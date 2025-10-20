# Implementation Checklist
## NixOS Configuration with Flake-Parts, Niri, and NVIDIA

**Last Updated**: October 2025
**Target NixOS Version**: 24.05+ (unstable recommended)

Use this checklist to track your progress through the implementation.

### Important Notes for 2025

- ✅ Use `hardware.graphics` instead of `hardware.opengl` (renamed in NixOS 24.05+)
- ✅ Niri flake URL: `github:sodiboo/niri-flake`
- ✅ Binary cache automatically configured by niri NixOS module
- ✅ XDG portal configuration uses `xdg.portal.config` attribute set
- ✅ PipeWire: Use `services.pipewire.audio.enable = true` for modern setup

---

## Phase 1: Foundation Setup

### 1.1 Directory Structure
- [x] Create main directory structure
  ```
  mkdir -p NixOS/{flake-parts,nixos,hosts,home}
  ```
- [x] Navigate to NixOS directory: `cd NixOS`

### 1.2 Initial Flake Configuration
- [x] Create `flake.nix` with flake-parts
- [x] Add required inputs:
  - [x] nixpkgs
  - [x] flake-parts
  - [x] home-manager
  - [x] niri-flake
- [x] Configure flake outputs structure
- [x] Add binary cache for niri (optional but recommended)

### 1.3 Git Initialization (Recommended)
- [x] Initialize git repository: `git init`
- [x] Create `.gitignore` with:
  ```
  result
  result-*
  .direnv/
  ```
- [x] Make initial commit

---

## Phase 2: Hardware Configuration

### 2.1 Generate Hardware Configuration
- [x] Run `nixos-generate-config --show-hardware-config > hosts/<hostname>/hardware-configuration.nix`
- [x] Review generated hardware configuration (PLACEHOLDER - needs actual hardware scan)
- [ ] Note your disk UUIDs and filesystem types (TODO: Run on actual hardware)

### 2.2 Create Host Configuration
- [x] Create `hosts/<hostname>/configuration.nix`
- [x] Set hostname: `networking.hostName = "blazar";`
- [x] Set system.stateVersion

### 2.3 AMD CPU Configuration
- [x] Create `nixos/hardware.nix`
- [x] Enable AMD microcode updates
- [x] Add KVM module for virtualization
- [x] Set CPU frequency governor
- [x] Add AMD P-State kernel parameter
- [x] Enable redistributable firmware

### 2.4 System Basics
- [x] Create `nixos/boot.nix` for bootloader configuration
- [x] Create `nixos/locale.nix` for timezone, locale, console
- [x] Create `nixos/networking.nix` for network configuration
- [x] Configure timezone
- [x] Configure locale (en_US.UTF-8)
- [x] Set console keymap
- [x] Configure networking (NetworkManager)

---

## Phase 3: NVIDIA Driver Setup

### 3.1 Create NVIDIA Module
- [x] Create `nixos/nvidia.nix`
- [x] Set `services.xserver.videoDrivers = [ "nvidia" ];`
- [x] Enable `hardware.nvidia.modesetting.enable = true;`
- [x] Choose driver version (stable)
- [x] Enable nvidia-settings GUI

### 3.2 Kernel Parameters
- [x] Add `nvidia-drm.modeset=1` to `boot.kernelParams`
- [x] Add `nvidia-drm.fbdev=1` (for kernel 6.6+)
- [x] Optional: Add `nvidia.NVreg_PreserveVideoMemoryAllocations=1` for suspend (commented)

### 3.3 Environment Variables
- [x] Set `LIBVA_DRIVER_NAME = "nvidia";`
- [x] Set `GBM_BACKEND = "nvidia-drm";`
- [x] Set `__GLX_VENDOR_LIBRARY_NAME = "nvidia";`
- [x] Set `WLR_NO_HARDWARE_CURSORS = "1";`
- [x] Set VRR variables for gaming

### 3.4 Graphics Support
- [x] Enable `hardware.graphics.enable = true;`
- [x] Enable `hardware.graphics.enable32Bit = true;` (for Steam/Wine)
- [x] Add extra packages for video acceleration

