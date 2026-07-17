# Presentation concern: render the per-severity, per-location detail
# breakdown as collapsible HTML blocks for the GitHub job summary.
#
# Input: raw Trivy JSON report.
# Output: markdown/HTML lines, one per line (use with `jq -r`).
#
# Usage: jq -r -L <scripts_dir> -f render-details.jq trivy-scan-results.json

include "lib/findings";

def icon: {"CRITICAL": "🟣", "HIGH": "🔴", "MEDIUM": "🟠", "LOW": "🟡", "UNKNOWN": "⚪"}[.] // "⚪";

def htmlesc: gsub("&"; "&amp;") | gsub("<"; "&lt;") | gsub(">"; "&gt;");

# Splits a location path into {path, indicator}: the directory portion and
# the trailing file/segment that indicates how the finding was detected
# (e.g. a python dist-info METADATA file, or the vulnerable file itself).
def splitloc:
  ( . / "/" ) as $parts
  | if ($parts | length) > 1
    then {path: ($parts[0:-1] | join("/")), indicator: $parts[-1]}
    else {path: ., indicator: null}
    end;

# Renders one <tr> location header (merged/full-width) followed by one <tr>
# per finding at that location. Expects an array of findings as input.
def renderRows:
  group_by(.Location)[]
  | ( .[0].Location | splitloc ) as $sl
  | "<tr><td colspan=\"5\">📁 <code>\($sl.path | htmlesc)</code>" + (if $sl.indicator then " <sub>(detected via \($sl.indicator | htmlesc))</sub>" else "" end) + "</td></tr>",
    ( .[] | "<tr><td><a href=\"\(.PrimaryURL // "#")\" target=\"_blank\" rel=\"noopener noreferrer\">\(.VulnerabilityID | htmlesc)</a></td><td>\(.PkgName | htmlesc)</td><td>\(.InstalledVersion // "-" | htmlesc)</td><td>\(.FixedVersion // "-" | htmlesc)</td><td>\((.Title // "") | gsub("[\\r\\n]"; " ") | htmlesc)</td></tr>" );

buildFindings
| group_by(.Severity)
| sort_by(.[0].Severity | rank)
| .[]
| ( .[0].Severity ) as $sev
| ( length ) as $count
| ( if ($sev == "CRITICAL" or $sev == "HIGH") then " open" else "" end ) as $open
| ( map(select(.Kind == "vuln")) ) as $vulns
| ( map(select(.Kind == "secret")) ) as $secrets
| "<details\($open)><summary>\($sev | icon) <b>\($sev)</b> (\($count))</summary>",
  "",
  "<table>",
  "<thead><tr><th>Vulnerability</th><th>Package</th><th>Installed</th><th>Fixed</th><th>Title</th></tr></thead>",
  "<tbody>",
  ( $vulns | renderRows ),
  ( $secrets | renderRows ),
  "</tbody>",
  "</table>",
  "",
  "</details>",
  ""
