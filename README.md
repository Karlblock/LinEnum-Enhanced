# LinEnum-Enhanced 🛡️

A **community-first**, security-hardened fork of the popular LinEnum Linux enumeration script. This enhanced version addresses critical security vulnerabilities while maintaining full functionality and adding community-driven improvements.

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Security Hardened](https://img.shields.io/badge/Security-Hardened-green.svg)](SECURITY.md)
[![Community First](https://img.shields.io/badge/Community-First-orange.svg)](CONTRIBUTING.md)
[![PRs Welcome](https://img.shields.io/badge/PRs-Welcome-brightgreen.svg)](CONTRIBUTING.md)

## 🎯 Why LinEnum-Enhanced?

This fork was created to address critical security vulnerabilities in the original LinEnum while building a welcoming, inclusive community around Linux security tooling. We believe security tools should be:

- **Secure by design** - No tool should introduce vulnerabilities
- **Community-driven** - Everyone can contribute and learn
- **Well-documented** - Clear docs help everyone
- **Ethically focused** - For defensive security only

## ✨ Key Improvements

### 🔒 Security Enhancements
- **Command injection prevention** - Input validation for all user parameters
- **Secure password handling** - No passwords visible in process lists
- **Path traversal protection** - All file operations properly quoted
- **Safe variable handling** - Prevents exploitation via special characters

### 🚀 Planned Features
- [ ] Modular architecture for easier contributions
- [ ] JSON/XML output formats
- [ ] Performance optimizations
- [ ] Plugin system for custom checks
- [ ] Automated testing suite
- [ ] Multi-language support

## 📖 Usage

```bash
# Basic enumeration
./LinEnum.sh

# Thorough scan with report
./LinEnum.sh -t -r report_name

# Search for keywords (safely!)
./LinEnum.sh -k keyword -e /tmp/export/

# All options
./LinEnum.sh -s -k keyword -r report -e /tmp/ -t
```

### Options
- `-k` Keyword search (alphanumeric, dots, underscores, hyphens only)
- `-e` Export location
- `-t` Thorough tests (slow but comprehensive)
- `-s` Sudo password check (CTF use only - still insecure!)
- `-r` Report name
- `-h` Help

## 🤝 Community First

We're building an inclusive community around Linux security tooling. Whether you're a:
- 🎓 Student learning security
- 🔍 Researcher finding vulnerabilities
- 💻 Developer improving code
- 📚 Writer enhancing documentation
- 🌍 Translator localizing content

**You belong here!** Check our [Contributing Guide](CONTRIBUTING.md) to get started.

## 🛡️ Security

This tool is for **defensive security purposes only**:
- ✅ Authorized penetration testing
- ✅ CTF competitions
- ✅ Personal system auditing
- ✅ Security education

Found a vulnerability? Please see our [Security Policy](SECURITY.md) for responsible disclosure.

## 📊 Improvements Over Original

| Feature | Original | Enhanced |
|---------|----------|----------|
| Command Injection | ❌ Vulnerable | ✅ Protected |
| Password Handling | ❌ Process visible | ✅ Secure stdin |
| Path Variables | ❌ Unquoted | ✅ Properly quoted |
| Input Validation | ❌ None | ✅ Strict validation |
| Community Focus | ➖ Limited | ✅ First priority |

## 🚦 Getting Started

1. **Clone the repository**
   ```bash
   git clone https://github.com/YOUR-USERNAME/LinEnum-Enhanced.git
   cd LinEnum-Enhanced
   chmod +x LinEnum.sh
   ```

2. **Run basic enumeration**
   ```bash
   ./LinEnum.sh
   ```

3. **Join the community**
   - Star the repository
   - Check open issues
   - Read contribution guidelines
   - Make your first PR!

## 📈 Roadmap

See our [public roadmap](https://github.com/YOUR-USERNAME/LinEnum-Enhanced/projects/1) for planned features and improvements.

### Near Term (v1.0)
- Complete security audit
- Automated testing
- Performance optimizations
- Better documentation

### Long Term (v2.0)
- Modular architecture
- Plugin system
- GUI interface option
- API for integration

## 👥 Contributors

We appreciate all contributions! See our [Contributors List](CONTRIBUTORS.md).

## 📜 License

This project maintains the GPL v3 license from the original LinEnum. See [LICENSE](LICENSE) for details.

## 🙏 Acknowledgments

- Original LinEnum by @rebootuser
- Security improvements inspired by community feedback
- All our amazing contributors

---

<p align="center">
  Made with ❤️ by the security community, for the security community
</p>

<p align="center">
  <a href="CONTRIBUTING.md">Contribute</a> •
  <a href="https://github.com/YOUR-USERNAME/LinEnum-Enhanced/issues">Report Bug</a> •
  <a href="https://github.com/YOUR-USERNAME/LinEnum-Enhanced/discussions">Discussions</a>
</p># LinEnum-Enhanced
# LinEnum-Enhanced
