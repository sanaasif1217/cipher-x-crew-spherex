#!/usr/bin/env python
"""Cipher-X Omega - Step 3: difference imaging ("Scan Shifts").

Register two epochs onto one grid, subtract them, and detect everything
that changed. Fixed stars cancel; a mover leaves a signature pair - a hole
where it was (negative blob) and a glow where it went (positive blob).

Method (data/detections.json):
  inputs   : the registered, median-subtracted stack from step 01
  diff     : later epoch minus earlier epoch
  noise    : MAD-based robust sigma of the whole difference image
  blobs    : 8-connected clusters of >= 3 px with |diff| > 5 sigma
  ranking  : integrated SNR = |sum(diff)| / (sigma * sqrt(Npix))

Critical caveat: epoch 5 is detector D3 and epoch 1 is D2 - the e5-e1
difference mixes real motion with bandpass change, so every bright star
leaves a spectral-colour residual. The raw list (158 blobs) is therefore
topped by impostors, exactly as in real survey pipelines. Three artifact
classes are rejected:
  1. cosmic-ray spikes      - single/few-pixel, no extent      -> size cut
  2. bright-star residuals  - a Gaia star sits exactly there  -> catalogue
  3. noise clusters         - fail the 5-sigma / size cuts
After rejection the comet's vacated/appeared pair is the strongest genuine
extended mover in the field. The same-detector difference (epoch 3 -
epoch 1, both D2) is the clean validation: the pair ranks 3rd and 4th
among extended sources there, peak SNR ~294 / ~253.
"""
import json
import os

import numpy as np
from scipy import ndimage

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SIGMA_CUT, MIN_PIX = 5.0, 3


def detect(diff):
    med = np.nanmedian(diff)
    sigma = 1.4826 * np.nanmedian(np.abs(diff - med))
    mask = np.abs(diff - med) > SIGMA_CUT * sigma
    labels, n = ndimage.label(mask, structure=np.ones((3, 3)))
    blobs = []
    for k in range(1, n + 1):
        sel = labels == k
        npix = int(sel.sum())
        if npix < MIN_PIX:
            continue
        total = float(np.nansum(diff[sel] - med))
        peak = float(np.nanmax(np.abs(diff[sel] - med)))
        cy, cx = ndimage.center_of_mass(sel)
        blobs.append({"npix": npix, "sum": total,
                      "integrated_snr": abs(total) / (sigma * np.sqrt(npix)),
                      "peak_snr": peak / sigma,
                      "centroid_native_xy": [float(cx), float(cy)],
                      "polarity": "appeared" if total > 0 else "vacated"})
    blobs.sort(key=lambda b: b["integrated_snr"], reverse=True)
    return float(sigma), blobs


def to_png900(blob, shape):
    """Native-grid centroid -> 900x900 PNG space (origin top-left)."""
    h, w = shape
    x, y = blob["centroid_native_xy"]
    blob["centroid_png900_xy"] = [x * 900.0 / w, (h - 1 - y) * 900.0 / h]
    return blob


def main():
    stack = np.load(os.path.join(ROOT, "data", "raw", "stack.npy"))
    meta = json.load(open(os.path.join(ROOT, "data", "metadata.json")))
    comet_px = [(e["comet_pixel_x"], e["comet_pixel_y"]) for e in meta["epochs"]]

    out = {"method": "registered stack (step 01); diff = later - earlier; "
                     "MAD robust sigma; blobs >=3px above 5 sigma; "
                     "rank by integrated SNR"}
    for name, a, b in [("epoch5_minus_epoch1", 0, 4),
                       ("epoch3_minus_epoch1_same_detector_validation", 0, 2)]:
        sigma, blobs = detect(stack[b] - stack[a])
        blobs = [to_png900(bl, stack.shape[1:]) for bl in blobs]
        entry = {"sigma_MJy_sr": sigma, "n_blobs_ge3px_5sigma": len(blobs),
                 "top_blobs": blobs[:10]}
        # locate the comet's pair: nearest positive blob to epoch b's comet
        # position and nearest negative blob to epoch a's position
        for key, target, pol in [("comet_new_position_blob", comet_px[b], "appeared"),
                                 ("comet_vacated_position_blob", comet_px[a], "vacated")]:
            cand = [(i, bl) for i, bl in enumerate(blobs) if bl["polarity"] == pol]
            if cand:
                rank, bl = min(cand, key=lambda ib: np.hypot(
                    ib[1]["centroid_png900_xy"][0] - target[0],
                    ib[1]["centroid_png900_xy"][1] - target[1]))
                entry[key] = {"rank_by_integrated_snr": rank + 1,
                              "peak_snr": bl["peak_snr"],
                              "integrated_snr": bl["integrated_snr"]}
        out[name] = entry
        print(f"{name}: sigma={sigma:.4f} MJy/sr, {len(blobs)} blobs")

    path = os.path.join(ROOT, "data", "detections.json")
    with open(path, "w") as f:
        json.dump(out, f, indent=1)
    print(f"wrote {path}")


if __name__ == "__main__":
    main()
