#!/usr/bin/env python
"""Phase 4 finalize: re-render the preview with the offset patch annotated,
and write data/neossat_image.json with the full record."""
import json
import numpy as np
from astropy.io import fits
from astropy.wcs import WCS
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
facts = json.load(open(f'{BASE}/data/raw/neossat_facts.json'))
px, py = facts['px'], facts['py']

for k in ('OBJCTRA', 'OBJCTDEC', 'CMDRA', 'CMDDEC', 'RA_VEL', 'DEC_VEL', 'POINTING', 'WCSNAME'):
    if k in hdr:
        print(k, '=', hdr[k])

# final render
lo, hi = np.nanpercentile(data, [5, 99.7])
disp = np.arcsinh((np.clip(data, lo, hi) - lo) / (0.02 * (hi - lo)))
fig, axes = plt.subplots(1, 2, figsize=(13, 6.4), gridspec_kw={'width_ratios': [1.55, 1]})
ax = axes[0]
ax.imshow(disp, origin='lower', cmap='gray', interpolation='nearest')
ax.add_patch(Circle((px, py), 18, fill=False, color='red', lw=1.6))
ax.plot([px], [py], marker='+', color='red', ms=14, mew=1.6)
ax.set_title('NEOSSat (CSA) science image  NEOS_SCI_2025348075859_cor.fits\n'
             '2025-12-14 07:58:59 UTC, 15.0 s, CLEAR filter (4000-9000 A)\n'
             'red marker = 3I/ATLAS position interpolated from the SPHEREx motion fit', fontsize=10)
ax.set_xlabel('x (px)'); ax.set_ylabel('y (px)')
ax2 = axes[1]
z = 60
x0, x1, y0, y1 = int(px) - z, int(px) + z, int(py) - z, int(py) + z
ax2.imshow(disp[y0:y1, x0:x1], origin='lower', cmap='gray', interpolation='nearest',
           extent=[x0, x1, y0, y1])
ax2.add_patch(Circle((px, py), 12, fill=False, color='red', lw=1.6))
ax2.plot([px], [py], marker='+', color='red', ms=14, mew=1.6)
ax2.add_patch(Circle((484, 519), 10, fill=False, color='deepskyblue', lw=1.4, linestyle='--'))
ax2.annotate('faint field star\n(44 arcsec from prediction)', xy=(484, 519),
             xytext=(452, 486), color='deepskyblue', fontsize=8,
             arrowprops=dict(arrowstyle='->', color='deepskyblue', lw=1.0))
ax2.set_title('zoom: no significant source at the predicted position\n'
              '(aperture excess = 12th-60th percentile of random positions)', fontsize=10)
ax2.set_xlabel('x (px)'); ax2.set_ylabel('y (px)')
fig.tight_layout()
fig.savefig(f'{BASE}/data/neossat_preview.png', dpi=110)
print('re-rendered data/neossat_preview.png')