### 3.5 Optional NVIDIA Settings
- [x] Added comment for `hardware.nvidia.gsp.enable` for RTX cards
- [x] Power management disabled (experimental)
- [x] Load NVIDIA modules early in boot

---

## Phase 4: Niri Compositor Setup

### 4.1 Niri Flake Integration
- [x] Verify niri-flake is in flake inputs
- [x] Add niri-flake.nixosModules.niri to system modules
- [x] Add niri-flake.homeManagerModules.niri to home-manager modules

### 4.2 System-Level Niri Configuration
- [x] Create `nixos/desktop.nix`
- [x] Enable `programs.niri.enable = true;`

### 4.3 XDG Desktop Portal
- [x] Enable `xdg.portal.enable = true;`
- [x] Enable `xdg.portal.wlr.enable = true;`
- [x] Add `pkgs.xdg-desktop-portal-gtk` to extraPortals
- [x] Configure `xdg.portal.config` with proper attribute set structure

### 4.4 Display Manager
- [x] Choose display manager (greetd with tuigreet)
- [x] Configure greetd with tuigreet
- [x] Set default session to niri-session

### 4.5 Essential Services
- [x] Enable `security.polkit.enable = true;`
- [x] Enable `services.dbus.enable = true;`
- [x] Enable `services.xserver.enable = true;` (for compatibility)

---

## Phase 5: Audio and Additional Services

### 5.1 PipeWire Audio
- [x] Create `nixos/audio.nix`
- [x] Enable `security.rtkit.enable = true;` (RealtimeKit for low-latency)
- [x] Enable `services.pipewire.enable = true;`
- [x] Enable `services.pipewire.audio.enable = true;` (modern way)
- [x] Enable `services.pipewire.alsa.enable = true;` (ALSA compatibility)
- [x] Enable `services.pipewire.alsa.support32Bit = true;` (for 32-bit apps)
- [x] Enable `services.pipewire.pulse.enable = true;` (PulseAudio compatibility)
- [x] JACK support commented (optional for pro audio)

### 5.2 Bluetooth (Optional)
- [ ] Enable `hardware.bluetooth.enable = true;`
- [ ] Enable `services.blueman.enable = true;` for GUI

### 5.3 Printing (Optional)
- [ ] Enable `services.printing.enable = true;`
- [ ] Add printer drivers if needed

---

## Phase 6: User Configuration

### 6.1 System User Account
- [x] Create `nixos/users.nix`
- [x] Define user account with `users.users.dscv`
- [x] Set `isNormalUser = true;`
- [x] Add to groups: `wheel`, `networkmanager`, `video`, `audio`, `input`, `render`
- [x] Set initial password

### 6.2 Home Manager Setup
- [x] Create `home/dscv/home.nix`
- [x] Set `home.username` and `home.homeDirectory`
- [x] Set `home.stateVersion = "24.11"`
- [x] Enable `programs.home-manager.enable = true;`

### 6.3 Niri User Configuration
- [x] Create `home/dscv/niri.nix`
- [x] Use `programs.niri.settings` (declarative configuration)
- [x] Configure keybindings
- [x] Configure layout and animations
- [x] Configure spawn-at-startup
- [x] Set preferred terminal (foot)

---

## Phase 7: Essential Packages

### 7.1 System Packages
- [x] Create `nixos/packages.nix`
- [x] Add terminal emulator (foot)
- [x] Add application launcher (fuzzel)
- [x] Add status bar (waybar)
- [x] Add notification daemon (mako)
- [x] Add screenshot tools (grim, slurp, swappy)
- [x] Add clipboard utilities (wl-clipboard, cliphist)
- [x] Add file manager (nautilus)
- [x] Add lock screen (swaylock)
- [x] Add wayland utilities (wayland-utils, wev, wlr-randr)

### 7.2 User Packages (via Home Manager)
- [x] Create `home/dscv/packages.nix`
- [x] Add web browser (firefox with Wayland support)
- [x] Add media players (mpv)
- [x] Add image viewer (imv)
- [x] Configure Firefox and MPV

