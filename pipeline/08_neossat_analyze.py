#!/usr/bin/env python
"""Phase 4 step 2: analyse the downloaded NEOSSat image of 3I/ATLAS.

- Interpolates the comet position at the NEOSSat timestamp from the SPHEREx
  linear motion fit (data/motion.json, anchored at SPHEREx epoch 1).
- Puts the expected position on the NEOSSat WCS frame, does aperture
  photometry there, renders data/neossat_preview.png (full frame + zoom
  inset, marker drawn), and writes data/neossat_image.json.
"""
import json
import numpy as np
from astropy.io import fits
from astropy.wcs import WCS
from astropy.time import Time
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Circle

import os
BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FITS_PATH = f'{BASE}/data/raw/NEOS_SCI_2025348075859_cor.fits'

hdr = fits.getheader(FITS_PATH)
data = fits.getdata(FITS_PATH).astype(np.float64)
w = WCS(hdr)

# --- comet position from the SPHEREx linear fit at the NEOSSat mid-exposure
motion = json.load(open(f'{BASE}/data/motion.json'))
meta = json.load(open(f'{BASE}/data/metadata.json'))
t_epoch1 = Time(meta['epochs'][0]['observation_datetime_utc'])
from astropy import units as u
t_obs = Time(hdr['DATE-OBS']) + (0.5 * float(hdr['EXPOSURE'])) * u.s  # mid-exposure
dt_days = (t_obs - t_epoch1).to_value('day')
ra_pred = motion['intercept_ra_deg_at_epoch1'] + motion['ra_rate_deg_per_day_raw_coordinate'] * dt_days
dec_pred = motion['intercept_dec_deg_at_epoch1'] + motion['dec_rate_deg_per_day'] * dt_days
px, py = w.all_world2pix(ra_pred, dec_pred, 0)  # 0-based, x=col, y=row
px, py = float(px), float(py)
print(f'mid-exposure {t_obs.isot}  dt={dt_days:.5f} d')
print(f'predicted comet RA={ra_pred:.5f} Dec={dec_pred:.5f} -> pixel x={px:.1f} y={py:.1f} (0-based)')

# --- image stats / aperture photometry at the expected position
med = np.nanmedian(data)
yy, xx = np.mgrid[0:data.shape[0], 0:data.shape[1]]
r = np.hypot(xx - px, yy - py)
for rad in (3, 5, 8):
    ap = r <= rad
    ann = (r > rad + 4) & (r <= rad + 12)
    bg = np.nanmedian(data[ann]); noise = 1.4826 * np.nanmedian(np.abs(data[ann] - bg))
    excess = np.nansum(data[ap] - bg)
    snr = excess / (noise * np.sqrt(ap.sum())) if noise > 0 else float('nan')
    print(f'r={rad}px: bg={bg:.1f} robust_std={noise:.1f} excess={excess:.0f} ADU  SNR~{snr:.1f}')
# brightest pixel within 15 px of prediction (pointing/ephemeris slop check)
box = (r <= 15)
vals = np.where(box, data, -np.inf)
iy, ix = np.unravel_index(np.nanargmax(vals), data.shape)
print(f'brightest pixel within 15px: ({ix},{iy}) value={data[iy,ix]:.0f} ADU, '
      f'offset={np.hypot(ix-px, iy-py):.1f} px')
# local peak in a smoothed sense: 3x3 boxcar max within 15 px
from scipy.ndimage import uniform_filter
sm = uniform_filter(np.nan_to_num(data, nan=med), size=3)
vals2 = np.where(box, sm, -np.inf)
jy, jx = np.unravel_index(np.argmax(vals2), sm.shape)
print(f'brightest 3x3-smoothed pixel within 15px: ({jx},{jy}) value={sm[jy,jx]:.0f} ADU/px, '
      f'offset={np.hypot(jx-px, jy-py):.1f} px')

# --- render preview: full frame + zoom inset, marker at prediction
lo, hi = np.nanpercentile(data, [5, 99.7])
disp = np.arcsinh((np.clip(data, lo, hi) - lo) / (0.02 * (hi - lo)))
fig, axes = plt.subplots(1, 2, figsize=(13, 6.2), gridspec_kw={'width_ratios': [1.55, 1]})
ax = axes[0]
ax.imshow(disp, origin='lower', cmap='gray', interpolation='nearest')
ax.add_patch(Circle((px, py), 18, fill=False, color='red', lw=1.6))
ax.plot([px], [py], marker='+', color='red', ms=14, mew=1.6)
ax.set_title('NEOSSat science image  NEOS_SCI_2025348075859_cor.fits\n'
             f"{hdr['DATE-OBS']} UTC, 15.0 s, CLEAR filter (4000-9000 A)\n"
             'red marker = 3I/ATLAS position from SPHEREx motion fit', fontsize=10)
ax.set_xlabel('x (px)'); ax.set_ylabel('y (px)')
ax2 = axes[1]
z = 60
x0, x1 = int(px) - z, int(px) + z
y0, y1 = int(py) - z, int(py) + z
ax2.imshow(disp[y0:y1, x0:x1], origin='lower', cmap='gray', interpolation='nearest',
           extent=[x0, x1, y0, y1])
ax2.add_patch(Circle((px, py), 12, fill=False, color='red', lw=1.6))
ax2.plot([px], [py], marker='+', color='red', ms=14, mew=1.6)
ax2.set_title(f'zoom: 120x120 px around prediction ({px:.0f}, {py:.0f})', fontsize=10)
ax2.set_xlabel('x (px)'); ax2.set_ylabel('y (px)')
fig.tight_layout()
out_png = f'{BASE}/data/neossat_preview.png'
fig.savefig(out_png, dpi=110)
print('wrote', out_png)

facts = {
    'px': px, 'py': py, 'ra_pred': ra_pred, 'dec_pred': dec_pred,
    'dt_days': dt_days, 't_mid': t_obs.isot,
    'brightest_raw_within15': {'x': int(ix), 'y': int(iy), 'value': float(data[iy, ix]),
                               'offset_px': float(np.hypot(ix - px, iy - py))},
    'brightest_smooth_within15': {'x': int(jx), 'y': int(jy), 'value': float(sm[jy, jx]),
                                  'offset_px': float(np.hypot(jx - px, jy - py))},
    'image_median': float(med),
}
json.dump(facts, open(f'{BASE}/data/raw/neossat_facts.json', 'w'), indent=1)
print(json.dumps(facts, indent=1))
