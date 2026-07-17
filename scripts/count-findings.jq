# Aggregation concern: how many findings, in total and by severity.
#
# Input: raw Trivy JSON report.
# Output (compact JSON, one object):
#   { "total": <int>, "rows": [ { "severity": "HIGH", "count": 5 }, ... ] }
# "rows" only contains severities that actually have findings, ordered by
# rank (CRITICAL, HIGH, MEDIUM, LOW, UNKNOWN, then anything else).
#
# Usage: jq -c -L <scripts_dir> -f count-findings.jq trivy-scan-results.json

include "lib/findings";

buildFindings as $all
| ($all | length) as $total
| ($all | group_by(.Severity) | sort_by(.[0].Severity | rank)) as $bySev
| {
    total: $total,
    rows: [ $bySev[] | { severity: .[0].Severity, count: length } ]
  }
