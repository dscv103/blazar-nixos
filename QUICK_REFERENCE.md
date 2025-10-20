# Quick Reference Guide
## NixOS + Flake-Parts + Niri + NVIDIA Setup

---

## Essential Commands

### Building and Switching
```bash
# Build configuration (don't activate)
sudo nixos-rebuild build --flake .#<hostname>

# Build and activate (switch)
sudo nixos-rebuild switch --flake .#<hostname>

# Build and activate on next boot
sudo nixos-rebuild boot --flake .#<hostname>

# Test configuration (temporary, reverts on reboot)
sudo nixos-rebuild test --flake .#<hostname>

# Update flake inputs
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs
```

### Flake Operations
```bash
# Show flake outputs
nix flake show

# Check flake for errors
nix flake check

# Format nix files
nix fmt

# Enter development shell (default)
nix develop

# Enter named development shell
nix develop .#python
nix develop .#rust

# Build custom package
nix build .#my-package

# Run custom package
nix run .#my-package
```

### Debugging
```bash
# Check NVIDIA modesetting
cat /sys/module/nvidia_drm/parameters/modeset

# List loaded NVIDIA modules
lsmod | grep nvidia

# Check Wayland session
echo $XDG_SESSION_TYPE

# View system logs
journalctl -xe
journalctl -u display-manager

# Check niri logs
journalctl --user -u niri
```

---

## Critical Configuration Snippets

### Minimal flake.nix with flake-parts
```nix
{
  description = "NixOS configuration with niri";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    flake-parts.url = "github:hercules-ci/flake-parts";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    niri-flake = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      
      flake = {
        nixosConfigurations.myhostname = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/myhostname
            inputs.niri-flake.nixosModules.niri
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.myusername = import ./home/myusername;
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
          ];
        };
      };
    };
}
```

### NVIDIA Configuration (nvidia.nix)
```nix
{ config, pkgs, ... }:

{
  # Enable NVIDIA drivers
  services.xserver.videoDrivers = [ "nvidia" ];
  
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  
  # Graphics support
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  
  # Kernel parameters
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
  ];
  
  # Environment variables
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    WLR_NO_HARDWARE_CURSORS = "1";
  };
}
```

### AMD CPU Configuration (hardware.nix)
```nix
{ config, lib, pkgs, ... }:

{
  # AMD CPU microcode
  hardware.cpu.amd.updateMicrocode = true;
  
  # Enable KVM
  boot.kernelModules = [ "kvm-amd" ];
  
  # CPU governor
  powerManagement.cpuFreqGovernor = "schedutil";
  
  # AMD P-State driver (kernel 6.1+)
  boot.kernelParams = [ "amd_pstate=active" ];
  
  # Enable firmware
  hardware.enableRedistributableFirmware = true;
}
```

### Niri Desktop Configuration (desktop.nix)
```nix
{ config, pkgs, ... }:

{
  # Enable niri
  programs.niri.enable = true;
  
  # XDG Desktop Portal
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };
  
  # Display manager (greetd with tuigreet)
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd niri-session";
        user = "greeter";
      };
    };
  };
  
  # Essential services
  security.polkit.enable = true;
  services.dbus.enable = true;
  
  # Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
```

### Essential Packages
```nix
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Terminal
    foot
    
    # Launcher
    fuzzel
    
    # Status bar
    waybar
    
    # Notifications
    mako
    
    # Screenshots
    grim
    slurp
    
    # Clipboard
    wl-clipboard
    
    # File manager
    nautilus
    
    # Lock screen
    swaylock
    
    # Utilities
    wayland-utils
    wev  # Wayland event viewer
  ];
}
```

---

## Flake-Parts Module Examples

### Custom Package Module (flake-parts/packages.nix)
```nix
{ inputs, ... }:

{
  perSystem = { config, self', inputs', pkgs, system, lib, ... }: {
    packages = {
      # Simple script package
      my-script = pkgs.writeShellScriptBin "my-script" ''
        #!${pkgs.bash}/bin/bash
        echo "Hello from custom package!"
      '';

      # Custom derivation
      my-app = pkgs.stdenv.mkDerivation {
        pname = "my-app";
        version = "1.0.0";
        src = ./src;
        buildInputs = with pkgs; [ ];
        installPhase = ''
          mkdir -p $out/bin
          cp my-app $out/bin/
        '';
      };
    };
  };
}
```

### Overlays Module (flake-parts/overlays.nix)
```nix
{ inputs, ... }:

{
  perSystem = { config, self', inputs', pkgs, system, lib, ... }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = [
        # Modify existing package
        (final: prev: {
          neovim = prev.neovim.override {
            viAlias = true;
            vimAlias = true;
          };
        })
      ];
      config.allowUnfree = true;
    };
  };
}
```

### Development Shells Module (flake-parts/devshells.nix)
```nix
{ inputs, ... }:

{
  perSystem = { config, self', inputs', pkgs, system, lib, ... }: {
    devShells = {
      default = pkgs.mkShell {
        buildInputs = with pkgs; [
          nixpkgs-fmt
          nil
          git
        ];
        shellHook = ''
          echo "Development environment loaded"
        '';
      };

      python = pkgs.mkShell {
        buildInputs = with pkgs; [
          python311
          python311Packages.pip
        ];
      };
    };
  };
}
```

