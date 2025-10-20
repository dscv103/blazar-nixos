# Template flake.nix for NixOS with flake-parts, niri, NVIDIA, and AMD Ryzen 7 5800X
# 
# Instructions:
# 1. Copy this file to flake.nix in your NixOS directory
# 2. Replace <hostname> with your actual hostname
# 3. Replace <username> with your actual username
# 4. Adjust the system architecture if needed (default: x86_64-linux)
# 5. Customize inputs versions as needed
# 6. Run: nix flake update
# 7. Run: sudo nixos-rebuild switch --flake .#<hostname>

{
  description = "NixOS configuration with flake-parts, niri, NVIDIA, and AMD optimizations";

  # ============================================================================
  # INPUTS - External dependencies
  # ============================================================================
  inputs = {
    # Main package repository
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Alternative: Use stable channel
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    # Flake-parts for modular flake organization
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    # Home Manager for user environment management
    home-manager = {
      url = "github:nix-community/home-manager";
      # For unstable:
      inputs.nixpkgs.follows = "nixpkgs";
      # For stable, use the matching branch:
      # url = "github:nix-community/home-manager/release-24.11";
    };

    # Niri compositor with NixOS integration
    niri-flake = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Optional: Systems helper for flake-parts
    systems.url = "github:nix-systems/default-linux";
  };

  # ============================================================================
  # OUTPUTS - What this flake produces
  # ============================================================================
  outputs = inputs @ { self, nixpkgs, flake-parts, home-manager, niri-flake, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      # Systems this flake supports
      systems = [ "x86_64-linux" ];
      # Add "aarch64-linux" if you need ARM support

      # ========================================================================
      # FLAKE-PARTS MODULES - Import custom packages, overlays, and configs
      # ========================================================================
      # All custom packages and overlays are defined as flake-parts modules
      # This keeps the flake.nix clean and modular
      imports = [
        # Custom packages (exposed as flake.packages.<system>.<name>)
        ./flake-parts/packages.nix

        # Overlays (modifications to nixpkgs)
        ./flake-parts/overlays.nix

        # Development shells
        ./flake-parts/devshells.nix

        # Add more flake-parts modules here as needed
        # ./flake-parts/checks.nix
        # ./flake-parts/apps.nix
      ];

      # Per-system outputs (formatters, dev shells, etc.)
      # Additional perSystem configuration can be added here,
      # but prefer using flake-parts modules (imported above) for better organization
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        # Formatter for nix files (run with: nix fmt)
        formatter = pkgs.nixpkgs-fmt;
        # Alternative formatters:
        # formatter = pkgs.alejandra;
        # formatter = pkgs.nixfmt;
      };

      # Flake-level outputs
      flake = {
        # ======================================================================
        # NIXOS CONFIGURATIONS
        # ======================================================================
        nixosConfigurations = {
          # Replace <hostname> with your actual hostname
          "<hostname>" = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            
            # Special arguments passed to all modules
            specialArgs = { 
              inherit inputs;
              # Add custom arguments here if needed
            };
            
            modules = [
              # ================================================================
              # FLAT IMPORT PATTERN - All modules imported here directly
              # No nested imports within module files
              # ================================================================

              # ----------------------------------------------------------------
              # Host Configuration
              # ----------------------------------------------------------------
              ./hosts/<hostname>/configuration.nix
              ./hosts/<hostname>/hardware-configuration.nix

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
                  users."<username>" = {
                    imports = [
                      # All home modules imported directly here
                      ./home/<username>/home.nix      # Base home-manager config
                      ./home/<username>/niri.nix      # Niri user configuration
                      ./home/<username>/shell.nix     # Shell configuration
                      ./home/<username>/git.nix       # Git configuration
                      ./home/<username>/packages.nix  # User packages
                    ];
                  };

                  # Add more users as needed:
                  # users."anotheruser" = {
                  #   imports = [
                  #     ./home/anotheruser/home.nix
                  #     # ... other modules
                  #   ];
                  # };

                  # Niri home-manager module (optional)
                  sharedModules = [
                    niri-flake.homeManagerModules.niri
                  ];
                };
              }
              
              # ----------------------------------------------------------------
              # Binary cache configuration (optional but recommended)
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
          
          # Add more hosts as needed:
          # "another-host" = nixpkgs.lib.nixosSystem { ... };
        };

        # ======================================================================
        # STANDALONE HOME-MANAGER CONFIGURATIONS (optional)
        # ======================================================================
        # Uncomment if you want standalone home-manager (not as NixOS module)
        # homeConfigurations = {
        #   "<username>@<hostname>" = home-manager.lib.homeManagerConfiguration {
        #     pkgs = nixpkgs.legacyPackages.x86_64-linux;
        #     extraSpecialArgs = { inherit inputs; };
        #     modules = [
        #       ./home/<username>
        #       niri-flake.homeManagerModules.niri
        #     ];
        #   };
        # };
      };
    };
}

