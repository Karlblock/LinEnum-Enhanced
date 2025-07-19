# Changelog

All notable changes to LinEnum-Enhanced will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-19

### Added
- 🔒 **Security Enhancements**
  - Input validation for keyword parameter to prevent command injection
  - Secure password handling using stdin instead of command line
  - Proper quoting of all variables to prevent path traversal
  - Protection against special characters in file operations

- 📚 **Community Documentation**
  - Comprehensive README with security focus
  - Contributing guidelines for new contributors
  - Code of Conduct for inclusive community
  - Security policy for responsible disclosure
  - Issue templates for better collaboration

- 🧪 **Testing Infrastructure**
  - GitHub Actions workflow for automated testing
  - Syntax checking for shell scripts
  - Security validation tests
  - Multi-OS compatibility testing

### Changed
- Forked from original LinEnum v0.982
- Rebranded as LinEnum-Enhanced with community focus
- Updated all find/grep operations to use safe patterns

### Fixed
- **Critical**: Command injection vulnerability in keyword searches
- **Critical**: Password visible in process list during sudo operations
- **High**: Unquoted variables leading to potential exploitation
- **High**: Path traversal vulnerabilities in export functions

### Security
- All user inputs now validated before use
- Passwords handled securely without process visibility
- File operations protected against malicious paths
- Comprehensive security audit completed

---

## Original LinEnum Changelog

For changes prior to the fork, see the original LinEnum changelog:

### V0.982 (release 07-01-2020)
* Improvements to script execution speed

### V0.981 (release 21-11-2019)
* List permissions on PATH directories
* Added checks for .bak files

[Full original changelog available in the original repository]