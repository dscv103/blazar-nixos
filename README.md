# NixOS Configuration Plan
## Flake-Parts + Niri + NVIDIA + AMD Ryzen 7 5800X

This repository contains a comprehensive implementation plan for setting up a modern NixOS system with:
- **Flake Framework**: flake-parts for modular organization
- **Compositor**: niri (scrollable-tiling Wayland compositor)
- **GPU**: NVIDIA with full Wayland support
- **CPU**: AMD Ryzen 7 5800X with optimizations

---

## 📚 Documentation Structure

### Core Documents

1. **[IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md)** - Main implementation guide
   - Detailed explanation of all components
   - Complete configuration patterns
   - NixOS options reference
   - Troubleshooting guidance
   - **Start here** for understanding the architecture

2. **[IMPLEMENTATION_CHECKLIST.md](IMPLEMENTATION_CHECKLIST.md)** - Step-by-step checklist
   - Phase-by-phase implementation tasks
   - Verification steps
   - Troubleshooting checklist
   - Success criteria
   - **Use this** to track your progress

3. **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** - Quick reference guide
   - Essential commands
   - Configuration snippets
   - Troubleshooting tips
   - Performance tuning
   - **Keep this** handy during implementation

4. **Architecture Diagrams** - Visual representations
   - System architecture overview
   - Component interaction flow
   - **Review these** to understand how components fit together

---

## 🎯 Quick Start

### Prerequisites
- NixOS installation media or existing NixOS system
- AMD Ryzen 7 5800X CPU
- NVIDIA GPU
- Basic familiarity with NixOS and Nix flakes

### Implementation Order
1. Read through [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md) to understand the architecture
2. Follow [IMPLEMENTATION_CHECKLIST.md](IMPLEMENTATION_CHECKLIST.md) phase by phase
3. Use [QUICK_REFERENCE.md](QUICK_REFERENCE.md) for commands and snippets
4. Refer back to the main plan for detailed explanations

---

## 🏗️ Architecture Overview

### Directory Structure
```
NixOS/
├── flake.nix                    # Main flake entry point
├── flake.lock                   # Lock file (auto-generated)
│
├── flake-parts/                 # Flake-parts modules (imported in flake.nix)
│   ├── packages.nix             # Custom package definitions
│   ├── overlays.nix             # Nixpkgs overlays
│   ├── devshells.nix            # Development environments
│   └── checks.nix               # Build checks (optional)
│
├── nixos/                       # NixOS system modules (flat structure)
│   ├── hardware.nix             # AMD CPU configuration
│   ├── nvidia.nix               # NVIDIA driver setup
│   ├── desktop.nix              # Niri + Wayland
│   ├── boot.nix                 # Bootloader configuration
│   ├── networking.nix           # Network configuration
│   ├── locale.nix               # Locale, timezone, console
│   ├── users.nix                # User accounts
│   ├── audio.nix                # PipeWire audio
│   ├── packages.nix             # System-wide packages
│   └── nix-settings.nix         # Nix daemon settings
│
├── hosts/
│   └── <hostname>/              # Per-host configuration
│       ├── configuration.nix    # Host-specific settings
│       └── hardware-configuration.nix  # Generated hardware config
│
└── home/
    └── <username>/              # Per-user configuration (flat structure)
        ├── home.nix             # Home-manager base
        ├── niri.nix             # Niri user config
        ├── shell.nix            # Shell configuration
        ├── git.nix              # Git configuration
        └── packages.nix         # User packages
```

### Key Components

#### 1. Flake-Parts Framework
- Modular flake organization
- Clean separation of concerns
- Reusable across multiple hosts
- Type-safe module system

#### 2. AMD Ryzen 7 5800X Optimization
- Microcode updates
- KVM virtualization support
- AMD P-State driver (kernel 6.1+)
- Optimized CPU governor

#### 3. NVIDIA Wayland Support
- **Critical**: Kernel modesetting enabled
- GBM backend for Wayland
- Proper environment variables
- Hardware cursor workarounds

#### 4. Niri Compositor
- Scrollable-tiling Wayland compositor
- Native Wayland support
- Integrated via niri-flake
- Declarative configuration

#### 5. Essential Services
- XDG Desktop Portals (screen sharing, file pickers)
- PipeWire audio system
- Display manager (greetd)
- Polkit authorization

---

## 🔑 Critical Configuration Points

### NVIDIA + Wayland Compatibility

**Must-have kernel parameters:**
```nix
boot.kernelParams = [
  "nvidia-drm.modeset=1"    # CRITICAL for Wayland
  "nvidia-drm.fbdev=1"      # For kernel 6.6+
];
```

**Must-have NVIDIA options:**
```nix
hardware.nvidia.modesetting.enable = true;  # REQUIRED
services.xserver.videoDrivers = [ "nvidia" ];
```

**Must-have environment variables:**
```nix
environment.sessionVariables = {
  LIBVA_DRIVER_NAME = "nvidia";
  GBM_BACKEND = "nvidia-drm";
  __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  WLR_NO_HARDWARE_CURSORS = "1";
};
```

### Niri Setup

**System-level:**
```nix
programs.niri.enable = true;

xdg.portal = {
  enable = true;
  wlr.enable = true;
  extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
};
```

**User-level (via home-manager):**
- Configure keybindings
- Set up workspaces
- Configure window rules
- Set outputs (monitors)

---

## 🚀 Implementation Phases

### Phase 1: Foundation (30 minutes)
- Create directory structure
- Write initial flake.nix
- Generate hardware configuration
- Set up basic system config

