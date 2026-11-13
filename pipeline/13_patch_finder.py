#!/usr/bin/env python
"""Cipher-X Omega - Step 13: patch finder (any coordinates -> SPHEREx epochs).

The challenge brief's core interaction: a user enters the coordinates of
a patch of sky (right ascension, declination) and the tool shows the
series of images of that patch over time, like a little video, so moving
objects are easy to spot. The live web page demonstrates that viewer on
one worked patch (the 3I/ATLAS field); this step is the general engine
behind it.

Given any RA/Dec it queries the official IRSA SPHEREx archive
(spherex.obscore via TAP) for every level-2 image whose footprint
contains the point, and returns the epoch list: observation id, UTC,
and wavelength coverage. On the 3I/ATLAS field (RA 167.1309,
Dec +5.1732) it recovers the five 2025-12-14 epochs used by step 01
among the field's full coverage.

Usage:
    python 13_patch_finder.py --ra 167.1309 --dec 5.1732 --out out.json
    python 13_patch_finder.py --ra 270.0 --dec 66.56 --list-only

Data source: NASA/IPAC Infrared Science Archive (IRSA), SPHEREx
ObsCore table (spherex.obscore), queried 2026-11-13.
"""
import argparse
import json

import numpy as np
import pyvo
from astropy.time import Time

TAP_URL = "https://irsa.ipac.caltech.edu/TAP"


def find_epochs(ra, dec):
    """All level-2 SPHEREx images whose footprint contains (ra, dec)."""
    q = ("SELECT obs_id, access_url, s_ra, s_dec, t_min, em_min, em_max, "
         "obs_collection FROM spherex.obscore "
         "WHERE dataproduct_type='image' AND calib_level=2 "
         f"AND CONTAINS(POINT('ICRS', {ra}, {dec}), s_region) = 1 "
         "ORDER BY t_min")
    svc = pyvo.dal.TAPService(TAP_URL)
    rows = svc.search(q)
    epochs = {}
    for r in rows:
        oid = str(r["obs_id"])
        e = epochs.setdefault(oid, {
            "obs_id": oid,
            "t_min_mjd": float(r["t_min"]),
            "collection": str(r["obs_collection"]),
            "access_url": str(r["access_url"]),
            "bands_um": [],
        })
        e["bands_um"].append([round(float(r["em_min"]) * 1e6, 3),
                               round(float(r["em_max"]) * 1e6, 3)])
    out = []
    for e in epochs.values():
        bands = sorted({tuple(b) for b in e["bands_um"]})
        e["bands_um"] = [list(b) for b in bands]
        e["utc"] = Time(e["t_min_mjd"], format="mjd").isot
        e["band_span_um"] = [bands[0][0], bands[-1][1]] if bands else None
        out.append(e)
    out.sort(key=lambda e: e["t_min_mjd"])
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--ra", type=float, required=True)
    ap.add_argument("--dec", type=float, required=True)
    ap.add_argument("--out", default=None)
    ap.add_argument("--list-only", action="store_true")
    args = ap.parse_args()

    epochs = find_epochs(args.ra, args.dec)
    result = {
        "query": {"ra_deg": args.ra, "dec_deg": args.dec,
                  "source": "IRSA TAP spherex.obscore, level-2 images "
                            "whose footprint contains the point"},
        "n_epochs": len(epochs),
        "epochs": epochs,
    }
    if epochs:
        span = (epochs[-1]["utc"][:10], epochs[0]["utc"][:10])
        print(f"{len(epochs)} epochs cover RA {args.ra}, Dec {args.dec} "
              f"(dates {span[1]} to {span[0]})")
        for e in epochs[:8]:
            print(" ", e["utc"], e["obs_id"], e["band_span_um"])
        if len(epochs) > 8:
            print(f"  ... and {len(epochs) - 8} more")
    else:
        print("no level-2 SPHEREx coverage for that point yet")
    if args.out:
        with open(args.out, "w") as f:
            json.dump(result, f, indent=1)
        print("wrote", args.out)


if __name__ == "__main__":
    main()
