# Security Policy 🔐

## Supported Versions

We take security seriously and actively maintain the following versions:

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability 🚨

We appreciate your help in making LinEnum-Enhanced secure for everyone. If you discover a security vulnerability, please follow these responsible disclosure guidelines:

### DO ✅

1. **Email us privately** at [SECURITY-EMAIL]
2. **Include details**:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)
3. **Allow reasonable time** for us to respond and fix
4. **Work with us** to understand and resolve the issue

### DON'T ❌

1. **Don't** create public GitHub issues for security vulnerabilities
2. **Don't** exploit the vulnerability beyond proof of concept
3. **Don't** disclose publicly before we've had time to fix it

## Our Commitment 🤝

When you report a security issue, we commit to:

- **Acknowledge** your report within 48 hours
- **Provide updates** on our progress
- **Credit you** (unless you prefer to remain anonymous) when we fix the issue
- **Notify you** when the fix is released

## Disclosure Timeline ⏰

1. **Day 0**: You report the vulnerability
2. **Day 0-2**: We acknowledge receipt
3. **Day 0-30**: We work on a fix
4. **Day 30-45**: We release the fix
5. **Day 45+**: Public disclosure (coordinated with you)

## Security Best Practices 🛡️

When using LinEnum-Enhanced:

### DO ✅
- Only run on systems you own or have permission to test
- Review the script before running in production
- Use in isolated environments when possible
- Keep your version updated

### DON'T ❌
- Run with elevated privileges unless necessary
- Use in production without understanding the impact
- Modify security checks without understanding implications
- Use for malicious purposes

## Known Security Improvements 🔒

This fork includes security enhancements over the original:

1. **Input Validation**: All user inputs are validated
2. **Command Injection Prevention**: Keywords are sanitized
3. **Secure Password Handling**: Passwords not visible in process list
4. **Path Traversal Protection**: All paths properly quoted

## Security Changelog 📝

### Version 1.0 (Enhanced)
- Fixed command injection in keyword searches
- Secured password handling for sudo checks
- Protected against path traversal attacks
- Added input validation for all parameters

## Bug Bounty 💰

While we don't currently offer monetary rewards, we do offer:

- Public acknowledgment in our Hall of Fame
- A special "Security Researcher" badge/role
- Eternal gratitude from the community
- Recommendation letters for your contributions

## Hall of Fame 🏆

We thank the following security researchers:

- [Your name could be here!]

## Contact 📧

For security issues: [SECURITY-EMAIL]
For general issues: Use GitHub Issues

---

Remember: **Security is everyone's responsibility**. Thank you for helping keep LinEnum-Enhanced secure! 🙏