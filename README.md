# devops-engineering-ci-public-trivy-scan-action

Public repo holding a reusable composite action, called from product pipelines, that scans built container images with Trivy for vulnerabilities.

## What it does

The image is scanned once and the results are surfaced in three ways:

1. **Job summary (readable in GitHub)** – a Markdown report is written to the workflow run's summary page: per-severity counts plus a collapsible table with **clickable CVE links**, affected package, installed version and fixed version. Results can be reviewed and acted on directly in GitHub without downloading the artifact or opening a third-party tool.
2. **SARIF upload to the Security tab (optional)** – when `upload_to_security_tab` is `true`, results are uploaded via `github/codeql-action/upload-sarif` so they appear as tracked code scanning alerts. This requires **GitHub Advanced Security** (GHAS); it is disabled by default because the upload fails on repos without GHAS.
3. **Artifacts** – both the raw JSON (`trivy-scan-results.json`) and SARIF (`trivy-scan-results.sarif`) reports are uploaded as the `trivy-report` artifact for use in third-party tooling.

> **Note on the summary vs. the Security tab:** the Markdown summary gives per-run, click-through readable results with remediation info and needs no GHAS. It does **not** provide SARIF's cross-run alert lifecycle (new/fixed/dismissed tracking) — that is a GHAS-only capability available through the Security tab.

## Requirements

The job summary is generated with `jq`. The action includes a guard step that verifies `jq` is present and installs it via the runner's package manager (`apt-get`, `apk`, `yum`, `dnf` or `brew`) if it is missing, so it works on GitHub-hosted and most self-hosted runners without extra setup.

## Inputs

| Name | Required | Default | Description |
| --- | --- | --- | --- |
| `image` | yes | – | Container image to scan |
| `severity_threshold` | no | `MEDIUM,CRITICAL,HIGH` | Comma-separated Trivy severities to report |
| `upload_to_security_tab` | no | `false` | Upload SARIF to the GitHub Security tab. Requires GitHub Advanced Security; leave `false` if GHAS is not enabled |
| `registry_username` | yes | – | ACR registry username |
| `registry_password` | yes | – | ACR registry password |
| `token` | yes | – | GitHub token used by Trivy for authentication |

## Usage

```yaml
jobs:
  scan:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      security-events: write   # only needed if upload_to_security_tab is true
    steps:
      - name: Trivy scan
        uses: <org>/devops-engineering-ci-public-trivy-scan-action@main
        with:
          image: myregistry.azurecr.io/my-app:latest
          registry_username: ${{ secrets.ACR_USERNAME }}
          registry_password: ${{ secrets.ACR_PASSWORD }}
          token: ${{ secrets.GITHUB_TOKEN }}
          # upload_to_security_tab: 'true'   # enable only if your org has GitHub Advanced Security
```

After the job runs, open the workflow run in GitHub and scroll to the **Summary** section to read the vulnerability table.
