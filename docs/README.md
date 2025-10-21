# NixOS Configuration Documentation

Welcome to the documentation for this NixOS configuration! This directory contains comprehensive guides, references, and optimization reports.

---

## 📚 Documentation Index

### Getting Started

- **[Installation Guide](INSTALLATION.md)** - Complete guide for installing on bare metal
- **[Installation Quick Reference](INSTALL_QUICK_REFERENCE.md)** - Fast installation reference
- **[Quick Reference](QUICK_REFERENCE.md)** - Quick commands and common tasks
- **[Configuration Guide](CONFIG_README.md)** - Detailed configuration walkthrough
- **[Disko Setup](DISKO_SETUP.md)** - Disk partitioning and encryption setup

### Configuration System

- **[Profiles Guide](PROFILES_GUIDE.md)** - Understanding and using the profile system
- **[Module Templates](MODULE_TEMPLATES.md)** - Templates for creating new modules
- **[Development Shell](DEVSHELL.md)** - Using the development environment

### Optimization & Audits

- **[Audit Overview](AUDIT_OVERVIEW.md)** - Visual overview of configuration audit
- **[Audit Summary](AUDIT_SUMMARY.md)** - Executive summary of findings
- **[Comprehensive Audit Report](COMPREHENSIVE_AUDIT_REPORT.md)** - Detailed analysis of all 37 issues
- **[Optimization Checklist](OPTIMIZATION_CHECKLIST.md)** - Progress tracking for optimizations
- **[Quick Implementation Guide](QUICK_IMPLEMENTATION_GUIDE.md)** - Step-by-step optimization guide
- **[Phase 1 Summary](PHASE1_IMPLEMENTATION_SUMMARY.md)** - Phase 1 implementation results

---

## 🏗️ Configuration Structure

```
.
├── flake.nix              # Main flake configuration
├── flake-parts/           # Flake-parts modules (packages, overlays, devshells)
├── hosts/                 # Host-specific configurations
│   └── blazar/           # Configuration for 'blazar' host
├── nixos/                 # NixOS system modules
│   └── hardware/         # Hardware-specific configs (CPU, GPU)
├── home/                  # Home-manager user configurations
│   └── dscv/             # User 'dscv' configuration
├── profiles/              # Feature profiles (system, user, features)
│   ├── system/           # System-level profiles (development, multimedia)
│   ├── user/             # User-level profiles (productivity)
│   └── features/         # Optional features (printing, etc.)
├── shared/                # Shared constants and theme definitions
└── docs/                  # Documentation (you are here!)
```

---

## 🚀 Quick Start

### Rebuild System

```bash
# Dry build (test without applying)
sudo nixos-rebuild dry-build --flake .#blazar

# Build and switch
sudo nixos-rebuild switch --flake .#blazar

# Build and test (doesn't set as default)
sudo nixos-rebuild test --flake .#blazar
```

### Update System

```bash
# Update flake inputs
nix flake update

# Rebuild with updates
sudo nixos-rebuild switch --flake .#blazar
```

### Development

```bash
# Enter development shell
nix develop

# Enter NixOS-specific shell
nix develop .#nixos
```

---

## 🎯 Key Features

### Profile System

This configuration uses a modular profile system that allows you to enable/disable feature sets:

- **System Profiles**: Development tools, multimedia creation
- **User Profiles**: Productivity applications
- **Feature Profiles**: Printing, virtualization, etc.

See [Profiles Guide](PROFILES_GUIDE.md) for details.

### Multi-Host Support

The configuration supports multiple hosts through the `hostName` parameter:

- Hardware configs in `nixos/hardware/`
- Host-specific settings in `hosts/${hostName}/`
- Profile configuration in `hosts/${hostName}/profiles.nix`

### Shared Configuration

Common values are centralized in `shared/`:

- `theme.nix` - Dracula color palette and theme settings
- `constants.nix` - User info, system settings, paths

---

## 📖 Additional Resources

### External Documentation

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Language Basics](https://nixos.org/guides/nix-language.html)
- [Niri Compositor](https://github.com/YaLTeR/niri)

### Community

- [NixOS Discourse](https://discourse.nixos.org/)
- [NixOS Reddit](https://www.reddit.com/r/NixOS/)
- [NixOS Wiki](https://nixos.wiki/)

---

## 🔧 Troubleshooting

### Common Issues

1. **Build Errors**: Check `nix flake check` for issues
2. **Module Conflicts**: Review module imports in `flake.nix`
3. **Profile Issues**: Verify `hosts/${hostName}/profiles.nix` syntax

### Getting Help

- Check the documentation files in this directory
- Review the audit reports for known issues
- Consult the NixOS manual and community resources

---

## 📝 Contributing

When adding new features or modules:

1. Follow the existing structure and naming conventions
2. Add documentation headers to new modules
3. Update relevant documentation files
4. Test with `nixos-rebuild dry-build`
5. Update the optimization checklist if applicable

---

## 📊 Configuration Stats

- **NixOS Version**: 24.11
- **System**: x86_64-linux
- **Hardware**: AMD Ryzen 7 5800X + NVIDIA RTX 3080
- **Compositor**: Niri (Wayland)
- **Theme**: Dracula
- **Font**: Maple Mono NerdFont

---

**Last Updated**: 2025-10-21  
**Configuration Version**: Phase 2 Complete

