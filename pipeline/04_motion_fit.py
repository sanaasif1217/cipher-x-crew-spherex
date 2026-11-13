#!/usr/bin/env python
"""Cipher-X Omega - Step 4: motion fit for comet 3I/ATLAS.

Unweighted least-squares linear fit of RA(t) and Dec(t) across the five
SPHEREx epochs of 2025-12-14 (span 0.3406 d = 8 h 10 min), using the
comet's catalogued per-epoch positions in data/metadata.json.

Results (data/motion.json):
  total on-sky rate  1.167 deg/day  = 175.1 arcsec/hour
  position angle     289.3 deg east of north
  fit residuals      0.31 arcsec RMS (about 1/20 of a SPHEREx pixel)

The +6-month point is a straight-line EXTRAPOLATION ONLY - an illustration
of the prediction concept, not an ephemeris. Real bodies follow Keplerian
orbits; over ~182 days the true comet is nowhere near the extrapolated
point. The web tool labels it exactly that way.
"""
import json
import os
from datetime import datetime, timezone

import numpy as np

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def main():
    meta = json.load(open(os.path.join(ROOT, "data", "metadata.json")))
    epochs = meta["epochs"]
    t0 = datetime.fromisoformat(epochs[0]["observation_datetime_utc"].replace("Z", "+00:00"))
    t = np.array([(datetime.fromisoformat(e["observation_datetime_utc"].replace("Z", "+00:00")) - t0)
                  .total_seconds() / 86400.0 for e in epochs])
    ra = np.array([e["comet_ra_deg"] for e in epochs])
    dec = np.array([e["comet_dec_deg"] for e in epochs])

    A = np.vstack([t, np.ones_like(t)]).T
    ra_rate, ra0 = np.linalg.lstsq(A, ra, rcond=None)[0]
    dec_rate, dec0 = np.linalg.lstsq(A, dec, rcond=None)[0]

    cosd = np.cos(np.radians(dec.mean()))
    ra_rate_sky = ra_rate * cosd
    total = float(np.hypot(ra_rate_sky, dec_rate))
    pa = float(np.degrees(np.arctan2(ra_rate_sky, dec_rate)) % 360.0)

    res_ra = (ra - (ra_rate * t + ra0)) * 3600.0 * cosd   # arcsec, on-sky
    res_dec = (dec - (dec_rate * t + dec0)) * 3600.0      # arcsec
    rms = float(np.sqrt(np.mean(res_ra ** 2 + res_dec ** 2)))

    days = 182.34016203703703  # epoch 1 -> 2026-06-14
    pred_ra = float((ra0 + ra_rate * days) % 360.0)
    pred_dec = float(dec0 + dec_rate * days)

    out = {
        "fit": "Unweighted least-squares linear fit of RA(t), Dec(t) across "
               "the 5 epochs of 2025-12-14. On-sky RA rate = raw RA rate * cos(mean Dec).",
        "epoch_times_days_since_epoch1": t.tolist(),
        "ra_rate_deg_per_day_raw_coordinate": float(ra_rate),
        "dec_rate_deg_per_day": float(dec_rate),
        "ra_rate_on_sky_deg_per_day": float(ra_rate_sky),
        "total_on_sky_rate_deg_per_day": total,
        "total_on_sky_rate_arcsec_per_hour": total * 3600.0 / 24.0,
        "position_angle_deg_east_of_north": pa,
        "intercept_ra_deg_at_epoch1": float(ra0),
        "intercept_dec_deg_at_epoch1": float(dec0),
        "residuals_ra_arcsec_on_sky": res_ra.tolist(),
        "residuals_dec_arcsec": res_dec.tolist(),
        "residual_rms_on_sky_arcsec": rms,
        "prediction_plus_6_months": {
            "target_date": "2026-06-14",
            "days_after_epoch1": days,
            "ra_deg_wrapped_0_360": pred_ra,
            "dec_deg_unwrapped": pred_dec,
            "label": "ILLUSTRATIVE LINEAR EXTRAPOLATION ONLY - not an ephemeris.",
        },
    }
    path = os.path.join(ROOT, "data", "motion.json")
    with open(path, "w") as f:
        json.dump(out, f, indent=1)
    print(f"rate {total:.3f} deg/day ({total * 150:.1f} arcsec/hr), PA {pa:.1f} deg, "
          f"residual RMS {rms:.2f} arcsec")
    print(f"wrote {path}")


if __name__ == "__main__":
    main()
