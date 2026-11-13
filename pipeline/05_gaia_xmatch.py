#!/usr/bin/env python
"""Gaia DR3 cross-match for the Cipher-X Omega SPHEREx 3I/ATLAS field.

- Cone-searches Gaia DR3 (ESA TAP via astroquery) around the field centre.
- Propagates positions from Gaia epoch J2016.0 to the SPHEREx epoch
  2025-12-14 using catalogued proper motions (parallax neglected: <=0.05",
  negligible vs the 6.13" SPHEREx pixels).
- Maps RA/Dec -> native pixels with the epoch-3 FITS celestial WCS (TAN-SIP),
  then scales to the 900x900 PNG space exactly as Phase 1 did
  (png = native * 900/NAXIS).
- Validates the mapping by centroiding the brightest Gaia stars in the
  epoch-3 FITS image and by peak-snapping in epoch3.png.
- Checks the comet's epoch-1 and epoch-5 positions against the propagated
  catalogue (nearest fixed Gaia source).
"""
import json
import numpy as np
from astropy.io import fits
from astropy.wcs import WCS
from astropy.coordinates import SkyCoord
import astropy.units as u
from astroquery.gaia import Gaia

import os
BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RA0, DEC0 = 167.1309, 5.1732
RADIUS = 0.36  # deg
OBS_EPOCH_YR = 2025.953   # 2025-12-14
GAIA_EPOCH_YR = 2016.0
DT = OBS_EPOCH_YR - GAIA_EPOCH_YR

# ---------------------------------------------------------------- Gaia query
ADQL = f"""
SELECT source_id, ra, dec, phot_g_mean_mag, phot_bp_mean_mag, phot_rp_mean_mag,
       bp_rp, pmra, pmdec, parallax
FROM gaiadr3.gaia_source
WHERE CONTAINS(POINT('ICRS', ra, dec),
               CIRCLE('ICRS', {RA0}, {DEC0}, {RADIUS})) = 1
  AND phot_g_mean_mag IS NOT NULL
ORDER BY phot_g_mean_mag ASC
"""
print('Launching Gaia DR3 cone query...')
# NOTE: astroquery's TapPlus client ignores this sandbox's HTTPS egress proxy
# and its TLS handshake fails (WRONG_VERSION_NUMBER). The identical ADQL is
# therefore submitted to the same ESA TAP sync endpoint with a proxy-aware
# requests session and parsed as a VOTable.
import io
import requests
from astropy.io.votable import parse as vot_parse
resp = requests.post(
    'https://gea.esac.esa.int/tap-server/tap/sync',
    data={'REQUEST': 'doQuery', 'LANG': 'ADQL', 'FORMAT': 'votable_plain',
          'QUERY': ADQL, 'MAXREC': '200000'},
    timeout=600)
resp.raise_for_status()
tab = vot_parse(io.BytesIO(resp.content)).get_first_table().to_table()
print(f'Gaia rows returned: {len(tab)}')
src = np.array(tab['SOURCE_ID'], dtype=np.int64)  # ESA TAP upper-cases this name
ra = np.array(tab['ra'], dtype=float)
dec = np.array(tab['dec'], dtype=float)
gmag = np.array(tab['phot_g_mean_mag'], dtype=float)
bprp = np.array(tab['bp_rp'], dtype=float)
pmra = np.array(tab['pmra'], dtype=float)     # mas/yr, already includes cos(dec)
pmdec = np.array(tab['pmdec'], dtype=float)   # mas/yr
has_pm = np.isfinite(pmra) & np.isfinite(pmdec)

# ------------------------------------------------- propagate to 2025-12-14
ra_p = ra.copy(); dec_p = dec.copy()
ra_p[has_pm] = ra[has_pm] + (pmra[has_pm] * DT) / 3.6e6 / np.cos(np.deg2rad(dec[has_pm]))
dec_p[has_pm] = dec[has_pm] + (pmdec[has_pm] * DT) / 3.6e6

# ------------------------------------------------------------------- WCS map
hdul = fits.open(f'{BASE}/data/raw/cut_e3.fits')
img = hdul['IMAGE'].data.astype(float)
wcs = WCS(hdul['IMAGE'].header).celestial
NY, NX = img.shape  # 293, 294
fx, fy = wcs.world_to_pixel_values(ra_p, dec_p)
inside = (fx >= 0) & (fx < NX) & (fy >= 0) & (fy < NY)
print(f'Sources inside the 0.5-deg field: {inside.sum()}')