### Using Flake-Parts Modules in flake.nix
```nix
{
  outputs = inputs @ { flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      # Import flake-parts modules
      imports = [
        ./flake-parts/packages.nix
        ./flake-parts/overlays.nix
        ./flake-parts/devshells.nix
      ];

      # Rest of configuration...
    };
}
```

---

## Troubleshooting Checklist

### NVIDIA Not Working
- [ ] Check `nvidia-drm.modeset=1` in kernel params
- [ ] Verify `hardware.nvidia.modesetting.enable = true`
- [ ] Check `services.xserver.videoDrivers = [ "nvidia" ]`
- [ ] Verify environment variables are set
- [ ] Check `cat /sys/module/nvidia_drm/parameters/modeset` outputs `Y`

### Niri Won't Start
- [ ] Check `journalctl --user -u niri` for errors
- [ ] Verify XDG portals are configured
- [ ] Check display manager logs: `journalctl -u display-manager`
- [ ] Ensure `programs.niri.enable = true`
- [ ] Verify niri-flake is in inputs and modules

### Cursor Issues
- [ ] Set `WLR_NO_HARDWARE_CURSORS = "1"`
- [ ] Check if cursor theme is installed
- [ ] Verify `XCURSOR_THEME` and `XCURSOR_SIZE` are set

### Screen Tearing
- [ ] Enable `hardware.nvidia.forceFullCompositionPipeline = true`
- [ ] Check VRR settings in niri config
- [ ] Verify monitor refresh rate configuration

### Audio Not Working
- [ ] Check `systemctl --user status pipewire`
- [ ] Verify `security.rtkit.enable = true`
- [ ] Check `services.pipewire.enable = true`
- [ ] Run `pactl info` to verify PulseAudio compatibility

---

## Useful Environment Variables

### NVIDIA + Wayland
```bash
export LIBVA_DRIVER_NAME=nvidia
export GBM_BACKEND=nvidia-drm
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export WLR_NO_HARDWARE_CURSORS=1
export __GL_GSYNC_ALLOWED=1
export __GL_VRR_ALLOWED=1
```

### Wayland General
```bash
export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=niri
export MOZ_ENABLE_WAYLAND=1  # Firefox
export QT_QPA_PLATFORM=wayland
export SDL_VIDEODRIVER=wayland
export CLUTTER_BACKEND=wayland
```

---

## File Locations

### System Configuration
- `/etc/nixos/configuration.nix` - Traditional (not used with flakes)
- `/etc/nixos/flake.nix` - System flake (if installed there)
- `/etc/niri/config.kdl` - System-wide niri config

### User Configuration
- `~/.config/niri/config.kdl` - User niri config
- `~/.config/home-manager/` - Home-manager config (standalone)

### Logs
- `/var/log/` - System logs
- `~/.local/share/niri/` - Niri user data
- `journalctl` - Systemd journal

---

## Performance Tips

### NVIDIA
- Use latest stable driver: `config.boot.kernelPackages.nvidiaPackages.stable`
- For newest GPUs, consider: `nvidiaPackages.beta` or `nvidiaPackages.production`
- Enable GSP firmware: `hardware.nvidia.gsp.enable = true;` (RTX 20/30/40 series)

### AMD Ryzen 7 5800X
- Use `schedutil` governor for balanced performance
- Use `performance` governor for maximum performance
- Enable AMD P-State: `boot.kernelParams = [ "amd_pstate=active" ];`
- Consider latest kernel: `boot.kernelPackages = pkgs.linuxPackages_latest;`

### Niri
- Configure output refresh rates in niri config
- Enable VRR if supported by monitor
- Adjust animation speeds for preference

---

## Next Steps After Implementation

1. **Test basic functionality**
   - Boot into niri session
   - Verify NVIDIA is working: `nvidia-smi`
   - Check Wayland: `echo $XDG_SESSION_TYPE`

2. **Configure niri keybindings**
   - Set up workspace navigation
   - Configure window management
   - Set up application launchers

3. **Install applications**
   - Web browser (Firefox with Wayland)
   - Text editor
   - Development tools
   - Media players

4. **Customize appearance**
   - Set wallpaper
   - Configure waybar
   - Set up notification styling
   - Choose GTK/Qt themes

5. **Set up additional services**
   - SSH server (if needed)
   - Docker/Podman (if needed)
   - Development environments
   - Backup solutions

---

## Resources

### Documentation
- NixOS Manual: https://nixos.org/manual/nixos/stable/
- Nix Pills: https://nixos.org/guides/nix-pills/
- Home Manager Manual: https://nix-community.github.io/home-manager/
- Flake-parts: https://flake.parts/

### Niri
- Niri GitHub: https://github.com/YaLTeR/niri
- Niri Flake: https://github.com/sodiboo/niri-flake
- Niri Wiki: https://github.com/YaLTeR/niri/wiki

### Community
- NixOS Discourse: https://discourse.nixos.org/
- NixOS Reddit: https://reddit.com/r/NixOS
- NixOS Wiki: https://nixos.wiki/

### Search
- NixOS Search: https://search.nixos.org/
- Home Manager Options: https://nix-community.github.io/home-manager/options.xhtml
- Nix Package Versions: https://lazamar.co.uk/nix-versions/

