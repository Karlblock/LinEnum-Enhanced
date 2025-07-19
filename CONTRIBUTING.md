# Contributing to LinEnum-Enhanced 🤝

First off, **thank you** for considering contributing to LinEnum-Enhanced! It's people like you that make this a great tool for the security community.

## 🌟 Ways to Contribute

Everyone has something valuable to offer:

- **🐛 Bug Reports** - Found something broken? Let us know!
- **✨ Feature Ideas** - Have an idea? We'd love to hear it!
- **💻 Code** - From tiny fixes to major features
- **📚 Documentation** - Help others understand and use the tool
- **🧪 Testing** - Try the tool and report your experience
- **🌍 Translations** - Make the tool accessible globally
- **💬 Community Support** - Help others in discussions

## 🚀 Getting Started

### 1. Fork and Clone

```bash
# Fork on GitHub first, then:
git clone https://github.com/YOUR-USERNAME/LinEnum-Enhanced.git
cd LinEnum-Enhanced
```

### 2. Create a Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/issue-description
```

### 3. Make Your Changes

Follow our style guide:
- Use clear, descriptive variable names
- Quote all variables: `"$var"` not `$var`
- Comment complex logic
- Test your changes thoroughly

### 4. Commit Your Changes

```bash
git add .
git commit -m "feat: add amazing new feature

- Detailed description of what changed
- Why this change was needed
- Any breaking changes or notes"
```

We follow [Conventional Commits](https://www.conventionalcommits.org/):
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes
- `refactor:` Code refactoring
- `perf:` Performance improvements
- `test:` Test additions/changes
- `chore:` Maintenance tasks

### 5. Push and Create PR

```bash
git push origin feature/your-feature-name
```

Then create a Pull Request on GitHub!

## 📋 Pull Request Guidelines

### PR Title
Follow the same convention as commits:
```
feat: add JSON output format
fix: correct path traversal in export function
docs: improve usage examples
```

### PR Description Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix (non-breaking change fixing an issue)
- [ ] New feature (non-breaking change adding functionality)
- [ ] Breaking change (fix or feature causing existing functionality to change)
- [ ] Documentation update

## Testing
- [ ] Tested on Ubuntu 20.04
- [ ] Tested on CentOS 8
- [ ] Tested with thorough mode
- [ ] No new security vulnerabilities introduced

## Checklist
- [ ] My code follows the project style
- [ ] I've added comments for complex logic
- [ ] I've updated documentation as needed
- [ ] All variables are properly quoted
- [ ] No sensitive data is logged
```

## 🧪 Testing Guidelines

Before submitting:

1. **Basic Syntax Check**
   ```bash
   bash -n LinEnum.sh
   ```

2. **Run Basic Tests**
   ```bash
   ./LinEnum.sh -h  # Help should work
   ./LinEnum.sh     # Basic run should complete
   ```

3. **Security Tests**
   ```bash
   # Try command injection (should fail safely)
   ./LinEnum.sh -k "test;id"
   
   # Try path traversal (should handle safely)
   ./LinEnum.sh -e "../../../tmp"
   ```

## 🎨 Code Style Guide

### Shell Script Best Practices

1. **Variable Usage**
   ```bash
   # Good
   local file_path="$1"
   if [ -f "$file_path" ]; then
   
   # Bad
   filepath=$1
   if [ -f $filepath ]; then
   ```

2. **Command Substitution**
   ```bash
   # Good
   result=$(command)
   
   # Bad
   result=`command`
   ```

3. **Error Handling**
   ```bash
   # Good
   if ! command; then
     echo "Error: Command failed" >&2
     return 1
   fi
   
   # Bad
   command 2>/dev/null
   ```

## 🤔 Not Sure Where to Start?

Check out these good first issues:
- Issues labeled [`good first issue`](https://github.com/YOUR-USERNAME/LinEnum-Enhanced/labels/good%20first%20issue)
- Issues labeled [`help wanted`](https://github.com/YOUR-USERNAME/LinEnum-Enhanced/labels/help%20wanted)
- Documentation improvements
- Adding tests

## 💬 Communication

- **GitHub Issues** - Bug reports and feature requests
- **GitHub Discussions** - General questions and ideas
- **Pull Request Comments** - Code-specific discussions

## 🎯 Development Philosophy

1. **Security First** - Never introduce vulnerabilities
2. **Backward Compatible** - Don't break existing functionality
3. **User Friendly** - Make it easy to use and understand
4. **Performance Conscious** - Don't make it slower
5. **Community Focused** - Be welcoming and helpful

## 📜 Code of Conduct

Please read our [Code of Conduct](CODE_OF_CONDUCT.md). We're committed to providing a welcoming and inspiring community for all.

## 🙋 Getting Help

- Check existing issues and discussions
- Read the documentation
- Ask in discussions with the `question` tag
- Be patient and respectful

## 🎉 Recognition

All contributors will be added to our [CONTRIBUTORS.md](CONTRIBUTORS.md) file and thanked in release notes!

---

**Remember:** There are no stupid questions, and no contribution is too small. We're all here to learn and improve together!

Thank you for making LinEnum-Enhanced better! 🚀