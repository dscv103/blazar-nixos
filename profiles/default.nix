# Profile system loader
# This module loads all profile definitions and applies the configuration
# from hosts/blazar/profiles.nix

{ lib, ... }:

let
  # Load profile configuration from host
  profileConfig = import ../hosts/blazar/profiles.nix;
in
{
  # ============================================================================
  # IMPORT ALL PROFILE MODULES
  # ============================================================================

  imports = [
    # System profiles
    ./system/development.nix
    ./system/multimedia.nix

    # Feature profiles
    ./features/printing.nix
  ];

  # ============================================================================
  # APPLY PROFILE CONFIGURATION
  # ============================================================================

  # System profiles
  profiles.system = {
    development.enable = lib.mkDefault profileConfig.system.development.enable;
    multimedia.enable = lib.mkDefault profileConfig.system.multimedia.enable;
  };

  # Feature profiles
  profiles.features = {
    printing.enable = lib.mkDefault profileConfig.features.printing.enable;
  };
}

