#!/usr/bin/env bash
# Orchestrates rendering of the Trivy job summary from the JSON report.
#
# Reads from env:
#   REPORT             path to the Trivy JSON report (default: trivy-scan-results.json)
#   IMAGE               the scanned image reference, for the summary header
#   SEVERITY_THRESHOLD  the configured severity list, for the summary header
#
# Writes the rendered markdown/HTML to stdout. Caller is expected to
# redirect this into $GITHUB_STEP_SUMMARY.
set -euo pipefail

report="${REPORT:-trivy-scan-results.json}"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "## 🛡️ Trivy vulnerability scan"
echo ""
echo "**Image:** \`${IMAGE:-}\`"
echo ""
echo "**Severities scanned:** \`${SEVERITY_THRESHOLD:-}\`"
echo ""

counts=$(jq -c -L "$script_dir" -f "$script_dir/count-findings.jq" "$report")
total=$(jq -r '.total' <<<"$counts")

if [ "$total" = "0" ]; then
  echo "✅ No vulnerabilities found for the selected severity thresholds."
  exit 0
fi

echo "### Summary"
echo ""
echo "| Severity | Count |"
echo "| --- | ---: |"
jq -r '.rows[] | "| \(.severity) | \(.count) |"' <<<"$counts"
echo ""

jq -r -L "$script_dir" -f "$script_dir/render-details.jq" "$report"
