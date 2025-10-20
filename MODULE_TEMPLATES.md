# NixOS Module Templates - Flat Import Pattern
## Self-contained, ready-to-use configuration modules

This document contains template modules following the **flat import pattern**. Each module is self-contained with NO `imports = [ ... ]` statements. All imports happen in `flake.nix`.

---

## Table of Contents

### Part 1: NixOS Modules
1. [Hardware Module (AMD Ryzen 7 5800X)](#hardware-module)
2. [NVIDIA Module](#nvidia-module)
3. [Desktop Module (Niri + Wayland)](#desktop-module)
4. [Boot Module](#boot-module)
5. [Networking Module](#networking-module)
6. [Locale Module](#locale-module)
7. [Users Module](#users-module)
8. [Audio Module (PipeWire)](#audio-module)
9. [Packages Module](#packages-module)
10. [Nix Settings Module](#nix-settings-module)
11. [Host Configuration](#host-configuration)
12. [Home Manager Modules](#home-manager-modules)

### Part 2: Flake-Parts Modules
13. [Flake-Parts: Custom Packages](#flake-parts-packages)
14. [Flake-Parts: Overlays](#flake-parts-overlays)
15. [Flake-Parts: Development Shells](#flake-parts-devshells)

---

## ⚠️ IMPORTANT: Flat Import Pattern Rules

**Each module file:**
- ✅ Contains ONLY its own configuration
- ✅ Is self-contained and focused on one aspect
- ✅ Has NO `imports = [ ... ]` statements
- ✅ Uses NixOS module system options for inter-module communication

**All imports happen in `flake.nix`:**
```nix
modules = [
  ./hosts/<hostname>/configuration.nix
  ./hosts/<hostname>/hardware-configuration.nix
  ./nixos/hardware.nix
  ./nixos/nvidia.nix
  # ... all modules listed explicitly
];
```

---

## Hardware Module
**File**: `nixos/hardware.nix`

**Purpose**: AMD Ryzen 7 5800X CPU configuration and optimizations

```nix
# AMD Ryzen 7 5800X hardware configuration
# Self-contained module - NO imports
{ config, lib, pkgs, ... }:

{
  # AMD CPU microcode updates
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Enable KVM virtualization
  boot.kernelModules = [ "kvm-amd" ];

  # CPU frequency governor
  # Options: "powersave", "performance", "schedutil", "ondemand"
  powerManagement.cpuFreqGovernor = lib.mkDefault "schedutil";

  # AMD-specific kernel parameters
  boot.kernelParams = [
    # Use AMD P-State driver (requires kernel 6.1+)
    "amd_pstate=active"

    # Optional: Reduce latency for gaming/real-time applications
    # "processor.max_cstate=1"
  ];

  # Enable all firmware
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;

  # Platform
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
```

---

## NVIDIA Module
**File**: `nixos/nvidia.nix`

**Purpose**: NVIDIA driver configuration with Wayland support

```nix
# NVIDIA driver configuration with Wayland support
# Self-contained module - NO imports
{ config, lib, pkgs, ... }:

{
  # Enable NVIDIA drivers
  services.xserver.videoDrivers = [ "nvidia" ];
  
  # NVIDIA driver configuration
  hardware.nvidia = {
    # Modesetting is REQUIRED for Wayland
    modesetting.enable = true;
    
    # Power management (experimental, may cause issues)
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    
    # Use open source kernel module (currently beta, use false for stability)
    open = false;
    
    # Enable nvidia-settings GUI
    nvidiaSettings = true;
    
    # Driver package selection
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    # Alternatives:
    # package = config.boot.kernelPackages.nvidiaPackages.beta;
    # package = config.boot.kernelPackages.nvidiaPackages.production;
    # package = config.boot.kernelPackages.nvidiaPackages.latest;
    
    # Enable GSP firmware (for RTX 20/30/40 series)
    # gsp.enable = true;
    
    # Force full composition pipeline (may fix screen tearing)
    # WARNING: Can reduce performance and cause issues with some applications
    # forceFullCompositionPipeline = false;
  };
  
  # Graphics/OpenGL support
  hardware.graphics = {
    enable = true;
    enable32Bit = true;  # Required for 32-bit applications (Steam, Wine)
  };
  
  # Kernel parameters for NVIDIA + Wayland
  boot.kernelParams = [
    "nvidia-drm.modeset=1"  # CRITICAL for Wayland support
    "nvidia-drm.fbdev=1"    # Enable framebuffer device (kernel 6.6+)
    # "nvidia.NVreg_PreserveVideoMemoryAllocations=1"  # For suspend/resume
  ];
  
  # Environment variables for NVIDIA + Wayland
  environment.sessionVariables = {
    # NVIDIA-specific
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    
    # Wayland compatibility
    WLR_NO_HARDWARE_CURSORS = "1";  # Fix cursor issues
    
    # Optional: Enable VRR/G-Sync
    __GL_GSYNC_ALLOWED = "1";
    __GL_VRR_ALLOWED = "1";
    
    # Optional: NVIDIA threaded optimization
    # __GL_THREADED_OPTIMIZATION = "1";
  };
}
```

---

## Desktop Module
**File**: `nixos/desktop.nix`

**Purpose**: Niri compositor, Wayland, XDG portals, and display manager

```nix
# Niri compositor and Wayland desktop environment
# Self-contained module - NO imports
{ config, lib, pkgs, ... }:

{
  # Enable niri compositor
  programs.niri.enable = true;
  
  # XDG Desktop Portal configuration
  xdg.portal = {
    enable = true;
    wlr.enable = true;  # wlroots-based portal for niri
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk  # GTK file picker and settings
      # xdg-desktop-portal-gnome  # Alternative: GNOME portal
    ];
    config = {
      common = {
        default = "*";
      };
      niri = {
        default = [ "wlr" "gtk" ];
      };
    };
  };
  
  # Display manager - greetd with tuigreet
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd niri-session";
        user = "greeter";
      };
    };
  };
  
  # Alternative: SDDM with Wayland support
  # services.displayManager.sddm = {
  #   enable = true;
  #   wayland.enable = true;
  # };
  
  # Essential services
  security.polkit.enable = true;
  services.dbus.enable = true;
  
  # Enable Wayland-specific programs
  programs.xwayland.enable = true;  # For X11 app compatibility
  
  # Optional: Enable screen sharing
  services.pipewire.enable = true;  # Required for screen sharing
  
  # Fonts
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      # (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
    ];
    
    fontconfig = {
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        monospace = [ "Fira Code" ];
      };
    };
  };
}
```

---

## System Module
**File**: `modules/nixos/system.nix`

```nix
# Core system configuration
{ config, lib, pkgs, ... }:

{
  # Bootloader configuration
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;  # Keep last 10 generations
    };
    efi.canTouchEfiVariables = true;
  };
  
  # Alternative: GRUB bootloader
  # boot.loader.grub = {
  #   enable = true;
  #   device = "nodev";
  #   efiSupport = true;
  #   useOSProber = true;  # Detect other operating systems
  # };
  
  # Kernel selection
  # boot.kernelPackages = pkgs.linuxPackages_latest;  # Latest kernel
  # boot.kernelPackages = pkgs.linuxPackages;  # Default stable kernel
  
  # Networking
  networking = {
    networkmanager.enable = true;
    # Alternative: Use systemd-networkd
    # useNetworkd = true;
    
    # Firewall
    firewall = {
      enable = true;
      # allowedTCPPorts = [ 22 80 443 ];
      # allowedUDPPorts = [ ];
    };
  };
  
  # Time zone
  time.timeZone = "America/New_York";  # Change to your timezone
  
  # Locale
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };
  
  # Console configuration
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";  # Change to your keyboard layout
    # useXkbConfig = true;  # Use X11 keymap for console
  };
  
  # System packages
  environment.systemPackages = with pkgs; [
    # Essential utilities
    vim
    wget
    curl
    git
    htop
    btop
    
    # Wayland utilities
    wayland-utils
    wev  # Wayland event viewer
    
    # Terminal emulator
    foot
    
    # Application launcher
    fuzzel
    
    # Status bar
    waybar
    
    # Notifications
    mako
    
    # Screenshots
    grim
    slurp
    swappy
    
    # Clipboard
    wl-clipboard
    cliphist
    
    # File manager
    nautilus
    
    # Lock screen
    swaylock
    
    # System information
    neofetch
    lshw
    pciutils
    usbutils
  ];
  
  # NixOS version
  system.stateVersion = "24.11";  # Don't change this after installation
}
```

---

## Users Module
**File**: `modules/nixos/users.nix`

```nix
# User account configuration
{ config, lib, pkgs, ... }:

{
  # Define user accounts
  users.users = {
    # Replace <username> with your actual username
    "<username>" = {
      isNormalUser = true;
      description = "Your Full Name";
      
      # User groups
      extraGroups = [
        "wheel"          # sudo access
        "networkmanager" # network management
        "video"          # video devices
        "audio"          # audio devices
        "input"          # input devices
        "storage"        # storage devices
        # "docker"       # Docker (if using)
        # "libvirtd"     # Virtualization (if using)
      ];
      
      # Initial password (change after first login!)
      initialPassword = "changeme";
      
      # Or use hashed password (generate with: mkpasswd -m sha-512)
      # hashedPassword = "$6$rounds=656000$...";
      
      # Default shell
      shell = pkgs.bash;
      # Alternatives:
      # shell = pkgs.zsh;
      # shell = pkgs.fish;
    };
    
    # Add more users as needed
    # "anotheruser" = { ... };
  };
  
  # Enable sudo without password for wheel group (optional, less secure)
  # security.sudo.wheelNeedsPassword = false;
}
```

---

## Audio Module
**File**: `modules/nixos/audio.nix`

```nix
# PipeWire audio configuration
{ config, lib, pkgs, ... }:

{
  # Enable sound
  sound.enable = true;
  
  # Enable rtkit for real-time scheduling
  security.rtkit.enable = true;
  
  # PipeWire configuration
  services.pipewire = {
    enable = true;
    
    # ALSA support
    alsa = {
      enable = true;
      support32Bit = true;  # For 32-bit applications
    };
    
    # PulseAudio compatibility
    pulse.enable = true;
    
    # JACK support (for professional audio)
    jack.enable = true;
    
    # WirePlumber session manager (default)
    # wireplumber.enable = true;
  };
  
  # Optional: Disable PulseAudio (PipeWire provides compatibility)
  hardware.pulseaudio.enable = false;
  
  # Optional: Bluetooth audio support
  # hardware.bluetooth.enable = true;
  # services.blueman.enable = true;
}
```

---

## Host Configuration
**File**: `hosts/<hostname>/default.nix`

```nix
# Host-specific configuration
{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    # Hardware configuration (generated by nixos-generate-config)
    ./hardware-configuration.nix
    
    # System modules
    ../../modules/nixos/hardware.nix
    ../../modules/nixos/nvidia.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/system.nix
    ../../modules/nixos/users.nix
    ../../modules/nixos/audio.nix
  ];
  
  # Hostname
  networking.hostName = "<hostname>";  # Replace with your hostname
  
  # Host-specific settings
  # Add any configuration specific to this machine here
  
  # Example: Host-specific kernel parameters
  # boot.kernelParams = [ "quiet" "splash" ];
  
  # Example: Host-specific packages
  # environment.systemPackages = with pkgs; [
  #   # Add host-specific packages here
  # ];
  
  # NixOS version (don't change after installation)
  system.stateVersion = "24.11";
}
```

---

## Home Manager Configuration
**File**: `home/<username>/default.nix`

```nix
# Home Manager configuration for <username>
{ config, lib, pkgs, inputs, ... }:

{
  # User information
  home.username = "<username>";  # Replace with your username
  home.homeDirectory = "/home/<username>";  # Replace with your username
  
  # Home Manager version (should match system.stateVersion)
  home.stateVersion = "24.11";
  
  # Let Home Manager manage itself
  programs.home-manager.enable = true;
  
  # User packages
  home.packages = with pkgs; [
    # Web browser
    firefox
    
    # Development
    vscode
    
    # Media
    mpv
    imv
    
    # Utilities
    ripgrep
    fd
    eza
    bat
    
    # Add your preferred packages here
  ];
  
  # Niri configuration (if using niri-flake home module)
  programs.niri = {
    # config = {
    #   # Niri configuration in Nix format
    #   # See niri-flake documentation
    # };
  };
  
  # Alternative: Raw niri config file
  home.file.".config/niri/config.kdl".text = ''
    // Niri configuration in KDL format
    // See: https://github.com/YaLTeR/niri/wiki/Configuration:-Overview
    
    input {
        keyboard {
            xkb {
                layout "us"
            }
        }
        
        touchpad {
            tap
            natural-scroll
        }
    }
    
    output "DP-1" {
        mode "1920x1080@144"
    }
    
    layout {
        gaps 8
        center-focused-column "never"
    }
    
    binds {
        Mod+T { spawn "foot"; }
        Mod+D { spawn "fuzzel"; }
        Mod+Q { close-window; }
        
        Mod+Left { focus-column-left; }
        Mod+Right { focus-column-right; }
        Mod+Up { focus-window-up; }
        Mod+Down { focus-window-down; }
        
        Mod+Shift+Left { move-column-left; }
        Mod+Shift+Right { move-column-right; }
        Mod+Shift+Up { move-window-up; }
        Mod+Shift+Down { move-window-down; }
        
        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }
        
        Mod+Shift+1 { move-window-to-workspace 1; }
        Mod+Shift+2 { move-window-to-workspace 2; }
        Mod+Shift+3 { move-window-to-workspace 3; }
        Mod+Shift+4 { move-window-to-workspace 4; }
    }
  '';
  
  # Git configuration
  programs.git = {
    enable = true;
    userName = "Your Name";
    userEmail = "your.email@example.com";
  };
  
  # Shell configuration (bash example)
  programs.bash = {
    enable = true;
    shellAliases = {
      ll = "ls -la";
      ".." = "cd ..";
      rebuild = "sudo nixos-rebuild switch --flake ~/NixOS#<hostname>";
    };
  };
}
```

---

## Usage Instructions

1. **Create the directory structure**:
   ```bash
   mkdir -p modules/nixos modules/home-manager hosts/<hostname> home/<username>
   ```

2. **Copy templates**:
   - Copy each module template to its respective file
   - Replace `<hostname>` and `<username>` with actual values

3. **Generate hardware configuration**:
   ```bash
   nixos-generate-config --show-hardware-config > hosts/<hostname>/hardware-configuration.nix
   ```

4. **Customize**:
   - Adjust settings in each module to match your preferences
   - Enable/disable optional features as needed

5. **Build and test**:
   ```bash
   sudo nixos-rebuild build --flake .#<hostname>
   sudo nixos-rebuild switch --flake .#<hostname>
   ```

---

# Part 2: Flake-Parts Modules

Flake-parts modules are used to organize custom packages, overlays, and development environments. These modules are imported in the `imports` section of your flake-parts configuration.

---

## Flake-Parts: Custom Packages
**File**: `flake-parts/packages.nix`

**Purpose**: Define custom packages that will be available as `nix build .#<package-name>`

```nix
# Custom package definitions as a flake-parts module
# This module exposes packages via perSystem.packages
{ inputs, ... }:

{
  perSystem = { config, self', inputs', pkgs, system, lib, ... }: {
    # Custom packages available as: nix build .#<name>
    packages = {
      # Example: Custom hello package
      my-hello = pkgs.stdenv.mkDerivation {
        pname = "my-hello";
        version = "1.0.0";

        src = pkgs.fetchFromGitHub {
          owner = "example";
          repo = "hello";
          rev = "v1.0.0";
          sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
        };

        buildInputs = with pkgs; [ ];

        installPhase = ''
          mkdir -p $out/bin
          cp hello $out/bin/
        '';

        meta = with lib; {
          description = "Custom hello program";
          license = licenses.mit;
          platforms = platforms.linux;
        };
      };

      # Example: Python package with custom dependencies
      my-python-tool = pkgs.python3Packages.buildPythonApplication {
        pname = "my-python-tool";
        version = "0.1.0";

        src = ./path/to/source;

        propagatedBuildInputs = with pkgs.python3Packages; [
          requests
          click
        ];

        meta = with lib; {
          description = "Custom Python tool";
          license = licenses.mit;
        };
      };

      # Example: Wrapper script
      my-script = pkgs.writeShellScriptBin "my-script" ''
        #!${pkgs.bash}/bin/bash
        echo "Hello from custom script!"
        ${pkgs.neofetch}/bin/neofetch
      '';

      # Add more custom packages here
    };
  };
}
```

**Usage**:
- Build: `nix build .#my-hello`
- Run: `nix run .#my-hello`
- Install in NixOS: Add to `environment.systemPackages = [ self'.packages.my-hello ];`
- Install in Home Manager: Add to `home.packages = [ self'.packages.my-hello ];`

---

## Flake-Parts: Overlays
**File**: `flake-parts/overlays.nix`

**Purpose**: Modify or add packages to nixpkgs

```nix
# Overlays as a flake-parts module
# Overlays modify the pkgs set available throughout your configuration
{ inputs, ... }:

{
  perSystem = { config, self', inputs', pkgs, system, lib, ... }: {
    # Define overlays that modify nixpkgs
    # These are automatically applied to pkgs in perSystem
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = [
        # Overlay 1: Modify existing package
        (final: prev: {
          # Override neovim with custom configuration
          neovim = prev.neovim.override {
            viAlias = true;
            vimAlias = true;
          };
        })

        # Overlay 2: Add custom packages
        (final: prev: {
          # Add a custom package to nixpkgs
          my-custom-pkg = prev.callPackage ./pkgs/my-custom-pkg { };
        })

        # Overlay 3: Update package version
        (final: prev: {
          # Use a newer version from a different source
          firefox-nightly = prev.firefox.overrideAttrs (old: {
            version = "nightly";
            src = prev.fetchurl {
              url = "https://example.com/firefox-nightly.tar.bz2";
              sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
            };
          });
        })
      ];
      config.allowUnfree = true;
    };
  };

  # Alternative: Export overlays for use in NixOS configuration
  flake = {
    overlays = {
      default = final: prev: {
        # Your overlay definitions here
        my-package = prev.callPackage ./pkgs/my-package { };
      };

      # Named overlays
      custom-packages = final: prev: {
        # Custom packages overlay
      };
    };
  };
}
```

**Usage in NixOS configuration**:
```nix
# In your NixOS module or flake.nix
{
  nixpkgs.overlays = [
    inputs.self.overlays.default
    # or
    inputs.self.overlays.custom-packages
  ];
}
```

---

## Flake-Parts: Development Shells
**File**: `flake-parts/devshells.nix`

**Purpose**: Define development environments for different projects

```nix
# Development shells as a flake-parts module
# Available via: nix develop .#<shell-name>
{ inputs, ... }:

{
  perSystem = { config, self', inputs', pkgs, system, lib, ... }: {
    # Development shells
    devShells = {
      # Default development shell (nix develop)
      default = pkgs.mkShell {
        name = "nixos-config-dev";

        buildInputs = with pkgs; [
          # Nix tools
          nixpkgs-fmt
          nil  # Nix language server
          nix-tree
          nix-diff

          # Version control
          git
          gh  # GitHub CLI

          # Editors
          vim

          # Utilities
          jq
          yq
        ];

        shellHook = ''
          echo "🚀 NixOS Configuration Development Environment"
          echo "Available commands:"
          echo "  - nixpkgs-fmt: Format Nix files"
          echo "  - nil: Nix language server"
          echo "  - nix-tree: Explore dependency trees"
          echo ""
        '';
      };

      # Python development shell
      python = pkgs.mkShell {
        name = "python-dev";

        buildInputs = with pkgs; [
          python311
          python311Packages.pip
          python311Packages.virtualenv
          python311Packages.pytest
          python311Packages.black
          python311Packages.mypy
        ];

        shellHook = ''
          echo "🐍 Python Development Environment"
          python --version
        '';
      };

      # Rust development shell
      rust = pkgs.mkShell {
        name = "rust-dev";

        buildInputs = with pkgs; [
          rustc
          cargo
          rustfmt
          clippy
          rust-analyzer
        ];

        shellHook = ''
          echo "🦀 Rust Development Environment"
          rustc --version
          cargo --version
        '';
      };

      # Web development shell
      web = pkgs.mkShell {
        name = "web-dev";

        buildInputs = with pkgs; [
          nodejs_20
          nodePackages.npm
          nodePackages.typescript
          nodePackages.typescript-language-server
          nodePackages.prettier
        ];

        shellHook = ''
          echo "🌐 Web Development Environment"
          node --version
          npm --version
        '';
      };
    };
  };
}
```

**Usage**:
- Enter default shell: `nix develop`
- Enter named shell: `nix develop .#python`
- Run command in shell: `nix develop .#rust -c cargo build`

---

## Flake-Parts Module Best Practices

### 1. **Separation of Concerns**
- Keep packages, overlays, and dev shells in separate files
- One flake-parts module per concern

### 2. **Naming Conventions**
- Use descriptive names for packages: `my-project-name`
- Prefix custom packages to avoid conflicts: `custom-*`
- Use kebab-case for package names

### 3. **Documentation**
- Add comments explaining what each package does
- Include usage examples in comments
- Document dependencies and build requirements

### 4. **Testing**
- Test packages with `nix build .#<package-name>`
- Test dev shells with `nix develop .#<shell-name>`
- Use `nix flake check` to validate

### 5. **Reusability**
- Make packages configurable with function arguments
- Use `callPackage` pattern for complex packages
- Export overlays for use in other flakes

---

## Notes

- All NixOS module templates use `lib.mkDefault` where appropriate to allow easy overriding
- Flake-parts modules are imported in the `imports` section of flake.nix
- Comments indicate optional features and alternatives
- Adjust kernel parameters, packages, and settings to your needs
- Test each module individually before combining them all

---

For complete implementation guidance, see [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md) and [IMPLEMENTATION_CHECKLIST.md](IMPLEMENTATION_CHECKLIST.md).

