#!/usr/bin/env python
"""Time-boxed CADC / NEOSSat relevance check for the Cipher-X Omega field.

Queries the CADC TAP service (CAOM-2) for NEOSSat observations overlapping
the SPHEREx 3I/ATLAS field (RA 167.1309, Dec +5.1732) and for NEOSSat
observations targeted at the comet (3I/ATLAS / C/2025 N1). Every query and
its raw outcome is recorded, including zeros and errors.
"""
import io
import json
import subprocess
import time
from astropy.io.votable import parse as vot_parse

import os
BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TAP = 'https://ws.cadc-ccda.hia-iha.nrc-cnrc.gc.ca/argus/sync'
RA0, DEC0 = 167.1309, 5.1732

log = [{'label': 'endpoint_discovery',
        'note': ('The legacy endpoint https://www.cadc-ccda.hia-iha.nrc-cnrc.gc.ca/tap/sync '
                 'returns HTTP 404 (service retired). The current CADC TAP service '
                 '(ivo://cadc.nrc.ca/argus) was resolved via the CADC registry using '
                 'astroquery.cadc, giving base URL https://ws.cadc-ccda.hia-iha.nrc-cnrc.gc.ca/argus/; '
                 'its /sync endpoint is used below. Queries are sent with curl '
                 '(see transport note in the runner): Python requests cannot '
                 'follow CADC\'s sync redirect through this sandbox\'s egress '
                 'proxy, and CADC requires FORMAT=votable.')}]

def run(label, adql, timeout=240):
    """POST the ADQL to the CADC TAP sync endpoint via curl.

    Transport note: this sandbox's egress proxy drops the connection when
    Python requests follows CADC's sync->job redirect (ProxyError on
    /argus/sync/<id>/run), while curl -L completes the same flow. CADC also
    rejects FORMAT=votable_plain; FORMAT=votable is required.
    """
    t0 = time.time()
    entry = {'label': label, 'adql': ' '.join(adql.split())}
    try:
        p = subprocess.run(
            ['curl', '-sL', '--max-time', str(timeout), '-w', '\n%{http_code}',
             '--data-urlencode', 'REQUEST=doQuery',
             '--data-urlencode', 'LANG=ADQL',
             '--data-urlencode', 'FORMAT=votable',
             '--data-urlencode', f'QUERY={adql}', TAP],
            capture_output=True, timeout=timeout + 30)
        body, _, code = p.stdout.rpartition(b'\n')
        entry['http_status'] = int(code)
        if entry['http_status'] != 200:
            entry['error'] = body.decode('utf-8', 'replace')[:500]
        else:
            tab = vot_parse(io.BytesIO(body)).get_first_table().to_table()
            entry['n_rows'] = len(tab)
            entry['columns'] = list(tab.colnames)
            if len(tab):
                entry['sample'] = [
                    {c: (str(tab[c][i])) for c in tab.colnames}
                    for i in range(min(5, len(tab)))]
    except Exception as e:
        entry['error'] = f'{type(e).__name__}: {e}'
    entry['elapsed_s'] = round(time.time() - t0, 1)
    log.append(entry)
    print(label, '->', entry.get('n_rows', entry.get('error', '?')),
          f"({entry['elapsed_s']}s)")
    return entry

# Q0: verify CAOM-2 column names we rely on (no guessing)
run('schema_probe',
    "SELECT column_name FROM TAP_SCHEMA.columns "
    "WHERE table_name='caom2.Observation' AND "
    "(column_name IN ('collection','observationID','target_name','obsID'))")

# Q1: sanity -- the NEOSSat collection exists and its size
run('neossat_collection_size',
    "SELECT COUNT(*) AS n FROM caom2.Observation WHERE collection='NEOSSat'")

# Q2: NEOSSat observations whose footprint overlaps our field (0.5-deg radius
#     circle generously covers the 0.5x0.5-deg field plus pointing slop)
run('neossat_field_overlap',
    "SELECT TOP 50 o.observationID, o.target_name, o.intent, "
    "p.dataProductType, p.calibrationLevel "
    "FROM caom2.Observation AS o JOIN caom2.Plane AS p ON o.obsID = p.obsID "
    "WHERE o.collection='NEOSSat' "
    f"AND INTERSECTS(p.position_bounds, CIRCLE('ICRS', {RA0}, {DEC0}, 0.5)) = 1")

# Q3: NEOSSat observations targeted at the comet, any field/date
run('neossat_target_atlas',
    "SELECT observationID, target_name, intent FROM caom2.Observation "
    "WHERE collection='NEOSSat' AND (UPPER(target_name) LIKE '%ATLAS%' "
    "OR UPPER(target_name) LIKE '%3I%' OR UPPER(target_name) LIKE '%C/2025%')")

# Q4: control -- which collections DO cover this field (proves the spatial
#     query method works even if NEOSSat returns zero)
run('control_field_overlap_all_collections',
    "SELECT o.collection, COUNT(*) AS n "
    "FROM caom2.Observation AS o JOIN caom2.Plane AS p ON o.obsID = p.obsID "
    f"WHERE INTERSECTS(p.position_bounds, CIRCLE('ICRS', {RA0}, {DEC0}, 0.5)) = 1 "
    "GROUP BY o.collection")

by_label = {e['label']: e for e in log}
n_field = by_label.get('neossat_field_overlap', {}).get('n_rows')
n_target = by_label.get('neossat_target_atlas', {}).get('n_rows')
control = by_label.get('control_field_overlap_all_collections', {})

out = {
    'service': ('CADC (Canadian Astronomy Data Centre) TAP service "argus" '
                '(ivo://cadc.nrc.ca/argus), CAOM-2 schema, sync endpoint'),
    'endpoint': TAP,
    'query_date_utc': '2026-11-13',
    'field': {'centre_ra_deg': RA0, 'centre_dec_deg': DEC0,
              'overlap_circle_radius_deg': 0.5},
    'queries': log,
    'results_summary': {
        'neossat_collection_total_observations':
            (by_label.get('neossat_collection_size', {})
             .get('sample', [{}])[0].get('n') if by_label.get(
                 'neossat_collection_size', {}).get('sample') else None),
        'neossat_overlapping_field': n_field,
        'neossat_targeted_at_3I_ATLAS': n_target,
        'control_all_collections_overlapping_field': control.get('sample'),
    },
    'honest_conclusion': (
        'See results_summary: the NEOSSat collection was queried directly at '
        'CADC (collection size confirms the archive and collection are real '
        'and reachable). NEOSSat is a small NEO/space-debris surveillance '
        'microsatellite whose pointings are driven by its own target list; '
        'whether it ever imaged this field or the comet is answered purely '
        'by the two result counts above -- no relevance is claimed beyond '
        'what the archive returned.'),
}
with open(f'{BASE}/data/neossat_check.json', 'w') as f:
    json.dump(out, f, indent=1)
print('Wrote data/neossat_check.json')
