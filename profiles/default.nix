# Profile system loader
# This module loads all profile definitions and applies the configuration
# from the host-specific profiles.nix file

{ lib, hostName, ... }:

let
  # Load profile configuration from host
  profileConfig = import ../hosts/${hostName}/profiles.nix;
in
{
  # ============================================================================
  # IMPORT ALL PROFILE MODULES
  # ============================================================================
  # Note: Each profile module defines its own options with lib.mkEnableOption
  # This ensures proper type validation and documentation
  # Subdirectories have default.nix files that import all modules in that category

  imports = [
    # System profiles (development, multimedia, etc.)
    ./system

    # User profiles (productivity, etc.)
    ./user

    # Feature profiles (printing, virtualization, etc.)
    ./features
  ];

  # ============================================================================
  # APPLY PROFILE CONFIGURATION
  # ============================================================================
  # Load configuration from host-specific profiles.nix and apply defaults

  config = {
    # System profiles
    profiles.system = {
      development.enable = lib.mkDefault profileConfig.system.development.enable;
      multimedia.enable = lib.mkDefault profileConfig.system.multimedia.enable;
    };

    # Feature profiles
    profiles.features = {
      printing.enable = lib.mkDefault profileConfig.features.printing.enable;
    };
  };
}

