# Trivy Image Scanner Action

A composite GitHub action that scans Docker images for vulnerabilities using [Trivy](https://github.com/aquasecurity/trivy) and publishes the results to GitHub Security tab.

## Features

- 🛡️ Scan Docker images for vulnerabilities using Trivy
- 📊 Support multiple output formats (SARIF, JSON, Table, etc.)
- 🔍 Configurable severity levels and filtering
- 📋 Automatic upload to GitHub Security tab when using SARIF format
- ⚡ Fast and efficient scanning with customizable timeout
- 🎯 Easy integration with existing CI/CD pipelines

## Usage

### Basic Usage

```yaml
name: Vulnerability Scan
on: [push, pull_request]

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Scan image with Trivy
        uses: IQGeo/devops-engineering-ci-public-trivy-scan-action@main
        with:
          image: 'nginx:latest'
```

### Advanced Usage

```yaml
name: Advanced Vulnerability Scan
on: [push, pull_request]

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Build Docker image
        run: docker build -t myapp:latest .

      - name: Scan custom image with Trivy
        uses: IQGeo/devops-engineering-ci-public-trivy-scan-action@main
        with:
          image: 'myapp:latest'
          format: 'sarif'
          output: 'reports/trivy-results.sarif'
          severity: 'HIGH,CRITICAL'
          exit-code: '1'
          ignore-unfixed: 'true'
          timeout: '10m0s'

      - name: Upload scan results as artifact
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: trivy-results
          path: reports/trivy-results.sarif
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `image` | Docker image to scan (e.g., `nginx:latest` or `registry.com/image:tag`) | ✅ | - |
| `format` | Output format (`table`, `json`, `sarif`, `cyclonedx`, `spdx`, `spdx-json`, `github`) | ❌ | `sarif` |
| `output` | Output file path for scan results | ❌ | `trivy-results.sarif` |
| `severity` | Severities to display (`UNKNOWN`, `LOW`, `MEDIUM`, `HIGH`, `CRITICAL`) | ❌ | `UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL` |
| `exit-code` | Exit code when vulnerabilities are found | ❌ | `0` |
| `ignore-unfixed` | Display only fixed vulnerabilities (`true`/`false`) | ❌ | `false` |
| `timeout` | Timeout for image scan | ❌ | `5m0s` |

## Outputs

| Output | Description |
|--------|-------------|
| `results` | Path to the scan results file |

## Examples

### Scan and fail on high/critical vulnerabilities

```yaml
- name: Security scan with failure on critical issues
  uses: IQGeo/devops-engineering-ci-public-trivy-scan-action@main
  with:
    image: 'myapp:${{ github.sha }}'
    severity: 'HIGH,CRITICAL'
    exit-code: '1'
```

### Generate JSON report

```yaml
- name: Generate JSON vulnerability report
  uses: IQGeo/devops-engineering-ci-public-trivy-scan-action@main
  with:
    image: 'myapp:latest'
    format: 'json'
    output: 'vulnerability-report.json'
```

### Scan with custom timeout and ignore unfixed

```yaml
- name: Extended scan ignoring unfixed vulnerabilities
  uses: IQGeo/devops-engineering-ci-public-trivy-scan-action@main
  with:
    image: 'large-image:latest'
    timeout: '15m0s'
    ignore-unfixed: 'true'
```

## Security Integration

When using the default SARIF format, scan results are automatically uploaded to GitHub's Security tab, allowing you to:

- View vulnerabilities in the GitHub Security dashboard
- Track vulnerability trends over time
- Integrate with GitHub's security policies
- Receive security alerts and notifications

## Supported Image Sources

This action can scan images from various sources:

- Docker Hub: `nginx:latest`, `ubuntu:20.04`
- GitHub Container Registry: `ghcr.io/owner/image:tag`
- Amazon ECR: `123456789.dkr.ecr.region.amazonaws.com/image:tag`
- Google Container Registry: `gcr.io/project/image:tag`
- Azure Container Registry: `registry.azurecr.io/image:tag`
- Private registries: `private-registry.com/image:tag`

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
