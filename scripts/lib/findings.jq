# Shared data model for Trivy job-summary rendering.
#
# Normalizes the raw Trivy JSON report into a flat list of "findings" that
# unifies package vulnerabilities and detected secrets under one shape, so
# downstream consumers (counting, presentation, ...) don't need to know about
# the two different source shapes.
#
# Included by count-findings.jq and render-details.jq via:
#   include "lib/findings";

# Severity sort order, shared by both counting and presentation so severities
# are always ordered the same way everywhere.
def rank: {"CRITICAL": 0, "HIGH": 1, "MEDIUM": 2, "LOW": 3, "UNKNOWN": 4}[.] // 5;

# Builds the unified findings array from a raw Trivy JSON report (`.`).
# Each finding has: Severity, Location, Kind ("vuln" | "secret"),
# VulnerabilityID, PkgName, InstalledVersion, FixedVersion, PrimaryURL, Title.
def buildFindings:
  [ .Results[]? as $r |
    ( ($r.Vulnerabilities // [])[] | . + {
        Location: (.PkgPath // $r.Target // "-"),
        Kind: "vuln"
      } ),
    ( ($r.Secrets // [])[] | . + {
        VulnerabilityID: (.RuleID // "secret"),
        PkgName: "-",
        InstalledVersion: "-",
        FixedVersion: "-",
        PrimaryURL: null,
        Location: ($r.Target // "-"),
        Kind: "secret"
      } )
  ];
