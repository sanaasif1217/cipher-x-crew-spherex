# Cipher-X Omega — Memory over Files

**NASA Space Apps Challenge 2026 · Challenge: Planet X and SPHEREx**
**Team: Cipher-X Crew (Pakistan and India)**

🔭 **Live demo: https://sanaasif1217.github.io/cipher-x-crew-spherex/**

Cipher-X Omega detects change in the sky on **two axes at once**:

1. **Position change** — blink comparison and difference imaging of SPHEREx's own repeated epochs find what *moved*.
2. **Spectral-fingerprint change** — every object carries a compact fingerprint of its measured brightness and sampled wavelength; when a new visit's fingerprint differs, the object is flagged even if it never moved.

It is demonstrated end-to-end on real data: five SPHEREx observations of the interstellar comet **3I/ATLAS** taken across one morning (14 Dec 2025), cross-checked against the Gaia catalogue and a NEOSSat (CSA) observation of the same comet from the same morning — two space agencies' telescopes on a single timeline.

## Measured results

- Comet motion fitted from the five epochs: **1.167°/day (175″/hour)**, position angle 289.3°, fit residuals **0.31″ RMS**
- Difference imaging (epoch 5 − epoch 1) with artifact rejection recovers the comet as the **strongest genuine extended mover** in the field; in the clean same-detector test (epoch 3 − epoch 1) its vacated/appeared pair ranks 3rd and 4th among extended sources (peak SNR ≈ 294 / 253)
- The comet's sampled wavelength swept **1.213 → 1.827 µm** across the morning as it crossed SPHEREx's detector gradient — a five-point spectral trace written by its own motion
- **751 Gaia DR3 sources** in the field; the nearest fixed Gaia star is 51″ from the comet's first position and 27″ from its last — the comet is in no fixed-sky catalogue, because it moves
- **4,417 NEOSSat observations** target 3I/ATLAS in the CADC archive; 44 overlap this field on 2025-12-13/14. One real NEOSSat science frame (15 s, 2025-12-14 07:58:59 UTC) is analysed in the pipeline — honestly, the comet is not detectable in that single frame (control-tested). Step 14 shift-and-stacks the 40 calibrated frames (600 s total, aligned on the JPL Horizons position): the comet is detected at SNR 12.4 as an extended coma, above all 400 control positions, present in both halves of the night independently and absent at ±90″ offset positions

## Repository layout

| Path | Contents |
|---|---|
| `index.html` | The web application — a single self-contained file (blink comparator, Scan Shifts difference imaging, Fingerprint Lab, Motion & Predict, Spot the Mover, two-agency timeline). No build step; served by GitHub Pages. |
| `pipeline/` | The Python analysis pipeline, numbered in run order (see below). |
| `data/` | Result data produced by the pipeline (JSON): epoch metadata, photometry/fingerprints, detections, motion fit, Gaia cross-match, NEOSSat checks. |
| `requirements.txt` | Python dependencies. |

Large raw files (SPHEREx FITS cutouts, the NEOSSat FITS, rendered PNGs) are not committed; the pipeline downloads or regenerates them into `data/raw/` and `data/`.

## Pipeline

```bash
pip install -r requirements.txt
python pipeline/01_fetch_epochs.py            # IRSA SPHEREx cutouts -> registered stack + PNGs
python pipeline/02_photometry_fingerprints.py # aperture photometry -> data/spectra.json
python pipeline/03_difference_imaging.py      # epoch differencing   -> data/detections.json
python pipeline/04_motion_fit.py              # least-squares motion -> data/motion.json
python pipeline/05_gaia_xmatch.py             # Gaia DR3 cross-match -> data/gaia_stars.json
python pipeline/06_neossat_check.py           # CADC/NEOSSat overlap -> data/neossat_check.json
python pipeline/07_neossat_retrieve.py        # download one NEOSSat science frame
python pipeline/08_neossat_analyze.py         # analyse the frame (predicted-position test)
python pipeline/09_neossat_verify.py          # independent verification of the analysis
python pipeline/10_neossat_finalize.py        # write data/neossat_image.json + preview
```

A note on method: SPHEREx level-2 images are LVF (linear-variable filter) images — a single 2D plane per exposure, with each pixel sampling one wavelength (WCS-WAVE table). There is no spectral cube in a single cutout, and this project fabricates none: the "fingerprint" is band-integrated aperture photometry plus the real effective wavelength sampled at the object's position in each epoch.

## Data sources (official challenge resources)

- **NASA IRSA** — SPHEREx archive (QR2 level-2 spectral images of 3I/ATLAS)
- **SPHEREx Tutorial Notebooks** (IPAC) — level-2 data model, WCS-WAVE handling
- **WiseView** — blink-comparison reference and inspiration for the comparator design
- **Gaia via STScI** — Gaia DR3 catalogue for the fixed-sky cross-match
- **NEOSSat (CSA)** — Canadian Space Agency small-body observations of 3I/ATLAS
- **CADC** — Canadian Astronomy Data Centre archive access (CAOM-2 / raven)
- **NEOSSat Data Tutorial** — NEOSSat image model and calibration notes
- **NEOSSat Dataset** — the observation set queried for the overlap analysis

## Limitations and future work

- The +6-month position shown in the tool is a straight-line extrapolation of an 8-hour arc, labelled as illustrative — it is not an ephemeris; real orbit fitting is future work.
- A Python/FastAPI service with a vector database (Qdrant) for billion-object fingerprint lookup is the designed next step; the current fingerprint records (under 1 KB per object, vs ~6.4 MB per FITS cutout) define its schema.
- Stacking the 44 overlapping NEOSSat frames should pull the comet out of the noise; only single-frame analysis is included here.

## Team — Cipher-X Crew

- **Sana Asif — Team Leader**
- Sherdil Khan — Team Member
- Naheed Nawaz — Team Member
- Abdul Qadoos — Team Member
- Abdullah — Team Member
- Sujal Khanolkar — Team Member

Built for the NASA Space Apps Challenge 2026. Data: NASA SPHEREx (via IRSA/IPAC) and CSA NEOSSat (via CADC).