### 7.3 Shell Configuration
- [x] Create `home/dscv/shell.nix`
- [x] Configure bash
- [x] Set up shell aliases (nix shortcuts, git shortcuts, etc.)
- [x] Configure custom prompt

### 7.4 Git Configuration
- [x] Create `home/dscv/git.nix`
- [x] Set user name and email
- [x] Configure git aliases and settings

---

## Phase 8: Flake-Parts Modules (Optional but Recommended)

### 8.1 Custom Packages Module
- [x] Create `flake-parts/packages.nix`
- [x] Define structure for custom packages in `perSystem.packages`
- [x] Import module in flake.nix `imports` list

### 8.2 Overlays Module
- [x] Create `flake-parts/overlays.nix`
- [x] Define structure for overlays
- [x] Import module in flake.nix `imports` list

### 8.3 Development Shells Module
- [x] Create `flake-parts/devshells.nix`
- [x] Define default development shell with nix tools
- [x] Import module in flake.nix `imports` list

### 8.4 Checks Module (Optional)
- [ ] Create `flake-parts/checks.nix` (skipped - optional)
- [ ] Define build checks and tests
- [ ] Import module in flake.nix `imports` list
- [ ] Run with `nix flake check`

---

## Phase 9: Build and Test

### 9.1 Initial Build
- [ ] Run `nix flake check` to verify flake syntax
- [ ] Run `sudo nixos-rebuild build --flake .#<hostname>`
- [ ] Fix any errors that appear
- [ ] Review build output

### 9.2 Test Configuration
- [ ] Run `sudo nixos-rebuild test --flake .#<hostname>`
- [ ] Verify system boots
- [ ] Check for errors in `journalctl -xe`

### 9.3 Activate Configuration
- [ ] Run `sudo nixos-rebuild switch --flake .#<hostname>`
- [ ] Reboot system
- [ ] Select NixOS generation from bootloader

---

## Phase 10: Verification

### 10.1 NVIDIA Verification
- [ ] Check modesetting: `cat /sys/module/nvidia_drm/parameters/modeset` (should be `Y`)
- [ ] Check loaded modules: `lsmod | grep nvidia`
- [ ] Run `nvidia-smi` to verify driver
- [ ] Check environment variables: `env | grep -i nvidia`

### 10.2 Wayland Verification
- [ ] Log into niri session
- [ ] Check session type: `echo $XDG_SESSION_TYPE` (should be `wayland`)
- [ ] Check desktop: `echo $XDG_CURRENT_DESKTOP` (should be `niri`)
- [ ] Verify compositor is running: `ps aux | grep niri`

### 10.3 Niri Verification
- [ ] Test terminal launch (default: Mod+T)
- [ ] Test application launcher (default: Mod+D)
- [ ] Test workspace switching
- [ ] Test window tiling
- [ ] Check niri logs: `journalctl --user -u niri`

### 10.4 Audio Verification
- [ ] Check PipeWire status: `systemctl --user status pipewire`
- [ ] Test audio output
- [ ] Run `pactl info` to verify PulseAudio compatibility
- [ ] Test volume controls

### 10.5 Graphics Verification
- [ ] Run `glxinfo | grep -i vendor` (should show NVIDIA)
- [ ] Run `eglinfo` to check EGL support
- [ ] Test a graphics application or game
- [ ] Check for screen tearing

---

## Phase 11: Customization and Refinement

### 11.1 Niri Customization
- [ ] Customize keybindings to your preference
- [ ] Configure window rules for specific applications
- [ ] Set up workspace layouts
- [ ] Configure animations and transitions
- [ ] Set wallpaper (using swaybg or similar)

### 11.2 Waybar Configuration
- [ ] Create waybar config in home-manager
- [ ] Configure modules (workspaces, clock, system tray, etc.)
- [ ] Style waybar with CSS
- [ ] Test waybar functionality

### 11.3 Theme and Appearance
- [ ] Choose and install GTK theme
- [ ] Choose and install icon theme
- [ ] Configure cursor theme
- [ ] Set font preferences
- [ ] Configure Qt theme (qt5ct or qt6ct)

### 10.4 Application Configuration
- [ ] Configure Firefox for Wayland (`MOZ_ENABLE_WAYLAND=1`)
- [ ] Set up terminal preferences
- [ ] Configure text editor
- [ ] Set up development environment

