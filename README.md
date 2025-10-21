# NixOS Configuration
## Flake-Parts + Niri + NVIDIA + AMD Ryzen 7 5800X

A modern, modular NixOS configuration featuring:
- **Flake Framework**: flake-parts for modular organization
- **Compositor**: Niri (scrollable-tiling Wayland compositor)
- **GPU**: NVIDIA RTX 3080 with full Wayland support
- **CPU**: AMD Ryzen 7 5800X with optimizations
- **Theme**: Dracula color scheme throughout
- **Profile System**: Modular feature toggles for easy customization

---

## 📚 Documentation

**All documentation has been moved to the [`docs/`](docs/) directory.**

### Quick Links

- **[Documentation Index](docs/README.md)** - Start here! Complete documentation overview
- **[Quick Reference](docs/QUICK_REFERENCE.md)** - Essential commands and common tasks
- **[Configuration Guide](docs/CONFIG_README.md)** - Detailed configuration walkthrough
- **[Profiles Guide](docs/PROFILES_GUIDE.md)** - Understanding the profile system
- **[Optimization Reports](docs/AUDIT_OVERVIEW.md)** - Configuration audit and optimization results

---

## 🎯 Quick Start

### Prerequisites
- NixOS installation media or existing NixOS system
- AMD Ryzen 7 5800X CPU (or similar)
- NVIDIA GPU
- Basic familiarity with NixOS and Nix flakes

### Clone and Build

```bash
# Clone the repository
git clone https://github.com/dscv103/blazar-nixos.git
cd blazar-nixos

# Test the configuration (dry build)
sudo nixos-rebuild dry-build --flake .#blazar

# Build and switch
sudo nixos-rebuild switch --flake .#blazar
```

### For New Hosts

To use this configuration on a different machine:

1. Copy `hosts/blazar/` to `hosts/your-hostname/`
2. Update hardware configuration
3. Adjust profiles in `hosts/your-hostname/profiles.nix`
4. Update `flake.nix` to add your host configuration

---

## 🏗️ Architecture Overview

### Directory Structure
```
.
├── flake.nix              # Main flake configuration
├── flake-parts/           # Flake-parts modules (packages, overlays, devshells)
├── hosts/                 # Host-specific configurations
│   └── blazar/           # Configuration for 'blazar' host
├── nixos/                 # NixOS system modules
│   ├── hardware/         # Hardware-specific configs (CPU, GPU)
│   ├── desktop.nix       # Niri compositor + XDG portals
│   ├── sddm.nix          # Display manager
│   ├── boot.nix          # Bootloader
│   ├── networking.nix    # Network configuration
│   ├── locale.nix        # Locale and timezone
│   ├── users.nix         # User accounts
│   ├── audio.nix         # PipeWire audio
│   ├── packages.nix      # System packages
│   └── nix-settings.nix  # Nix daemon settings
├── home/                  # Home-manager user configurations
│   └── dscv/             # User 'dscv' configuration
│       ├── home.nix      # Base home-manager config
│       ├── fonts.nix     # Centralized font configuration
│       ├── theme.nix     # Dracula theme
│       ├── niri.nix      # Niri user config
│       ├── ghostty.nix   # Terminal emulator
│       ├── vscode.nix    # VSCode configuration
│       ├── zed.nix       # Zed editor
│       └── ...           # Other application configs
├── profiles/              # Feature profiles (modular system)
│   ├── system/           # System-level profiles (development, multimedia)
│   ├── user/             # User-level profiles (productivity)
│   └── features/         # Optional features (printing, etc.)
├── shared/                # Shared constants and theme definitions
│   ├── theme.nix         # Dracula color palette
│   └── constants.nix     # Common values
└── docs/                  # Documentation
```

### Key Features

#### Profile System
Modular feature toggles for easy customization:
- **System Profiles**: Development tools, multimedia creation
- **User Profiles**: Productivity applications
- **Feature Profiles**: Printing, virtualization, etc.

See [Profiles Guide](docs/PROFILES_GUIDE.md) for details.

#### Multi-Host Support
- Hardware configs in `nixos/hardware/`
- Host-specific settings in `hosts/${hostName}/`
- Profile configuration in `hosts/${hostName}/profiles.nix`

#### Shared Configuration
Centralized constants in `shared/`:
- `theme.nix` - Dracula color palette and theme settings
- `constants.nix` - User info, system settings, paths

#### Optimized Performance
- Phase 1 optimizations complete (8-13s faster boot, 300-500MB less memory)
- Phase 2 structural improvements complete
- Type-safe configuration with validation

---

## 🚀 Essential Commands

### System Management

```bash
# Rebuild system
sudo nixos-rebuild switch --flake .#blazar

# Test configuration (dry build)
sudo nixos-rebuild dry-build --flake .#blazar

# Update flake inputs
nix flake update

# Enter development shell
nix develop
```

### Verification

```bash
# Check boot time
systemd-analyze

# Check memory usage
free -h

# Verify Wayland session
echo $XDG_SESSION_TYPE  # Should output: wayland

# Check NVIDIA driver
nvidia-smi
```

See [Quick Reference](docs/QUICK_REFERENCE.md) for more commands.



---

## 📖 Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Niri Compositor](https://github.com/YaLTeR/niri)
- [Niri Flake](https://github.com/sodiboo/niri-flake)
- [NixOS Discourse](https://discourse.nixos.org/)

---

## 📊 Configuration Stats

- **NixOS Version**: 24.11
- **System**: x86_64-linux
- **Hardware**: AMD Ryzen 7 5800X + NVIDIA RTX 3080
- **Compositor**: Niri (Wayland)
- **Theme**: Dracula
- **Font**: Maple Mono NerdFont
- **Optimizations**: Phase 1 & 2 Complete

---

## 🙏 Acknowledgments

- **NixOS Community** - For the amazing ecosystem
- **Niri Project** - For the excellent Wayland compositor
- **sodiboo** - For the niri-flake integration
- **Flake-parts** - For the modular flake framework

---

**For complete documentation, see the [`docs/`](docs/) directory.**

