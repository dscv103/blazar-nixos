# Blazar NixOS Configuration

A complete NixOS configuration using flake-parts, niri compositor, NVIDIA drivers, and AMD Ryzen 7 5800X optimizations.

## System Specifications

- **Hostname**: blazar
- **CPU**: AMD Ryzen 7 5800X
- **GPU**: NVIDIA (with Wayland support)
- **Compositor**: Niri (scrollable-tiling Wayland compositor)
- **NixOS Version**: unstable
- **User**: dscv

## Features

- ✅ **Flake-based configuration** with flake-parts for modular organization
- ✅ **Flat import pattern** - all modules imported directly in flake.nix
- ✅ **AMD CPU optimizations** - microcode updates, P-State driver, KVM support
- ✅ **NVIDIA Wayland support** - full driver configuration with proper environment variables
- ✅ **Niri compositor** - modern scrollable-tiling Wayland compositor
- ✅ **PipeWire audio** - modern audio server with PulseAudio compatibility
- ✅ **Home Manager integration** - declarative user environment management
- ✅ **Binary caching** - niri.cachix.org for faster builds

## Directory Structure

```
NixOS/
├── flake.nix                    # Main flake entry point
├── flake.lock                   # Lock file (auto-generated)
│
├── flake-parts/                 # Flake-parts modules
│   ├── packages.nix             # Custom package definitions
│   ├── overlays.nix             # Nixpkgs overlays
│   └── devshells.nix            # Development environments
│
├── nixos/                       # NixOS system modules
│   ├── hardware.nix             # AMD Ryzen 7 5800X configuration
│   ├── nvidia.nix               # NVIDIA drivers + Wayland
│   ├── desktop.nix              # Niri + XDG portals + greetd
│   ├── boot.nix                 # Bootloader configuration
│   ├── networking.nix           # Network configuration
│   ├── locale.nix               # Locale, timezone, console
│   ├── users.nix                # User accounts
│   ├── audio.nix                # PipeWire audio
│   ├── packages.nix             # System-wide packages
│   └── nix-settings.nix         # Nix daemon settings
│
├── hosts/
│   └── blazar/
│       ├── configuration.nix    # Host-specific settings
│       └── hardware-configuration.nix  # Hardware scan (PLACEHOLDER)
│
└── home/
    └── dscv/
        ├── home.nix             # Home-manager base
        ├── niri.nix             # Niri user configuration
        ├── shell.nix            # Bash configuration
        ├── git.nix              # Git configuration
        └── packages.nix         # User packages
```

## Installation Steps

### 1. Generate Hardware Configuration

**IMPORTANT**: The current `hardware-configuration.nix` is a placeholder. You MUST generate the actual hardware configuration on your target system:

```bash
sudo nixos-generate-config --show-hardware-config > hosts/blazar/hardware-configuration.nix
```

This will detect your:
- File systems (/, /boot, swap)
- Disk UUIDs
- Hardware-specific kernel modules
- Boot configuration

### 2. Review and Customize

Before building, review and customize:

- **Timezone**: Edit `nixos/locale.nix` (currently set to America/New_York)
- **User password**: Change the initial password in `nixos/users.nix`
- **Monitor configuration**: Edit `home/dscv/niri.nix` outputs section
- **Packages**: Add/remove packages in `nixos/packages.nix` and `home/dscv/packages.nix`

### 3. Update Flake Lock

```bash
nix flake update
```

### 4. Build Configuration

Test the configuration without activating:

```bash
sudo nixos-rebuild build --flake .#blazar
```

### 5. Test Configuration

Apply the configuration temporarily (reverts on reboot):

```bash
sudo nixos-rebuild test --flake .#blazar
```

### 6. Switch to Configuration

If everything works, make it permanent:

```bash
sudo nixos-rebuild switch --flake .#blazar
```

### 7. Reboot

```bash
sudo reboot
```

## Post-Installation

### First Login

