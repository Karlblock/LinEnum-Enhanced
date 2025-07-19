# Development Guide 🛠️

Welcome to LinEnum-Enhanced development! This guide will help you get started contributing to the project.

## 📋 Table of Contents

- [Quick Start](#quick-start)
- [Development Environment](#development-environment)
- [Architecture Overview](#architecture-overview)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Documentation](#documentation)
- [Release Process](#release-process)

## 🚀 Quick Start

### 1. Fork and Clone
```bash
git clone https://github.com/YOUR-USERNAME/LinEnum-Enhanced.git
cd LinEnum-Enhanced
```

### 2. Set Up Development Environment
```bash
# Install dependencies (for testing/linting)
sudo apt update
sudo apt install shellcheck bats-core

# Make script executable
chmod +x LinEnum.sh

# Run basic tests
bash -n LinEnum.sh  # Syntax check
./LinEnum.sh -h     # Help test
```

### 3. Create Feature Branch
```bash
git checkout -b feature/your-feature-name
```

### 4. Make Changes and Test
```bash
# Edit files
vim LinEnum.sh

# Test your changes
./LinEnum.sh --test-mode  # Future: test mode
bash -n LinEnum.sh        # Syntax check
```

### 5. Submit Pull Request
```bash
git add .
git commit -m "feat: add amazing feature"
git push origin feature/your-feature-name
# Create PR on GitHub
```

## 🏗️ Development Environment

### Required Tools
```bash
# Basic tools
bash >= 4.0
git >= 2.0

# Development tools (optional but recommended)
shellcheck      # Shell script linting
bats-core       # Testing framework
ripgrep         # Fast searching
```

### IDE Setup

#### VS Code
```json
{
    "bashIde.shellcheckPath": "/usr/bin/shellcheck",
    "files.associations": {
        "*.sh": "shellscript"
    },
    "editor.insertSpaces": true,
    "editor.tabSize": 2
}
```

#### Vim
```vim
" .vimrc additions
autocmd FileType sh setlocal expandtab tabstop=2 shiftwidth=2
let g:syntastic_sh_checkers = ['shellcheck']
```

## 🏛️ Architecture Overview

### Current Architecture (v1.0)
```
LinEnum.sh (Monolithic)
├── Command line parsing
├── Configuration functions
├── Enumeration functions
│   ├── system_info()
│   ├── user_info()
│   ├── networking_info()
│   └── ...
└── Output formatting
```

### Future Architecture (v2.0)
```
Core Engine
├── Plugin System
├── Configuration Manager
├── Output Formatter
└── Error Handler

Plugins/
├── system/
├── network/
├── user/
└── custom/
```

### Key Components

#### 1. Core Functions
- `header()` - Display banner
- `debug_info()` - Show configuration
- `call_each()` - Main orchestrator

#### 2. Enumeration Modules
- `system_info()` - OS/kernel information
- `user_info()` - User enumeration
- `networking_info()` - Network configuration
- `services_info()` - Running services
- `interesting_files()` - File permissions

#### 3. Output System
- Color-coded output using ANSI escape codes
- Export functionality for files
- Report generation

## 📝 Coding Standards

### Shell Scripting Best Practices

#### 1. Variable Usage
```bash
# Good: Always quote variables
local file_path="$1"
if [ -f "$file_path" ]; then
    echo "File exists: $file_path"
fi

# Bad: Unquoted variables
local filepath=$1
if [ -f $filepath ]; then
    echo "File exists: $filepath"
fi
```

#### 2. Command Substitution
```bash
# Good: Use $() instead of backticks
result=$(command arg1 arg2)

# Bad: Backticks are deprecated
result=`command arg1 arg2`
```

#### 3. Error Handling
```bash
# Good: Check command success
if ! command_that_might_fail; then
    echo "Error: Command failed" >&2
    return 1
fi

# Bad: Ignoring errors
command_that_might_fail 2>/dev/null
```

#### 4. Function Design
```bash
# Good: Clear function with error handling
enumerate_users() {
    local output_file="$1"
    
    if [ -z "$output_file" ]; then
        echo "Error: Output file required" >&2
        return 1
    fi
    
    if ! getent passwd > "$output_file" 2>/dev/null; then
        echo "Warning: Could not enumerate users" >&2
        return 1
    fi
    
    return 0
}
```

### Code Organization

#### 1. File Structure
```bash
#!/bin/bash
# Brief description of the script

# Global variables
readonly SCRIPT_VERSION="1.0.0"
readonly DEFAULT_CONFIG="/etc/linenum.conf"

# Helper functions
helper_function() {
    # Implementation
}

# Main functions
main_function() {
    # Implementation
}

# Main execution
main "$@"
```

#### 2. Function Naming
- Use descriptive names: `enumerate_network_interfaces()` not `net_enum()`
- Use verb_noun pattern: `check_permissions()`, `list_processes()`
- Prefix private functions: `_internal_helper()`

#### 3. Comments
```bash
# Function: enumerate_system_info
# Purpose: Gather basic system information
# Arguments: None
# Returns: 0 on success, 1 on failure
enumerate_system_info() {
    # Get kernel information
    local kernel_info
    kernel_info=$(uname -a 2>/dev/null)
    
    # Display results
    if [ -n "$kernel_info" ]; then
        echo "[+] Kernel: $kernel_info"
    fi
}
```

### Security Considerations

#### 1. Input Validation
```bash
validate_keyword() {
    local keyword="$1"
    
    # Only allow alphanumeric, dots, underscores, hyphens
    if [[ "$keyword" =~ [^a-zA-Z0-9._-] ]]; then
        echo "Error: Invalid characters in keyword" >&2
        return 1
    fi
    
    return 0
}
```

#### 2. Safe Command Execution
```bash
# Good: Proper quoting and validation
search_files() {
    local keyword="$1"
    local search_path="$2"
    
    # Validate inputs
    validate_keyword "$keyword" || return 1
    
    # Use proper quoting
    find "$search_path" -name "*.conf" -type f -exec grep -Hn -- "$keyword" {} \;
}
```

## 🧪 Testing

### Test Categories

#### 1. Syntax Tests
```bash
# Check script syntax
bash -n LinEnum.sh

# Run shellcheck
shellcheck LinEnum.sh
```

#### 2. Functionality Tests
```bash
# Test help function
./LinEnum.sh -h

# Test basic execution
timeout 30s ./LinEnum.sh

# Test with invalid input
./LinEnum.sh -k "invalid;command"
```

#### 3. Security Tests
```bash
# Test command injection prevention
./LinEnum.sh -k 'test;id' 2>&1 | grep -q "invalid characters"

# Test path traversal protection
./LinEnum.sh -e "../../../etc" 2>&1 | grep -q "safe"
```

### Writing Tests

#### Test Structure
```bash
#!/usr/bin/env bats

setup() {
    # Setup for each test
    export TEST_DIR=$(mktemp -d)
}

teardown() {
    # Cleanup after each test
    rm -rf "$TEST_DIR"
}

@test "help function works" {
    run ./LinEnum.sh -h
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Local Linux Enumeration" ]]
}

@test "keyword validation prevents injection" {
    run ./LinEnum.sh -k "test;id"
    [ "$status" -eq 1 ]
    [[ "$output" =~ "invalid characters" ]]
}
```

### Continuous Integration

Tests run automatically on:
- Every pull request
- Pushes to main/develop branches
- Nightly builds

## 📚 Documentation

### Code Documentation
```bash
# Function documentation template
# Function: function_name
# Purpose: What this function does
# Arguments:
#   $1 - First argument description
#   $2 - Second argument description
# Returns:
#   0 - Success
#   1 - Error condition 1
#   2 - Error condition 2
# Example:
#   function_name "arg1" "arg2"
function_name() {
    # Implementation
}
```

### User Documentation
- Update README.md for user-facing changes
- Add examples for new features
- Update man page (future)
- Keep CHANGELOG.md current

### API Documentation
```bash
# For future plugin API
# Plugin Interface: enumerate
# Purpose: Main enumeration function for plugin
# Expected Variables:
#   PLUGIN_NAME - Plugin display name
#   PLUGIN_VERSION - Plugin version
# Expected Functions:
#   plugin_check_requirements() - Verify plugin can run
#   plugin_enumerate() - Main enumeration logic
#   plugin_cleanup() - Clean up resources
```

## 🚀 Release Process

### Version Numbering
We follow [Semantic Versioning](https://semver.org/):
- **MAJOR.MINOR.PATCH** (e.g., 2.1.3)
- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes

### Release Checklist

#### Pre-Release
- [ ] All tests passing
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Version number updated
- [ ] Security review completed

#### Release
- [ ] Create release branch
- [ ] Final testing on multiple platforms
- [ ] Tag release in git
- [ ] Create GitHub release
- [ ] Update website/documentation

#### Post-Release
- [ ] Announce in community channels
- [ ] Monitor for issues
- [ ] Plan next milestone

### Branch Strategy

```
main           ←---- stable releases
  ↑
develop        ←---- integration branch
  ↑
feature/*      ←---- feature development
hotfix/*       ←---- urgent fixes
```

## 🤝 Community Guidelines

### Communication
- Be respectful and inclusive
- Ask questions in appropriate channels
- Share knowledge and help others
- Follow our Code of Conduct

### Contribution Tips
- Start with "good first issue" labels
- Read existing code to understand patterns
- Write tests for new functionality
- Update documentation for changes
- Be patient with the review process

### Getting Help
- GitHub Discussions for general questions
- Discord for real-time help
- Code of Conduct for community issues
- Security Policy for vulnerability reports

---

**Happy coding! Let's build something amazing together! 🚀**