# RFC 0001: Plugin Architecture Design

- **RFC Number**: 0001
- **Title**: Plugin Architecture Design
- **Author(s)**: LinEnum-Enhanced Community
- **Status**: Draft
- **Type**: Breaking Change
- **Created**: 2024-01-19
- **Updated**: 2024-01-19

## Summary

Transform LinEnum from a monolithic bash script into a modular, extensible system with a plugin architecture. This will allow users to customize enumeration for specific environments, contribute new checks easily, and maintain better code organization.

## Motivation

The current monolithic LinEnum.sh (1350+ lines) has several limitations:

1. **Difficult to extend** - Adding new checks requires modifying the main script
2. **Hard to maintain** - All code in one file makes debugging and testing difficult
3. **No customization** - Users can't disable specific checks or add custom ones
4. **Performance impact** - All checks run regardless of relevance
5. **Community barriers** - Contributing requires understanding the entire codebase

### User Stories

- As a penetration tester, I want to load only network-related plugins so that scans are faster in network-focused engagements
- As a security researcher, I want to write custom plugins for new vulnerability classes without modifying core code
- As a compliance auditor, I want compliance-specific plugins (PCI, HIPAA) that aren't relevant for general users
- As a developer, I want to test individual modules in isolation for better debugging

## Detailed Design

### Architecture Overview

```
LinEnum-Enhanced v2.0 Architecture:

┌─────────────────────────────────────────┐
│              Core Engine                │
├─────────────────────────────────────────┤
│  • Plugin Discovery & Loading           │
│  • Configuration Management             │
│  • Output Formatting & Reporting        │
│  • Error Handling & Logging             │
└─────────────────────────────────────────┘
                    │
    ┌───────────────┼───────────────┐
    ▼               ▼               ▼
┌─────────┐    ┌─────────┐    ┌─────────┐
│ System  │    │ Network │    │  User   │
│ Module  │    │ Module  │    │ Module  │
└─────────┘    └─────────┘    └─────────┘
    │               │               │
┌─────────┐    ┌─────────┐    ┌─────────┐
│  File   │    │Container│    │ Custom  │
│ Module  │    │ Module  │    │ Plugin  │
└─────────┘    └─────────┘    └─────────┘
```

### Plugin Interface

Each plugin must implement this interface:

```bash
#!/bin/bash
# Plugin: example-plugin.sh

# Required metadata
PLUGIN_NAME="Example Plugin"
PLUGIN_VERSION="1.0.0"
PLUGIN_DESCRIPTION="Example enumeration plugin"
PLUGIN_AUTHOR="Community"
PLUGIN_CATEGORY="system"  # system, network, user, file, custom
PLUGIN_DEPENDENCIES=""   # Space-separated list
PLUGIN_PLATFORMS="linux" # linux, unix, all

# Required functions
plugin_check_requirements() {
    # Return 0 if plugin can run, 1 otherwise
    return 0
}

plugin_enumerate() {
    # Main enumeration logic
    # Output should follow standard format
    echo "[+] Example check result"
}

plugin_cleanup() {
    # Clean up any temporary files/processes
    return 0
}
```

### Core Engine Design

```bash
# Core engine: linenum-core.sh

# Plugin management
load_plugin() {
    local plugin_file="$1"
    # Validate plugin format
    # Source plugin file
    # Register plugin functions
}

discover_plugins() {
    # Scan plugin directories
    # Load enabled plugins
    # Resolve dependencies
}

# Execution engine
run_enumeration() {
    local selected_plugins="$1"
    
    for plugin in $selected_plugins; do
        if plugin_check_requirements; then
            echo "[+] Running $PLUGIN_NAME..."
            plugin_enumerate
            plugin_cleanup
        fi
    done
}
```

### Plugin Categories

1. **System Plugins**
   - `system-basic.sh` - OS version, kernel info
   - `system-processes.sh` - Running processes
   - `system-services.sh` - System services

2. **User Plugins**
   - `user-enum.sh` - User enumeration
   - `user-sudo.sh` - Sudo permissions
   - `user-history.sh` - Command history

3. **Network Plugins**
   - `network-config.sh` - Network configuration
   - `network-connections.sh` - Active connections
   - `network-listeners.sh` - Listening services

