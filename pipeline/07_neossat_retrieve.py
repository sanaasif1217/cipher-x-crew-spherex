#!/usr/bin/env python
"""Cipher-X Omega - Step 7: retrieve a real NEOSSat science image (CADC).

NEOSSat (Canadian Space Agency) observed comet 3I/ATLAS on the same
morning as the SPHEREx epochs. Step 06 (neossat_check.py) established
that 4,417 CADC observations target '3I' and 44 overlap our SPHEREx field
on 2025-12-13/14. This step retrieves one of them:

  observation  NEOS_SCI_2025348075859
  epoch        2025-12-14 07:58:59 UTC (between SPHEREx epochs 3 and 4)
  exposure     15.0 s, CLEAR filter (4000-9000 A), 1024x1020, 3.0"/px
  pointing     ~8 arcsec from the SPHEREx field centre

Download route (documented because the obvious one fails): CADC's
data/pub service answers HTTP 401 for these files; the raven file
service serves them publicly:
  GET https://ws.cadc-ccda.hia-iha.nrc-cnrc.gc.ca/raven/files/{artifactURI}

The FITS (4.2 MB) is saved to data/raw/ and analysed in step 08.
Honest result (step 08/09): the comet is NOT detectable in this single
15-second frame - verified against 400 random control positions.
Stacking all 44 overlapping frames is future work.
"""
import os
import subprocess

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RAW = os.path.join(ROOT, "data", "raw")
os.makedirs(RAW, exist_ok=True)

ARTIFACT_URI = "cadc:NEOSSAT/NEOS_SCI_2025348075859_cor.fits"
RAVEN = "https://ws.cadc-ccda.hia-iha.nrc-cnrc.gc.ca/raven/files/"


def main():
    out = os.path.join(RAW, "NEOS_SCI_2025348075859_cor.fits")
    if os.path.exists(out):
        print(f"already present: {out}")
        return
    url = RAVEN + ARTIFACT_URI
    print(f"GET {url}")
    subprocess.run(["curl", "-sL", "--fail", "-o", out, url], check=True)
    print(f"saved {out} ({os.path.getsize(out)} bytes)")


if __name__ == "__main__":
    main()