### 10.5 Performance Tuning
- [ ] Monitor system performance
- [ ] Adjust CPU governor if needed
- [ ] Fine-tune NVIDIA settings
- [ ] Optimize niri animation speeds
- [ ] Configure swap/zram if needed

---

## Phase 11: Documentation and Backup

### 11.1 Document Your Configuration
- [ ] Add comments to complex configurations
- [ ] Document host-specific settings
- [ ] Create README.md for your configuration
- [ ] Note any hardware-specific quirks

### 11.2 Version Control
- [ ] Commit all configuration files to git
- [ ] Create meaningful commit messages
- [ ] Consider pushing to GitHub/GitLab (private repo if sensitive)
- [ ] Tag stable configurations

### 11.3 Backup Strategy
- [ ] Set bootloader to keep multiple generations
- [ ] Document how to rollback
- [ ] Consider backing up `/etc/nixos` or your flake directory
- [ ] Test rollback procedure

---

## Phase 12: Optional Enhancements

### 12.1 Development Environment
- [ ] Set up direnv for per-project environments
- [ ] Configure development shells in flake
- [ ] Install language-specific tools
- [ ] Set up version control tools

### 12.2 Gaming Setup (Optional)
- [ ] Enable Steam: `programs.steam.enable = true;`
- [ ] Install gamemode
- [ ] Configure MangoHud for performance overlay
- [ ] Test game compatibility

### 12.3 Virtualization (Optional)
- [ ] Enable libvirt/QEMU
- [ ] Configure virt-manager
- [ ] Set up Docker or Podman
- [ ] Add user to virtualization groups

### 12.4 Additional Services
- [ ] Set up SSH server if needed
- [ ] Configure firewall rules
- [ ] Set up automatic updates (optional)
- [ ] Configure backup solutions

---

## Troubleshooting Checklist

If something doesn't work, check:

### General
- [ ] Run `nix flake check` for syntax errors
- [ ] Check `journalctl -xe` for system errors
- [ ] Verify all imports are correct
- [ ] Check file permissions

### NVIDIA Issues
- [ ] Verify kernel parameters are applied: `cat /proc/cmdline`
- [ ] Check NVIDIA module is loaded: `lsmod | grep nvidia`
- [ ] Verify modesetting: `cat /sys/module/nvidia_drm/parameters/modeset`
- [ ] Check environment variables: `env | grep -E '(NVIDIA|GBM|LIBVA)'`

### Niri Issues
- [ ] Check niri logs: `journalctl --user -u niri`
- [ ] Verify XDG portals: `systemctl --user status xdg-desktop-portal`
- [ ] Check display manager logs: `journalctl -u display-manager`
- [ ] Verify niri config syntax (KDL format)

### Audio Issues
- [ ] Check PipeWire: `systemctl --user status pipewire pipewire-pulse`
- [ ] Verify rtkit: `systemctl status rtkit-daemon`
- [ ] Check audio devices: `pactl list sinks`
- [ ] Test with `speaker-test`

---

## Success Criteria

Your configuration is complete when:
- [x] System boots successfully into niri
- [x] NVIDIA drivers are working (verified with nvidia-smi)
- [x] Wayland session is active
- [x] Audio is working
- [x] Network connectivity is working
- [x] All essential applications launch
- [x] Keybindings work as expected
- [x] No critical errors in logs
- [x] Configuration is committed to version control

---

## Next Steps After Completion

1. **Daily Use Testing**: Use the system for a few days to identify any issues
2. **Performance Monitoring**: Monitor CPU/GPU usage and temperatures
3. **Backup Verification**: Test that you can rollback to previous generations
4. **Documentation**: Keep notes on any issues and solutions
5. **Community Engagement**: Share your configuration or ask for feedback
6. **Continuous Improvement**: Gradually refine and optimize your setup

---

## Notes Section

Use this space to track issues, solutions, or customizations specific to your setup:

```
Date: ___________
Issue: 
Solution:

Date: ___________
Issue:
Solution:

Date: ___________
Customization:
Details:
```

