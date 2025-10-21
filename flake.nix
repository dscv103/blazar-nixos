{
  description = "NixOS configuration for blazar - flake-parts, niri, NVIDIA, AMD Ryzen 7 5800X";

  # ================================================================================
  # INPUTS - External dependencies
  # ================================================================================
  inputs = {
    # Main package repository
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Flake-parts for modular flake organization
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    # Home Manager for user environment management
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Niri compositor with NixOS integration
    niri-flake = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Disko for declarative disk partitioning
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Systems helper for flake-parts
    systems.url = "github:nix-systems/default-linux";
  };

  # ================================================================================
  # OUTPUTS - What this flake produces
  # ================================================================================
  outputs = inputs @ { nixpkgs, flake-parts, home-manager, niri-flake, disko, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      # Systems this flake supports
      systems = [ "x86_64-linux" ];

      # ============================================================================
      # FLAKE-PARTS MODULES - Import custom packages, overlays, and configs
      # ============================================================================
      imports = [
        ./flake-parts/packages.nix
        ./flake-parts/overlays.nix
        ./flake-parts/devshells.nix
      ];

      # Per-system outputs
      perSystem = { pkgs, system, ... }: {
        # Configure nixpkgs for this system
        _module.args.pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true; # Allow unfree packages (e.g., graphite-cli)
        };

        # Formatter for nix files (run with: nix fmt)
        formatter = pkgs.nixpkgs-fmt;
      };

      # Flake-level outputs
      flake = {
        # ======================================================================
        # NIXOS CONFIGURATIONS
        # ======================================================================
        nixosConfigurations = {
          blazar = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";

            # Special arguments passed to all modules
            specialArgs = {
              inherit inputs;
              hostName = "blazar"; # Hostname for this configuration
            };

            modules = [
              # ================================================================
              # FLAT IMPORT PATTERN - All modules imported here directly
              # No nested imports within module files
              # ================================================================

              # ----------------------------------------------------------------
              # Host Configuration
              # ----------------------------------------------------------------
              ./hosts/blazar/configuration.nix
              ./hosts/blazar/hardware-configuration.nix
              ./hosts/blazar/disko.nix # Disko disk configuration

              # ----------------------------------------------------------------
              # NixOS System Modules (all imported directly, no nested imports)
              # ----------------------------------------------------------------
              ./nixos/hardware # Hardware-specific configs (CPU, GPU)
              ./nixos/desktop.nix # Niri + XDG portals
              ./nixos/sddm.nix # SDDM display manager with astronaut theme
              ./nixos/boot.nix # Bootloader configuration
              ./nixos/networking.nix # Network configuration
              ./nixos/locale.nix # Locale, timezone, console
              ./nixos/users.nix # User accounts
              ./nixos/audio.nix # PipeWire audio
              ./nixos/packages.nix # System-wide packages
              ./nixos/nix-settings.nix # Nix daemon, binary caches

              # ----------------------------------------------------------------
              # Profile System - Modular feature toggles
              # ----------------------------------------------------------------
              ./profiles/default.nix # System and feature profiles

              # ----------------------------------------------------------------
              # External Modules
              # ----------------------------------------------------------------
              disko.nixosModules.disko # Disko declarative disk partitioning
              niri-flake.nixosModules.niri
              home-manager.nixosModules.home-manager

              # ----------------------------------------------------------------
              # Home Manager Configuration (flat imports for user modules)
              # ----------------------------------------------------------------
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  extraSpecialArgs = {
                    inherit inputs;
                    hostName = "blazar"; # Pass hostname to home-manager modules
                  };

                  # User configurations with flat imports
                  users.dscv = {
                    imports = [
                      # User profile system (home-manager level)
                      ./profiles/user-loader.nix # User profile loader

                      # User configuration modules
                      ./home/dscv/home.nix # Base home-manager config
                      ./home/dscv/fonts.nix # Centralized font configuration
                      ./home/dscv/theme.nix # Dracula theme configuration
                      ./home/dscv/ghostty.nix # Ghostty terminal emulator
                      ./home/dscv/vscode.nix # VSCode with Dracula theme and Maple Mono
                      ./home/dscv/zed.nix # Zed IDE with Dracula theme and Maple Mono
                      ./home/dscv/rofi.nix # Rofi application launcher with Dracula theme
                      ./home/dscv/hyprpanel.nix # HyprPanel configuration
                      ./home/dscv/niri.nix # Niri user configuration
                      ./home/dscv/shell.nix # Shell configuration
                      ./home/dscv/starship.nix # Starship prompt configuration
                      ./home/dscv/direnv.nix # Direnv configuration
                      ./home/dscv/git.nix # Git configuration
                      ./home/dscv/packages.nix # User packages
                      ./profiles/user-default.nix # User profile system
                    ];
                  };
                };
              }

              # ----------------------------------------------------------------
              # Binary cache configuration
              # ----------------------------------------------------------------
              {
                nix.settings = {
                  # Enable flakes and nix-command
                  experimental-features = [ "nix-command" "flakes" ];

                  # Binary caches (speeds up builds significantly)
                  substituters = [
                    "https://cache.nixos.org" # Official NixOS cache
                    "https://niri.cachix.org" # Niri compositor cache
                    "https://nix-community.cachix.org" # Community packages cache
                  ];
                  trusted-public-keys = [
                    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
                    "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
                    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
                  ];

                  # Auto-optimize store
                  auto-optimise-store = true;
                };

                # Garbage collection
                nix.gc = {
                  automatic = true;
                  dates = "weekly";
                  options = "--delete-older-than 30d";
                };
              }
            ];
          };
        };
      };
    };
}