# ============================================================================
# NEXT STEPS - Flat Import Pattern
# ============================================================================
#
# 1. Create directory structure:
#    mkdir -p nixos hosts/<hostname> home/<username> flake-parts
#
# 2. Generate hardware configuration:
#    nixos-generate-config --show-hardware-config > hosts/<hostname>/hardware-configuration.nix
#
# 3. Create hosts/<hostname>/configuration.nix (minimal, no imports):
#    { config, pkgs, ... }: {
#      networking.hostName = "<hostname>";
#      system.stateVersion = "24.11";
#    }
#
# 4. Create nixos/*.nix modules (see MODULE_TEMPLATES.md)
#    - Each module is self-contained with NO imports
#    - All modules imported in flake.nix above
#
# 5. Create home/<username>/home.nix (minimal base config):
#    { config, pkgs, ... }: {
#      home.username = "<username>";
#      home.homeDirectory = "/home/<username>";
#      home.stateVersion = "24.11";
#      programs.home-manager.enable = true;
#    }
#
# 6. Create home/<username>/*.nix modules (see MODULE_TEMPLATES.md)
#    - Each module is self-contained with NO imports
#    - All modules imported in flake.nix home-manager.users section
#
# 7. Create flake-parts/*.nix modules (see MODULE_TEMPLATES.md)
#    - packages.nix: Custom package definitions
#    - overlays.nix: Nixpkgs overlays
#    - devshells.nix: Development environments
#    - All imported in flake.nix imports section
#
# 8. Update flake lock:
#    nix flake update
#
# 9. Build configuration:
#    sudo nixos-rebuild build --flake .#<hostname>
#
# 10. If build succeeds, switch to it:
#    sudo nixos-rebuild switch --flake .#<hostname>
#
# 11. Follow IMPLEMENTATION_CHECKLIST.md for complete setup
#
# ============================================================================
# FLAT IMPORT PATTERN RULES
# ============================================================================
#
# ✅ DO:
#   - Import all NixOS modules directly in flake.nix modules list
#   - Import all flake-parts modules in flake.nix imports list
#   - Keep modules self-contained and focused
#   - Use NixOS module system options for inter-module communication
#   - Define custom packages in flake-parts modules
#
# ❌ DON'T:
#   - Add imports = [ ... ] inside NixOS module files
#   - Create nested import hierarchies
#   - Make modules depend on importing other modules
#   - Define packages inline in flake.nix (use flake-parts modules instead)
#
# ============================================================================
# FLAKE-PARTS MODULE PATTERN
# ============================================================================
#
# Flake-parts modules are used for:
#   - Custom package definitions (perSystem.packages)
#   - Overlays (perSystem.overlays or config.flake.overlays)
#   - Development shells (perSystem.devShells)
#   - Checks, apps, and other flake outputs
#
# Benefits:
#   - Keeps flake.nix clean and focused
#   - Modular organization of packages and overlays
#   - Easy to enable/disable features
#   - Reusable across different flakes
#
# Example flake-parts module structure:
#   flake-parts/
#   ├── packages.nix    # Custom package definitions
#   ├── overlays.nix    # Nixpkgs overlays
#   ├── devshells.nix   # Development environments
#   └── checks.nix      # Build checks (optional)
#
# See MODULE_TEMPLATES.md for complete examples
#
# ============================================================================

