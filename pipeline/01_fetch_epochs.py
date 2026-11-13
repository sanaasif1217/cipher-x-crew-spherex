#!/usr/bin/env python
"""Cipher-X Omega - Step 1: fetch the real SPHEREx epochs of comet 3I/ATLAS.

Dataset: five SPHEREx QR2 level-2 spectral images of the SAME 0.5-degree
field, taken across one morning, 2025-12-14 (UTC), found in the NASA IRSA
SPHEREx archive. The field centre (RA 167.1309, Dec +5.1732) is the comet's
position at the middle epoch; every cutout is requested with the identical
centre and size, so the field stars register across epochs and only the
comet moves.

What this script does
---------------------
1. Downloads the five level-2 cutouts (IRSA IBE access URLs, ?center=&size=
   cutout parameters) into data/raw/cut_e1..e5.fits.
2. Reprojects every cutout onto the epoch-3 WCS grid (reproject_interp) and
   subtracts each image's median background -> the registered stack used by
   steps 02-03, saved as data/raw/stack.npy.
3. Renders the 900x900 display PNGs (data/epoch1..5.png) used by the web
   tool: asinh stretch (scale = 99.9th percentile over all epochs), subtle
   blue tint, bilinear resize. North up, east left.

Epochs 1-3 are detector D2 (1.103-1.650 um); epochs 4-5 are detector D3
(1.630-2.435 um). August 2025 epochs were evaluated and rejected: the comet
was 20-30x fainter then and is not detectable in them.

Data source: NASA/IPAC Infrared Science Archive (IRSA), SPHEREx QR2.
An IRSA-generated wget script for the same frames is kept alongside this
file as download_3iatlas.sh.
"""
import json
import os
import urllib.request

import numpy as np
from astropy.io import fits
from reproject import reproject_interp

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RAW = os.path.join(ROOT, "data", "raw")
os.makedirs(RAW, exist_ok=True)

CENTER = "167.1309,5.1732d"
SIZE = "0.5"
EPOCHS = [
    # (obs_id, datetime_utc, detector, IBE access path)
    ("2025W50_2A_0685_1", "2025-12-14T04:26:46Z", "D2",
     "2025W50_2A/l2b-v20-2025-349/2/level2_2025W50_2A_0685_1D2_spx_l2b-v20-2025-349.fits"),
    ("2025W50_2A_0698_1", "2025-12-14T06:01:11Z", "D2",
     "2025W50_2A/l2b-v20-2025-349/2/level2_2025W50_2A_0698_1D2_spx_l2b-v20-2025-349.fits"),
    ("2025W50_2A_0712_1", "2025-12-14T07:39:58Z", "D2",
     "2025W50_2A/l2b-v20-2025-349/2/level2_2025W50_2A_0712_1D2_spx_l2b-v20-2025-349.fits"),
    ("2025W50_2A_0741_1", "2025-12-14T10:58:39Z", "D3",
     "2025W50_2A/l2b-v20-2025-349/3/level2_2025W50_2A_0741_1D3_spx_l2b-v20-2025-349.fits"),
    ("2025W50_2A_0755_1", "2025-12-14T12:36:36Z", "D3",
     "2025W50_2A/l2b-v20-2025-349/3/level2_2025W50_2A_0755_1D3_spx_l2b-v20-2025-349.fits"),
]
IBE = "https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/"


def download_cutouts():
    paths = []
    for i, (obs_id, _dt, _det, path) in enumerate(EPOCHS, start=1):
        out = os.path.join(RAW, f"cut_e{i}.fits")
        if not os.path.exists(out):
            url = f"{IBE}{path}?center={CENTER}&size={SIZE}"
            print(f"epoch {i}: {obs_id} -> {out}")
            urllib.request.urlretrieve(url, out)
        paths.append(out)
    return paths


def build_stack(paths):
    """Reproject all cutouts onto the epoch-3 grid; median-subtract each."""
    with fits.open(paths[2]) as hdul:
        ref_hdu = hdul["IMAGE"]
        ref_wcs_header = ref_hdu.header
    stack = []
    for p in paths:
        with fits.open(p) as hdul:
            arr, _ = reproject_interp(hdul["IMAGE"], ref_wcs_header)
        arr = np.asarray(arr, dtype=np.float64)
        arr -= np.nanmedian(arr)
        stack.append(arr)
    stack = np.array(stack)
    np.save(os.path.join(RAW, "stack.npy"), stack)
    return stack


def render_pngs(stack):
    """asinh-stretched, blue-tinted 900x900 display frames for the web tool."""
    from PIL import Image

    scale = np.nanpercentile(stack, 99.9)
    tint = np.array([0.80, 0.89, 1.00])
    for i, img in enumerate(stack, start=1):
        v = np.arcsinh(np.clip(img, 0, None) / (0.02 * scale))
        v /= v.max() if v.max() > 0 else 1.0
        rgb = (np.dstack([v * t for t in tint]) * 255).astype(np.uint8)
        im = Image.fromarray(rgb).resize((900, 900), Image.BILINEAR)
        im.save(os.path.join(ROOT, "data", f"epoch{i}.png"))
    print("rendered data/epoch1..5.png (900x900)")


if __name__ == "__main__":
    paths = download_cutouts()
    stack = build_stack(paths)
    render_pngs(stack)
    meta = json.load(open(os.path.join(ROOT, "data", "metadata.json")))
    print(f"field centre RA {meta['field_center_ra_deg']}, "
          f"Dec {meta['field_center_dec_deg']} - stack {stack.shape} ready")
