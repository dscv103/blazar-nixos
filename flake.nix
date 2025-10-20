{
  description = "NixOS configuration for blazar - flake-parts, niri, NVIDIA, AMD Ryzen 7 5800X";

  # ============================================================================
  # INPUTS - External dependencies
  # ============================================================================
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

    # Systems helper for flake-parts
    systems.url = "github:nix-systems/default-linux";
  };

  # ============================================================================
  # OUTPUTS - What this flake produces
  # ============================================================================
  outputs = inputs @ { self, nixpkgs, flake-parts, home-manager, niri-flake, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      # Systems this flake supports
      systems = [ "x86_64-linux" ];

      # ========================================================================
      # FLAKE-PARTS MODULES - Import custom packages, overlays, and configs
      # ========================================================================
      imports = [
        ./flake-parts/packages.nix
        ./flake-parts/overlays.nix
        ./flake-parts/devshells.nix
      ];

      # Per-system outputs
      perSystem = { config, self', inputs', pkgs, system, ... }: {
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

              # ----------------------------------------------------------------
              # NixOS System Modules (all imported directly, no nested imports)
              # ----------------------------------------------------------------
              ./nixos/hardware.nix      # AMD Ryzen 7 5800X configuration
              ./nixos/nvidia.nix        # NVIDIA drivers + Wayland
              ./nixos/desktop.nix       # Niri + XDG portals + display manager
              ./nixos/boot.nix          # Bootloader configuration
              ./nixos/networking.nix    # Network configuration
              ./nixos/locale.nix        # Locale, timezone, console
              ./nixos/users.nix         # User accounts
              ./nixos/audio.nix         # PipeWire audio
              ./nixos/packages.nix      # System-wide packages
              ./nixos/nix-settings.nix  # Nix daemon, binary caches

              # ----------------------------------------------------------------
              # External Modules
              # ----------------------------------------------------------------
              niri-flake.nixosModules.niri
              home-manager.nixosModules.home-manager

              # ----------------------------------------------------------------
              # Home Manager Configuration (flat imports for user modules)
              # ----------------------------------------------------------------
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  extraSpecialArgs = { inherit inputs; };

                  # User configurations with flat imports
                  users.dscv = {
                    imports = [
                      ./home/dscv/home.nix      # Base home-manager config
                      ./home/dscv/niri.nix      # Niri user configuration
                      ./home/dscv/shell.nix     # Shell configuration
                      ./home/dscv/git.nix       # Git configuration
                      ./home/dscv/packages.nix  # User packages
                    ];
                  };

                  # Niri home-manager module
                  sharedModules = [
                    niri-flake.homeManagerModules.niri
                  ];
                };
              }
              
              # ----------------------------------------------------------------
              # Binary cache configuration
              # ----------------------------------------------------------------
              {
                nix.settings = {
                  # Enable flakes and nix-command
                  experimental-features = [ "nix-command" "flakes" ];
                  
                  # Niri binary cache (speeds up builds)
                  substituters = [
                    "https://cache.nixos.org"
                    "https://niri.cachix.org"
                  ];
                  trusted-public-keys = [
                    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
                    "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
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

