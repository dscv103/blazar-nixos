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
- [ ] Create main directory structure
  ```
  mkdir -p NixOS/{flake-parts,nixos,hosts,home}
  ```
- [ ] Navigate to NixOS directory: `cd NixOS`

### 1.2 Initial Flake Configuration
- [ ] Create `flake.nix` with flake-parts
- [ ] Add required inputs:
  - [ ] nixpkgs
  - [ ] flake-parts
  - [ ] home-manager
  - [ ] niri-flake
- [ ] Configure flake outputs structure
- [ ] Add binary cache for niri (optional but recommended)

### 1.3 Git Initialization (Recommended)
- [ ] Initialize git repository: `git init`
- [ ] Create `.gitignore` with:
  ```
  result
  result-*
  .direnv/
  ```
- [ ] Make initial commit

---

## Phase 2: Hardware Configuration

### 2.1 Generate Hardware Configuration
- [ ] Run `nixos-generate-config --show-hardware-config > hosts/<hostname>/hardware-configuration.nix`
- [ ] Review generated hardware configuration
- [ ] Note your disk UUIDs and filesystem types

### 2.2 Create Host Configuration
- [ ] Create `hosts/<hostname>/default.nix`
- [ ] Import hardware-configuration.nix
- [ ] Set hostname: `networking.hostName = "<hostname>";`
- [ ] Configure bootloader (systemd-boot or GRUB)

### 2.3 AMD CPU Configuration
- [ ] Create `nixos/hardware.nix`
- [ ] Enable AMD microcode updates
- [ ] Add KVM module for virtualization
- [ ] Set CPU frequency governor
- [ ] Add AMD P-State kernel parameter
- [ ] Enable redistributable firmware

### 2.4 System Basics
- [ ] Create `nixos/boot.nix` for bootloader configuration
- [ ] Create `nixos/locale.nix` for timezone, locale, console
- [ ] Create `nixos/networking.nix` for network configuration
- [ ] Configure timezone
- [ ] Configure locale (en_US.UTF-8 or your preference)
- [ ] Set console keymap
- [ ] Configure networking (NetworkManager recommended)

---

## Phase 3: NVIDIA Driver Setup

### 3.1 Create NVIDIA Module
- [ ] Create `nixos/nvidia.nix`
- [ ] Set `services.xserver.videoDrivers = [ "nvidia" ];`
- [ ] Enable `hardware.nvidia.modesetting.enable = true;`
- [ ] Choose driver version (stable recommended)
- [ ] Enable nvidia-settings GUI

### 3.2 Kernel Parameters
- [ ] Add `nvidia-drm.modeset=1` to `boot.kernelParams`
- [ ] Add `nvidia-drm.fbdev=1` (for kernel 6.6+)
- [ ] Optional: Add `nvidia.NVreg_PreserveVideoMemoryAllocations=1` for suspend

### 3.3 Environment Variables
- [ ] Set `LIBVA_DRIVER_NAME = "nvidia";`
- [ ] Set `GBM_BACKEND = "nvidia-drm";`
- [ ] Set `__GLX_VENDOR_LIBRARY_NAME = "nvidia";`
- [ ] Set `WLR_NO_HARDWARE_CURSORS = "1";`
- [ ] Optional: Set VRR variables for gaming

### 3.4 Graphics Support
- [ ] Enable `hardware.graphics.enable = true;` (Note: renamed from `hardware.opengl` in NixOS 24.05+)
- [ ] Enable `hardware.graphics.enable32Bit = true;` (for Steam/Wine)

### 3.5 Optional NVIDIA Settings
- [ ] Consider `hardware.nvidia.gsp.enable = true;` for RTX 20-series and newer (GPU System Processor)
- [ ] **NOT RECOMMENDED**: `hardware.nvidia.forceFullCompositionPipeline` (deprecated for Wayland, can reduce performance)
- [ ] Configure power management if needed (experimental, may cause issues)

---

## Phase 4: Niri Compositor Setup

### 4.1 Niri Flake Integration
- [ ] Verify niri-flake is in flake inputs
- [ ] Add niri-flake.nixosModules.niri to system modules
- [ ] Add niri-flake.homeManagerModules.niri to home-manager modules (if using)

### 4.2 System-Level Niri Configuration
- [ ] Create `nixos/desktop.nix`
- [ ] Enable `programs.niri.enable = true;`

### 4.3 XDG Desktop Portal
- [ ] Enable `xdg.portal.enable = true;`
- [ ] Enable `xdg.portal.wlr.enable = true;`
- [ ] Add `pkgs.xdg-desktop-portal-gtk` to extraPortals
- [ ] Configure `xdg.portal.config` to specify which portal provides each interface
  - Example: `config.common.default = [ "gtk" ];` and `config.niri.default = [ "wlr" "gtk" ];`

