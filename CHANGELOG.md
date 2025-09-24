# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-09-24

### Added
- Initial release of Trivy Image Scanner composite action
- Support for multiple output formats (SARIF, JSON, table, cyclonedx, spdx, spdx-json, github)
- Configurable severity filtering (UNKNOWN, LOW, MEDIUM, HIGH, CRITICAL)
- Automatic upload to GitHub Security tab for SARIF format
- Customizable timeout and ignore unfixed vulnerabilities options
- Comprehensive documentation with usage examples
- Test workflow for validating action functionality
- Example workflows for common use cases (basic CI/CD, strict security)
- MIT License

### Features
- 🛡️ Scan Docker images for vulnerabilities using Trivy
- 📊 Support multiple output formats
- 🔍 Configurable severity levels and filtering
- 📋 Automatic upload to GitHub Security tab
- ⚡ Fast and efficient scanning with customizable timeout
- 🎯 Easy integration with existing CI/CD pipelines

### Documentation
- Complete README with usage examples
- Example workflows for different scenarios
- Comprehensive input/output documentation
- Contributing guidelines