### Phase 2: Hardware & Drivers (45 minutes)
- Configure AMD CPU optimizations
- Set up NVIDIA drivers
- Add kernel parameters
- Configure environment variables

### Phase 3: Desktop Environment (1 hour)
- Integrate niri-flake
- Configure XDG portals
- Set up display manager
- Configure audio (PipeWire)

### Phase 4: User Environment (45 minutes)
- Create user accounts
- Set up home-manager
- Configure niri user settings
- Install essential packages

### Phase 5: Testing & Refinement (1-2 hours)
- Build and test configuration
- Verify NVIDIA Wayland support
- Test niri functionality
- Fine-tune and customize

**Total estimated time: 4-5 hours** (for first-time setup)

---

## ✅ Success Criteria

Your configuration is complete when:
- ✅ System boots successfully into niri
- ✅ NVIDIA drivers are working (`nvidia-smi` shows GPU)
- ✅ Wayland session is active (`echo $XDG_SESSION_TYPE` shows `wayland`)
- ✅ Audio is working (PipeWire active)
- ✅ Network connectivity works
- ✅ All essential applications launch
- ✅ Keybindings work as expected
- ✅ No critical errors in logs
- ✅ Configuration is version controlled

---

## 🔧 Essential Commands

### Building
```bash
# Build without activating
sudo nixos-rebuild build --flake .#<hostname>

# Build and activate
sudo nixos-rebuild switch --flake .#<hostname>

# Test (temporary, reverts on reboot)
sudo nixos-rebuild test --flake .#<hostname>
```

### Verification
```bash
# Check NVIDIA modesetting
cat /sys/module/nvidia_drm/parameters/modeset  # Should output: Y

# Verify Wayland session
echo $XDG_SESSION_TYPE  # Should output: wayland

# Check NVIDIA driver
nvidia-smi

# View logs
journalctl -xe
journalctl --user -u niri
```

### Flake Management
```bash
# Update all inputs
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs

# Check flake
nix flake check

# Show outputs
nix flake show
```

---

## 🐛 Common Issues and Solutions

### Issue: Black screen on boot
**Solution**: Verify `nvidia-drm.modeset=1` is in kernel parameters

### Issue: Cursor not visible
**Solution**: Set `WLR_NO_HARDWARE_CURSORS = "1"` in environment variables

### Issue: Screen tearing
**Solution**: Enable `hardware.nvidia.forceFullCompositionPipeline = true;`

### Issue: Niri won't start
**Solution**: Check XDG portals are configured and display manager logs

### Issue: No audio
**Solution**: Verify PipeWire is running: `systemctl --user status pipewire`

See [QUICK_REFERENCE.md](QUICK_REFERENCE.md) for complete troubleshooting guide.

---

## 📦 Essential Packages

### System Packages
- **Terminal**: foot, alacritty, or kitty
- **Launcher**: fuzzel, wofi, or rofi-wayland
- **Status Bar**: waybar
- **Notifications**: mako or dunst
- **Screenshots**: grim, slurp, swappy
- **Clipboard**: wl-clipboard, cliphist
- **File Manager**: nautilus, thunar
- **Lock Screen**: swaylock

### User Packages (via Home Manager)
- **Browser**: firefox (with Wayland support)
- **Editor**: neovim, vscode, or your preference
- **Development**: git, build tools, language toolchains
- **Media**: mpv, imv, etc.

---

## 🎨 Customization

After basic setup, customize:
1. **Niri keybindings** - Adjust to your workflow
2. **Waybar** - Configure modules and styling
3. **Themes** - GTK, icon, and cursor themes
4. **Applications** - Install your preferred tools
5. **Performance** - Fine-tune CPU governor and NVIDIA settings

---

## 📖 Resources

### Official Documentation
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Flake-parts Documentation](https://flake.parts/)

### Niri Resources
- [Niri GitHub](https://github.com/YaLTeR/niri)
- [Niri Flake](https://github.com/sodiboo/niri-flake)
- [Niri Wiki](https://github.com/YaLTeR/niri/wiki)

### Community
- [NixOS Discourse](https://discourse.nixos.org/)
- [NixOS Reddit](https://reddit.com/r/NixOS)
- [NixOS Wiki](https://nixos.wiki/)

### Search Tools
- [NixOS Search](https://search.nixos.org/)
- [Home Manager Options](https://nix-community.github.io/home-manager/options.xhtml)
- [Nix Package Versions](https://lazamar.co.uk/nix-versions/)

---

## 🤝 Contributing

This is a planning document. If you implement this configuration and find:
- Issues or corrections needed
- Better approaches
- Additional optimizations
- Useful tips

Consider documenting them for others!

---

## 📝 License

This documentation is provided as-is for educational purposes. Adapt and modify as needed for your system.

---

## 🙏 Acknowledgments

- **NixOS Community** - For the amazing ecosystem
- **Niri Project** - For the excellent Wayland compositor
- **sodiboo** - For the niri-flake integration
- **Flake-parts** - For the modular flake framework

---

## 🚦 Next Steps

1. **Read** [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md) thoroughly
2. **Follow** [IMPLEMENTATION_CHECKLIST.md](IMPLEMENTATION_CHECKLIST.md) step-by-step
3. **Reference** [QUICK_REFERENCE.md](QUICK_REFERENCE.md) as needed
4. **Build** your configuration incrementally
5. **Test** each phase before moving to the next
6. **Document** any issues or customizations
7. **Enjoy** your new NixOS system!

---

**Good luck with your NixOS setup! 🎉**