### 4.4 Display Manager
- [ ] Choose display manager (greetd recommended for Wayland)
- [ ] Configure greetd with tuigreet
- [ ] Set default session to niri-session
- [ ] Alternative: Configure SDDM with Wayland support

### 4.5 Essential Services
- [ ] Enable `security.polkit.enable = true;`
- [ ] Enable `services.dbus.enable = true;`
- [ ] Verify these are enabled (usually automatic)

---

## Phase 5: Audio and Additional Services

### 5.1 PipeWire Audio
- [ ] Create `nixos/audio.nix`
- [ ] Enable `security.rtkit.enable = true;` (RealtimeKit for low-latency)
- [ ] Enable `services.pipewire.enable = true;`
- [ ] Enable `services.pipewire.audio.enable = true;` (modern way to use PipeWire as primary sound server)
- [ ] Enable `services.pipewire.alsa.enable = true;` (ALSA compatibility)
- [ ] Enable `services.pipewire.alsa.support32Bit = true;` (for 32-bit apps)
- [ ] Enable `services.pipewire.pulse.enable = true;` (PulseAudio compatibility)
- [ ] Optional: Enable `services.pipewire.jack.enable = true;` (JACK compatibility for pro audio)

### 5.2 Bluetooth (Optional)
- [ ] Enable `hardware.bluetooth.enable = true;`
- [ ] Enable `services.blueman.enable = true;` for GUI

### 5.3 Printing (Optional)
- [ ] Enable `services.printing.enable = true;`
- [ ] Add printer drivers if needed

---

## Phase 6: User Configuration

### 6.1 System User Account
- [ ] Create `nixos/users.nix`
- [ ] Define user account with `users.users.<username>`
- [ ] Set `isNormalUser = true;`
- [ ] Add to groups: `wheel`, `networkmanager`, `video`, `audio`
- [ ] Set initial password or use `hashedPassword`

### 6.2 Home Manager Setup
- [ ] Create `home/<username>/home.nix`
- [ ] Set `home.username` and `home.homeDirectory`
- [ ] Set `home.stateVersion` (match system stateVersion)
- [ ] Enable `programs.home-manager.enable = true;`

### 6.3 Niri User Configuration
- [ ] Create `home/<username>/niri.nix`
- [ ] Option 1: Use `programs.niri.config` (if using niri-flake home module)
- [ ] Option 2: Use `home.file.".config/niri/config.kdl"` for raw config
- [ ] Configure keybindings
- [ ] Configure workspaces
- [ ] Configure outputs (monitors)
- [ ] Set preferred terminal

---

## Phase 7: Essential Packages

### 7.1 System Packages
- [ ] Create `nixos/packages.nix`
- [ ] Add terminal emulator (foot, alacritty, or kitty)
- [ ] Add application launcher (fuzzel, wofi, or rofi-wayland)
- [ ] Add status bar (waybar)
- [ ] Add notification daemon (mako or dunst)
- [ ] Add screenshot tools (grim, slurp, swappy)
- [ ] Add clipboard utilities (wl-clipboard, cliphist)
- [ ] Add file manager (nautilus, thunar, or terminal-based)
- [ ] Add lock screen (swaylock)
- [ ] Add wayland utilities (wayland-utils, wev)

### 7.2 User Packages (via Home Manager)
- [ ] Create `home/<username>/packages.nix`
- [ ] Add web browser (firefox with Wayland support)
- [ ] Add text editor
- [ ] Add development tools
- [ ] Add media players
- [ ] Add any other preferred applications

### 7.3 Shell Configuration
- [ ] Create `home/<username>/shell.nix`
- [ ] Configure bash/zsh/fish
- [ ] Set up shell aliases
- [ ] Configure prompt (starship recommended)

### 7.4 Git Configuration
- [ ] Create `home/<username>/git.nix`
- [ ] Set user name and email
- [ ] Configure git aliases and settings

---

## Phase 8: Flake-Parts Modules (Optional but Recommended)

### 8.1 Custom Packages Module
- [ ] Create `flake-parts/packages.nix`
- [ ] Define custom packages in `perSystem.packages`
- [ ] Import module in flake.nix `imports` list
- [ ] Test with `nix build .#<package-name>`

### 8.2 Overlays Module
- [ ] Create `flake-parts/overlays.nix`
- [ ] Define overlays to modify nixpkgs
- [ ] Import module in flake.nix `imports` list
- [ ] Export overlays via `flake.overlays` if needed

### 8.3 Development Shells Module
- [ ] Create `flake-parts/devshells.nix`
- [ ] Define development environments in `perSystem.devShells`
- [ ] Create default shell and any specialized shells
- [ ] Import module in flake.nix `imports` list
- [ ] Test with `nix develop` or `nix develop .#<shell-name>`

### 8.4 Checks Module (Optional)
- [ ] Create `flake-parts/checks.nix`
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