SX, SY = 900.0 / NX, 900.0 / NY

def to_png(fx_, fy_):
    return float(fx_ * SX), float(fy_ * SY)

# brightest ~20 inside the field (table already sorted by G)
idx_in = np.where(inside)[0][:20]
stars = []
for i in idx_in:
    px, py = to_png(fx[i], fy[i])
    stars.append({
        'gaia_dr3_source_id': int(src[i]),
        'ra_deg_j2016': round(float(ra[i]), 7),
        'dec_deg_j2016': round(float(dec[i]), 7),
        'ra_deg_at_2025_12_14': round(float(ra_p[i]), 7),
        'dec_deg_at_2025_12_14': round(float(dec_p[i]), 7),
        'g_mag': round(float(gmag[i]), 3),
        'bp_rp': (round(float(bprp[i]), 3) if np.isfinite(bprp[i]) else None),
        'pmra_mas_yr': (round(float(pmra[i]), 3) if np.isfinite(pmra[i]) else None),
        'pmdec_mas_yr': (round(float(pmdec[i]), 3) if np.isfinite(pmdec[i]) else None),
        'native_pixel_x': round(float(fx[i]), 2),
        'native_pixel_y': round(float(fy[i]), 2),
        'png900_pixel_x': round(px, 1),
        'png900_pixel_y': round(py, 1),
    })

# ------------------------------------------------------------- validation
# Centroid the top-5 brightest in the epoch-3 FITS image (native space).
def centroid(img, cx, cy, half=4):
    x0, x1 = int(cx) - half, int(cx) + half + 1
    y0, y1 = int(cy) - half, int(cy) + half + 1
    sub = img[y0:y1, x0:x1].copy()
    bg = np.median(sub)
    sub -= bg
    sub[sub < 0.25 * sub.max()] = 0.0
    yy, xx = np.mgrid[y0:y1, x0:x1]
    tot = sub.sum()
    return float((sub * xx).sum() / tot), float((sub * yy).sum() / tot), float(img[int(round(cy)), int(round(cx))])

from PIL import Image
png = np.asarray(Image.open(f'{BASE}/data/epoch3.png').convert('L'), dtype=float)

validation = []
for s in stars[:5]:
    cx, cy, peakval = centroid(img, s['native_pixel_x'], s['native_pixel_y'])
    dxn, dyn = cx - s['native_pixel_x'], cy - s['native_pixel_y']
    # peak-snap in the PNG within +-12 px of the predicted position
    pxp, pyp = s['png900_pixel_x'], s['png900_pixel_y']
    win = png[int(pyp) - 12:int(pyp) + 13, int(pxp) - 12:int(pxp) + 13]
    oy, ox = np.unravel_index(np.argmax(win), win.shape)
    snap_x, snap_y = int(pxp) - 12 + ox, int(pyp) - 12 + oy
    validation.append({
        'gaia_dr3_source_id': s['gaia_dr3_source_id'],
        'g_mag': s['g_mag'],
        'predicted_native_xy': [s['native_pixel_x'], s['native_pixel_y']],
        'image_centroid_native_xy': [round(cx, 2), round(cy, 2)],
        'offset_native_px': [round(dxn, 2), round(dyn, 2)],
        'offset_png900_px': [round(dxn * SX, 2), round(dyn * SY, 2)],
        'offset_arcsec': round(float(np.hypot(dxn, dyn)) * 6.137, 2),
        'fits_peak_MJy_sr_at_predicted': round(peakval, 2),
        'png_peak_snap_xy': [snap_x, snap_y],
        'png_peak_snap_offset_px': [snap_x - round(pxp), snap_y - round(pyp)],
    })
    print(f"G={s['g_mag']:.2f} pred=({s['native_pixel_x']:.1f},{s['native_pixel_y']:.1f}) "
          f"centroid offset=({dxn:+.2f},{dyn:+.2f}) native px = {np.hypot(dxn,dyn)*6.137:.1f} arcsec; "
          f"PNG snap offset=({snap_x-round(pxp):+d},{snap_y-round(pyp):+d}) px")