cd = np.hypot(hdr['CD1_1'], hdr['CD2_1']) * 3600  # arcsec/px along axis 1
out = {
 'task': 'Phase 4: download and verify one real NEOSSat science image of 3I/ATLAS from CADC',
 'status': 'DOWNLOAD SUCCEEDED; comet NOT detected in this single frame (see visibility_assessment)',
 'observation': {
  'observationID_caom': '2025348075859',
  'obs_id_header': str(hdr['OBS_ID']),
  'target_name': str(hdr['OBJECT']),
  'intent': 'science',
  'calibration_level_caom': 2,
  'cal_lvl_header': str(hdr['CAL_LVL']),
  'product_header': str(hdr['PRODUCT']),
  'date_obs_utc': str(hdr['DATE-OBS']),
  'plane_time_bounds_utc': ['2025-12-14 07:58:59.053', '2025-12-14 07:59:14.057'],
  'data_release': '2025-12-14T07:58:59 (CAOM Plane.dataRelease = header RELEASE; public)',
 },
 'artifact': {
  'uri': 'cadc:NEOSSAT/NEOS_SCI_2025348075859_cor.fits',
  'content_length_caom_bytes': 4219200,
  'downloaded_bytes': 4219200,
  'content_type': 'application/fits',
  'download_url_pattern': 'https://ws.cadc-ccda.hia-iha.nrc-cnrc.gc.ca/raven/files/{artifactURI}',
  'download_url_used': 'https://ws.cadc-ccda.hia-iha.nrc-cnrc.gc.ca/raven/files/cadc:NEOSSAT/NEOS_SCI_2025348075859_cor.fits',
  'local_fits_path': 'work/NEOS_SCI_2025348075859_cor.fits (4.2 MB, kept - well under the 200 MB cap)',
  'preview_png': 'data/neossat_preview.png',
 },
 'download_attempts': [
  {'route': 'CADC TAP (argus) CAOM-2 Artifact query', 'result': 'SUCCESS - artifact URIs and release metadata are public'},
  {'route': 'GET https://www.cadc-ccda.hia-iha.nrc-cnrc.gc.ca/data/pub/{artifactURI} (science FITS)', 'result': 'HTTP 401 "authentication required"'},
  {'route': 'GET data/pub for the preview PNG artifact', 'result': 'HTTP 401 "authentication required"'},
  {'route': 'control: GET data/pub for a public CFHT science file (cadc:CFHT/2015609p.fits.fz)', 'result': 'HTTP 401 as well - data/pub is auth-gated in general, not a NEOSSat proprietary block'},
  {'route': 'GET https://ws.cadc-ccda.hia-iha.nrc-cnrc.gc.ca/minoc/files/{artifactURI}', 'result': 'HTTP 404'},
  {'route': 'DataLink links endpoints (www and ws hosts, /datalink/links and /caom2ops/datalink)', 'result': 'HTTP 404 on all candidates'},
  {'route': 'GET https://ws.cadc-ccda.hia-iha.nrc-cnrc.gc.ca/raven/files/{artifactURI}', 'result': 'SUCCESS - HTTP 200, application/fits, full 4,219,200 bytes'},
 ],
 'image_facts': {
  'format': 'FITS, single primary HDU, float32',
  'dimensions_px': [int(hdr['NAXIS1']), int(hdr['NAXIS2'])],
  'telescope': str(hdr['TELESCOP']),
  'instrument_detector': str(hdr['DETECTOR']),
  'filter': str(hdr['FILTER']),
  'central_wavelength_angstrom': int(hdr['WAVELENG']),
  'bandpass_angstrom': str(hdr['BANDPASS']),
  'exposure_s': float(hdr['EXPOSURE']),
  'gain_e_per_adu': float(hdr['GAIN']),
  'read_noise_e': float(hdr['RDNOISE']),
  'pixel_scale_arcsec_per_px': round(float(cd), 3),
  'fov_deg': [round(int(hdr['NAXIS1']) * float(cd) / 3600, 3), round(int(hdr['NAXIS2']) * float(cd) / 3600, 3)],
  'rotation_crota2_deg': float(hdr['CROTA2']),
  'tracking_moving_flag': str(hdr['MOVING']) + ' (sidereal tracking; comet trail in 15 s = 0.73 arcsec, sub-pixel)',
  'saturated_pixels_header': int(hdr['NBSATPIX']),
  'image_completeness_pct': float(hdr['IMG_PERC']),
  'pixel_stats_adu': {'min': float(np.nanmin(data)), 'median': float(np.nanmedian(data)),
                      'p99': float(np.nanpercentile(data, 99)), 'p99_9': float(np.nanpercentile(data, 99.9)),
                      'max': float(np.nanmax(data))},
 },
 'pointing': {
  'header_ra_dec_strings': [str(hdr['RA']), str(hdr['DEC'])],
  'wcs_crval_deg': [float(hdr['CRVAL1']), float(hdr['CRVAL2'])],
  'spherex_field_centre_deg': [167.1309, 5.1732],
  'offset_from_spherex_field_centre_arcsec': 7.9,
  'note': 'NEOSSat WCS centre sits ~8 arcsec from the SPHEREx field centre: the two telescopes were looking at the same patch of sky that morning.',
 },
 'comet_prediction': {
  'method': 'Linear interpolation of the SPHEREx 5-epoch motion fit (data/motion.json; fit RMS 0.31 arcsec over 2025-12-14) to the NEOSSat mid-exposure time. NEOSSat time falls between SPHEREx epochs 3 and 4, so this is interpolation, not extrapolation.',
  'mid_exposure_utc': facts['t_mid'],
  'ra_deg': round(facts['ra_pred'], 5),
  'dec_deg': round(facts['dec_pred'], 5),
  'pixel_xy_0based': [round(facts['px'], 1), round(facts['py'], 1)],
  'offset_from_image_pointing_centre_arcsec': 61,
 },
 'visibility_assessment': {
  'verdict': 'NOT DETECTED in this single 15.0 s frame',
  'aperture_excess_adu': {'r3px': -199, 'r5px': 2352, 'r8px': 20513},
  'control_test': 'Same aperture measurement at 400 random field positions: the predicted-position excess ranks at the 12th percentile (r=5 px) and 60th percentile (r=8 px) - statistically indistinguishable from empty sky positions.',
  'nearest_features': 'Brightest raw pixel within 15 px of the prediction is 2920 ADU at 12.3 px offset (consistent with noise/star field). A diffuse patch 14.5 px (44 arcsec) away at (484,519) has a profile width (sigma ~4.9 px) matching the stellar PSF in this product (sigma 5.3-6.5 px) and no counterpart at that fixed sky position in SPHEREx epochs 1/5; assessed as a faint field star, not the comet.',
  'context': '3I/ATLAS in mid-Dec 2025 was a faint, highly diffuse comet; NEOSSat is a 15 cm microsatellite and this is a single 15 s sidereal-tracked exposure. CADC holds 44 NEOSSat 3I observations overlapping this field from 2025-12-13/14 (data/neossat_check.json); shift-and-stack of that sequence is the natural next step and was out of scope for this single-image task.',
 },
}
json.dump(out, open(f'{BASE}/data/neossat_image.json', 'w'), indent=1)
print('wrote data/neossat_image.json')
