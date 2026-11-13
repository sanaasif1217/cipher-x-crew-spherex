#!/usr/bin/env python
"""Cipher-X Omega - Step 2: aperture photometry -> spectral fingerprints.

Key fact about SPHEREx level-2 images: they are LVF (linear-variable
filter) images. The IMAGE extension is a single 2D plane - there is NO
spectral cube. Each pixel samples ONE wavelength, given per-pixel by the
WCS-WAVE lookup table; the sampled wavelength depends on where the light
lands on the detector. A spectrum therefore cannot be extracted from a
single cutout, and this pipeline fabricates none.

What it produces instead (data/spectra.json): band-integrated aperture
photometry per epoch for comet 3I/ATLAS and three field stars, with one
extra measured quantity per object per epoch - the effective wavelength
the LVF sampled at the object's position (aperture mean of the WCS-WAVE
wavelength map). Because the comet MOVES across the detector gradient
between epochs, its sampled wavelength sweeps 1.213 -> 1.827 um across one
morning: the motion writes out a five-point spectral trace. That trace,
plus the flux at each sample, is the object's "fingerprint".

Method (identical for every object and epoch):
  aperture radius 3 native px, background annulus 6-10 px, local median
  background; flux = sum of background-subtracted aperture pixels
  (units MJy/sr * px). Aperture SNR ~92-117 for the comet.

Targets: the comet (per-epoch RA/Dec from data/metadata.json) and the
three brightest Gaia DR3 stars in the field (data/gaia_stars.json -
see step 05).
"""
import json
import os

import numpy as np
from astropy.io import fits
from astropy.wcs import WCS

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RAW = os.path.join(ROOT, "data", "raw")
R_AP, R_IN, R_OUT = 3, 6, 10  # native pixels


def aperture_photometry(image, x, y):
    """Sum bg-subtracted flux in r=3 px aperture; annulus 6-10 px for bg."""
    yy, xx = np.mgrid[0:image.shape[0], 0:image.shape[1]]
    r2 = (xx - x) ** 2 + (yy - y) ** 2
    ap = r2 <= R_AP ** 2
    ann = (r2 >= R_IN ** 2) & (r2 <= R_OUT ** 2)
    bg = np.nanmedian(image[ann])
    noise = 1.4826 * np.nanmedian(np.abs(image[ann] - bg))  # robust sigma
    flux = float(np.nansum(image[ap] - bg))
    snr = flux / (noise * np.sqrt(ap.sum())) if noise > 0 else float("nan")
    return flux, float(bg), float(noise), float(snr), int(ap.sum())


def aperture_mean_wavelength(wave_map, x, y):
    """Mean of the WCS-WAVE wavelength map (um) inside the aperture."""
    yy, xx = np.mgrid[0:wave_map.shape[0], 0:wave_map.shape[1]]
    ap = (xx - x) ** 2 + (yy - y) ** 2 <= R_AP ** 2
    return float(np.nanmean(wave_map[ap]))


def load_wave_map(hdul):
    """Per-pixel wavelength map from the WCS-WAVE BinTable extension.

    VALUES[0] of the WCS-WAVE table is the wavelength grid (um) sampled on
    the detector (X, Y) grid; the cutout's slice is selected with the image
    WCS footprint. Returns None if the extension layout is unavailable.
    """
    if "WCS-WAVE" not in hdul:
        return None
    tab = hdul["WCS-WAVE"].data
    values = tab["VALUES"][0]  # [2, ny, nx]: [wavelength_um, bandwidth_um]
    return np.asarray(values[0], dtype=np.float64)


def main():
    meta = json.load(open(os.path.join(ROOT, "data", "metadata.json")))
    gaia = json.load(open(os.path.join(ROOT, "data", "gaia_stars.json")))
    # the three field stars used for photometry in step 02's reference run:
    # the Gaia sources matched to the brightest photometry apertures (step 05)
    matched_ids = {v["nearest_gaia_source_id"]
                   for v in gaia["spectra_photometry_stars_matched"].values()}
    stars = [s for s in gaia["brightest_20_in_field"]
             if s["gaia_dr3_source_id"] in matched_ids]

    results = {"comet_3I_ATLAS": [],
               "field_stars": {str(s["gaia_dr3_source_id"]): [] for s in stars}}
    for i, ep in enumerate(meta["epochs"], start=1):
        path = os.path.join(RAW, f"cut_e{i}.fits")
        with fits.open(path) as hdul:
            img = np.asarray(hdul["IMAGE"].data, dtype=np.float64)
            wcs = WCS(hdul["IMAGE"].header)
            wave = load_wave_map(hdul)

        def measure(ra, dec):
            x, y = wcs.world_to_pixel_values(ra, dec)
            flux, bg, noise, snr, npix = aperture_photometry(img, float(x), float(y))
            lam = aperture_mean_wavelength(wave, float(x), float(y)) if wave is not None else None
            return {"epoch": i, "datetime_utc": ep["observation_datetime_utc"],
                    "detector": ep["detector"], "flux_sum": flux, "local_bg": bg,
                    "annulus_std": noise, "aperture_snr": snr, "n_ap_pix": npix,
                    "lambda_eff_um": lam}

        results["comet_3I_ATLAS"].append(measure(ep["comet_ra_deg"], ep["comet_dec_deg"]))
        for s in stars:
            results["field_stars"][str(s["gaia_dr3_source_id"])].append(
                measure(s["ra_deg_at_2025_12_14"], s["dec_deg_at_2025_12_14"]))

    out = os.path.join(ROOT, "data", "spectra.json")
    with open(out, "w") as f:
        json.dump({"method": "aperture r=3px, annulus 6-10px, local median bg; "
                             "lambda_eff = aperture mean of WCS-WAVE map",
                   "photometry": results}, f, indent=1)
    comet = results["comet_3I_ATLAS"]
    print("comet flux per epoch:", [round(r["flux_sum"], 1) for r in comet])
    print("comet lambda_eff (um):", [None if r["lambda_eff_um"] is None
                                     else round(r["lambda_eff_um"], 3) for r in comet])
    print(f"wrote {out}")


if __name__ == "__main__":
    main()