offs = np.array([v['offset_native_px'] for v in validation])
median_shift = np.median(offs, axis=0)
print('Median validation offset (native px):', median_shift)

# Does the spectra.json trio correspond to Gaia stars? (nearest propagated source)
spec = json.load(open(f'{BASE}/data/spectra.json'))
trio = {}
for name in ('field_star_1', 'field_star_2', 'field_star_3'):
    nx_, ny_ = spec['photometry'][name]['positions_native_xy'][0]
    d = np.hypot(fx - nx_, fy - ny_)
    j = int(np.argmin(d))
    trio[name] = {
        'spectra_native_xy': [nx_, ny_],
        'nearest_gaia_source_id': int(src[j]),
        'nearest_gaia_g_mag': round(float(gmag[j]), 3),
        'separation_native_px': round(float(d[j]), 2),
        'separation_arcsec': round(float(d[j]) * 6.137, 1),
    }

# ------------------------------------------------- comet vs fixed catalogue
meta = json.load(open(f'{BASE}/data/metadata.json'))
cat = SkyCoord(ra_p * u.deg, dec_p * u.deg)
comet_nn = {}
for ep_key, ep in (('epoch1', meta['epochs'][0]), ('epoch5', meta['epochs'][4])):
    c = SkyCoord(ep['comet_ra_deg'] * u.deg, ep['comet_dec_deg'] * u.deg)
    i2, sep, _ = c.match_to_catalog_sky(cat)
    i2 = int(np.atleast_1d(i2)[0])
    sep_arcsec = float(np.atleast_1d(sep.to(u.arcsec).value)[0])
    comet_nn[ep_key] = {
        'comet_ra_deg': ep['comet_ra_deg'],
        'comet_dec_deg': ep['comet_dec_deg'],
        'nearest_gaia_source_id': int(src[i2]),
        'nearest_gaia_g_mag': round(float(gmag[i2]), 3),
        'nearest_separation_arcsec': round(sep_arcsec, 1),
    }
    print(ep_key, 'nearest Gaia separation (arcsec):', comet_nn[ep_key]['nearest_separation_arcsec'])

out = {
    'query': {
        'archive': ('ESA Gaia Archive TAP sync endpoint (gea.esac.esa.int/tap-server/tap/sync). '
            'ADQL written for astroquery.gaia; astroquery\'s TapPlus client cannot traverse this '
            'sandbox\'s HTTPS egress proxy (TLS WRONG_VERSION_NUMBER), so the identical query was '
            'POSTed with a proxy-aware requests session and the VOTable parsed with astropy.'),
        'table': 'gaiadr3.gaia_source',
        'adql': ' '.join(ADQL.split()),
        'cone_centre_deg': [RA0, DEC0],
        'cone_radius_deg': RADIUS,
        'rows_returned': int(len(tab)),
        'rows_inside_field': int(inside.sum()),
        'query_date_utc': '2026-11-13',
        'position_epoch_handling': ('Gaia DR3 positions (epoch J2016.0) propagated '
            'to 2025-12-14 with catalogue pmra/pmdec before WCS mapping and '
            'nearest-neighbour tests; parallax neglected (<=0.05 arcsec).'),
        'mapping': ('RA/Dec -> native pixel via epoch-3 FITS celestial WCS '
            '(RA---TAN-SIP) using astropy world_to_pixel_values (0-based, '
            'x=column, y=array row, empirically identical to the stored '
            'cutout array indexing); PNG900 = native * (900/294, 900/293), '
            'the same scaling Phase 1 used. No flip or shift correction '
            'was needed (see validation).'),
    },
    'brightest_20_in_field': stars,
    'validation_top5': validation,
    'validation_median_offset_native_px': [round(float(median_shift[0]), 2),
                                           round(float(median_shift[1]), 2)],
    'spectra_photometry_stars_matched': trio,
    'comet_nearest_gaia_neighbour': comet_nn,
}
with open(f'{BASE}/data/gaia_stars.json', 'w') as f:
    json.dump(out, f, indent=1,
              default=lambda o: int(o) if isinstance(o, np.integer) else float(o))
print('Wrote data/gaia_stars.json')
print('G range of top20:', stars[0]['g_mag'], '->', stars[-1]['g_mag'])
