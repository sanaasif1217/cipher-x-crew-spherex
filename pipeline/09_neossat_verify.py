#!/usr/bin/env python
"""Phase 4 step 3: is anything at the predicted comet position unusual?
(a) control test: aperture excess at the prediction vs 400 random positions;
(b) cross-check the offset diffuse patch (484,519) against the SPHEREx PNGs:
    a fixed sky source there in all epochs = star/galaxy, not the comet;
(c) extent of the patch vs a typical star (2nd moments)."""
import json
import numpy as np
from astropy.io import fits
from astropy.wcs import WCS
from PIL import Image

import os
BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
hdr = fits.getheader(f'{BASE}/data/raw/NEOS_SCI_2025348075859_cor.fits')
data = fits.getdata(f'{BASE}/data/raw/NEOS_SCI_2025348075859_cor.fits').astype(np.float64)
w = WCS(hdr)
facts = json.load(open(f'{BASE}/data/raw/neossat_facts.json'))
px, py = facts['px'], facts['py']
H, Wd = data.shape
yy, xx = np.mgrid[0:H, 0:Wd]

def ap_excess(cx, cy, rad):
    r = np.hypot(xx - cx, yy - cy)
    ap = r <= rad
    ann = (r > rad + 4) & (r <= rad + 12)
    bg = np.nanmedian(data[ann])
    return float(np.nansum(data[ap] - bg)), float(bg)

rng = np.random.default_rng(7)
for rad in (5, 8):
    target, _ = ap_excess(px, py, rad)
    ctrls = []
    while len(ctrls) < 400:
        cx, cy = rng.uniform(40, Wd - 40), rng.uniform(40, H - 40)
        if np.hypot(cx - px, cy - py) < 45:
            continue
        ctrls.append(ap_excess(cx, cy, rad)[0])
    ctrls = np.array(ctrls)
    pct = 100 * np.mean(ctrls < target)
    print(f'r={rad}: predicted-pos excess={target:.0f} ADU; control median='
          f'{np.median(ctrls):.0f}, 95th pct={np.percentile(ctrls,95):.0f}; '
          f'target ranks at {pct:.0f}th percentile of random positions')

# sky coords of the offset patch and of the prediction
for name, (cx, cy) in {'patch_484_519': (484, 519), 'prediction': (px, py)}.items():
    ra, dec = w.all_pix2world(cx, cy, 0)
    print(f'{name}: RA={float(ra):.5f} Dec={float(dec):.5f}')

# (b) SPHEREx PNG check: 900px PNG, centre (450,450) = (167.1309, 5.1732), 2.0"/px
ra0, dec0 = 167.1309, 5.1732
def to_png(ra, dec):
    x = 450 - (ra - ra0) * np.cos(np.radians(dec0)) * 3600 / 2.0
    y = 450 - (dec - dec0) * 3600 / 2.0
    return x, y
patch_ra, patch_dec = [float(v) for v in w.all_pix2world(484, 519, 0)]
print('patch in SPHEREx PNG coords:', np.round(to_png(patch_ra, patch_dec), 1),
      ' prediction:', np.round(to_png(facts['ra_pred'], facts['dec_pred']), 1))
for ep in (1, 3, 5):
    img = np.asarray(Image.open(f'{BASE}/data/epoch{ep}.png').convert('L'), dtype=float)
    for name, (cx, cy) in {'patch': to_png(patch_ra, patch_dec),
                           'comet_pred': to_png(facts['ra_pred'], facts['dec_pred'])}.items():
        xi, yi = int(round(cx)), int(round(cy))
        ap = img[yi-4:yi+5, xi-4:xi+5]
        ann = img[yi-12:yi+13, xi-12:xi+13].copy()
        ann[8:17, 8:17] = np.nan
        print(f'  epoch{ep} {name}: 9x9 mean={ap.mean():.1f} vs local median '
              f'{np.nanmedian(ann):.1f} (PNG grey levels)')

# (c) extent: 2nd moments of the patch vs an isolated bright star
def moments(cx, cy, half=10):
    cut = data[cy-half:cy+half+1, cx-half:cx+half+1].copy()
    bg = np.median(np.concatenate([cut[0], cut[-1], cut[:, 0], cut[:, -1]]))
    cut = np.clip(cut - bg, 0, None)
    ys, xs = np.mgrid[-half:half+1, -half:half+1]
    tot = cut.sum()
    varx = (cut * xs**2).sum() / tot - ((cut * xs).sum() / tot)**2
    vary = (cut * ys**2).sum() / tot - ((cut * ys).sum() / tot)**2
    return float(np.sqrt(max(varx, 0))), float(np.sqrt(max(vary, 0))), float(tot)
print('patch moments (sigx, sigy, flux):', np.round(moments(484, 519), 2))
print('star  moments (sigx, sigy, flux):', np.round(moments(596, 356), 2), '(bright star at ~(596,356))')
print('star2 moments:', np.round(moments(134, 804), 2), '(bright star at ~(134,804))')