4. **File Plugins**
   - `file-permissions.sh` - SUID/SGID files
   - `file-writable.sh` - World-writable files
   - `file-interesting.sh` - Interesting files

5. **Container Plugins**
   - `container-docker.sh` - Docker enumeration
   - `container-lxc.sh` - LXC enumeration

### Configuration System

```bash
# linenum.conf
[core]
output_format=text  # text, json, xml
verbosity=normal    # quiet, normal, verbose
export_path=/tmp/linenum-export

[plugins]
enabled=system-basic,user-enum,network-config
disabled=container-docker
plugin_paths=/usr/share/linenum/plugins:/home/user/.linenum/plugins

[system-basic]
include_kernel_version=true
include_os_details=true
```

### API Design

```bash
# New command structure
./linenum.sh [options] [plugins...]

# Examples:
./linenum.sh --all                    # Run all enabled plugins
./linenum.sh system user              # Run specific categories
./linenum.sh --plugin system-basic    # Run specific plugin
./linenum.sh --list-plugins           # List available plugins
./linenum.sh --config custom.conf     # Use custom config
./linenum.sh --output json --export /tmp/  # JSON output with export
```

### Implementation Plan

**Phase 1: Core Infrastructure (4 weeks)**
- Create plugin interface specification
- Implement plugin discovery and loading
- Basic configuration system
- Minimal working example

**Phase 2: Module Conversion (6 weeks)**
- Convert existing functions to plugins
- Maintain backward compatibility wrapper
- Add plugin metadata and documentation
- Testing framework for plugins

**Phase 3: Advanced Features (4 weeks)**
- Dependency resolution
- Plugin configuration
- Error handling improvements
- Performance optimizations

### Backward Compatibility

Maintain a compatibility wrapper:

```bash
# linenum-legacy.sh (wrapper for old behavior)
#!/bin/bash
# Enable all plugins and run with original output format
./linenum.sh --all --format legacy "$@"
```

## Drawbacks

1. **Complexity Increase**
   - More complex codebase
   - Learning curve for contributors
   - Potential for plugin conflicts

2. **Performance Overhead**
   - Plugin loading time
   - Inter-plugin communication
   - Memory usage increase

3. **Breaking Changes**
   - Existing scripts may need updates
   - Changed directory structure
   - Modified output format

4. **Maintenance Burden**
   - Plugin API stability
   - Version compatibility
   - Testing multiple configurations

## Alternatives

### Alternative 1: Configuration-Based Approach
Instead of plugins, use configuration to enable/disable sections.
- **Pros**: Simpler implementation, no breaking changes
- **Cons**: Limited extensibility, still monolithic

### Alternative 2: Language Migration
Rewrite in Python/Go for better modularity.
- **Pros**: Better language features, easier testing
- **Cons**: New dependencies, complete rewrite needed

### Do Nothing
Keep the monolithic structure.
- **Pros**: No breaking changes, simpler
- **Cons**: Continues to limit growth and contribution

## Prior Art

1. **Nmap Scripts** - Lua-based plugin system
2. **Metasploit Modules** - Ruby module system  
3. **Burp Extensions** - Java/Python plugin API
4. **Ansible Modules** - Python plugin architecture

## Unresolved Questions

1. **Plugin Security**: How do we prevent malicious plugins?
2. **Version Compatibility**: How do we handle API changes?
3. **Performance**: What's the acceptable overhead?
4. **Distribution**: How should plugins be distributed/installed?

## Future Possibilities

1. **Plugin Marketplace** - Community plugin repository
2. **Plugin Manager** - Install/update plugins easily
3. **Remote Plugins** - Load plugins from URLs
4. **Binary Plugins** - Support for compiled plugins
5. **Plugin Chaining** - Plugins that depend on other plugin outputs

---

## RFC Metadata

### Stakeholders
- **Champion**: @maintainer
- **Reviewers**: @security-expert, @architecture-team
- **Implementer**: Community volunteer needed

### Timeline
- **Target Quarter**: Q2 2024
- **Estimated Effort**: 14 weeks (3-4 developers)
- **Dependencies**: None (foundational change)

### Related Issues
- [Issue #001: Modular architecture discussion](https://github.com/example/issue/1)
- [Issue #002: Plugin system requirements](https://github.com/example/issue/2)