1. Log in with username `dscv` and password `changeme`
2. **Change your password immediately**: `passwd`
3. The niri session should start automatically via greetd

### Verify NVIDIA Setup

```bash
# Check NVIDIA driver
nvidia-smi

# Check modesetting
cat /sys/module/nvidia_drm/parameters/modeset  # Should output: Y

# Check Wayland session
echo $XDG_SESSION_TYPE  # Should output: wayland
```

### Verify Audio

```bash
# Check PipeWire status
systemctl --user status pipewire

# Test audio
pactl info
```

### Niri Keybindings

Default keybindings (Mod = Super/Windows key):

- `Mod+Return` - Open terminal (foot)
- `Mod+D` - Application launcher (fuzzel)
- `Mod+Q` - Close window
- `Mod+1-9` - Switch to workspace 1-9
- `Mod+Shift+1-9` - Move window to workspace 1-9
- `Mod+H/J/K/L` - Focus window (vim-style)
- `Mod+Shift+H/J/K/L` - Move window (vim-style)
- `Print` - Screenshot
- `Mod+Shift+E` - Quit niri

See `home/dscv/niri.nix` for complete keybinding list.

## Customization

### Adding Packages

**System packages** (available to all users):
- Edit `nixos/packages.nix`
- Run `sudo nixos-rebuild switch --flake .#blazar`

**User packages** (for dscv only):
- Edit `home/dscv/packages.nix`
- Run `sudo nixos-rebuild switch --flake .#blazar`

### Modifying Niri Configuration

Edit `home/dscv/niri.nix` to customize:
- Keybindings
- Window rules
- Animations
- Layout settings
- Monitor configuration
- Startup applications

### Shell Aliases

Convenient aliases are defined in `home/dscv/shell.nix`:

- `nrs` - Rebuild and switch
- `nrb` - Build only
- `nrt` - Test configuration
- `nfc` - Check flake
- `nfu` - Update flake
- `update` - Full system update
- `cleanup` - Garbage collect old generations

## Troubleshooting

### NVIDIA Issues

If you experience black screen or cursor issues:

1. Check kernel parameters: `cat /proc/cmdline`
2. Verify NVIDIA modules: `lsmod | grep nvidia`
3. Check environment variables: `env | grep -E '(NVIDIA|GBM|LIBVA)'`

For RTX 20-series or newer, consider enabling GSP in `nixos/nvidia.nix`:
```nix
hardware.nvidia.gsp.enable = true;
```

### Niri Issues

Check niri logs:
```bash
journalctl --user -u niri
```

Verify XDG portals:
```bash
systemctl --user status xdg-desktop-portal
```

### Audio Issues

Check PipeWire services:
```bash
systemctl --user status pipewire pipewire-pulse
```

## Maintenance

### Update System

```bash
# Update flake inputs
nix flake update

# Rebuild with new inputs
sudo nixos-rebuild switch --flake .#blazar
```

### Garbage Collection

```bash
# Manual cleanup
sudo nix-collect-garbage -d

# Or use the alias
cleanup
```

Automatic garbage collection runs weekly (configured in flake.nix).

### Rollback

If something breaks, rollback to previous generation:

1. Reboot
2. Select previous generation from bootloader menu
3. Or use: `sudo nixos-rebuild switch --rollback`

## Documentation

- [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md) - Detailed implementation strategy
- [IMPLEMENTATION_CHECKLIST.md](IMPLEMENTATION_CHECKLIST.md) - Step-by-step checklist
- [RESEARCH_FINDINGS.md](RESEARCH_FINDINGS.md) - Research and best practices
- [MODULE_TEMPLATES.md](MODULE_TEMPLATES.md) - Module templates and examples

## Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [NixOS Options Search](https://search.nixos.org/options)
- [Niri Wiki](https://github.com/YaLTeR/niri/wiki)
- [Niri Flake Documentation](https://github.com/sodiboo/niri-flake)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)

## License

This configuration is provided as-is for personal use. Modify as needed for your system.

