# Profile system loader
# This module loads all profile definitions and applies the configuration
# from hosts/blazar/profiles.nix

{ config, lib, pkgs, ... }:

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
    ./system/gaming.nix
    ./system/development.nix
    ./system/multimedia.nix
    
    # Feature profiles
    ./features/bluetooth.nix
    ./features/printing.nix
  ];

  # ============================================================================
  # APPLY PROFILE CONFIGURATION
  # ============================================================================
  
  # System profiles
  profiles.system = {
    gaming.enable = lib.mkDefault profileConfig.system.gaming.enable;
    development.enable = lib.mkDefault profileConfig.system.development.enable;
    multimedia.enable = lib.mkDefault profileConfig.system.multimedia.enable;
  };

  # Feature profiles
  profiles.features = {
    bluetooth.enable = lib.mkDefault profileConfig.features.bluetooth.enable;
    printing.enable = lib.mkDefault profileConfig.features.printing.enable;
  };
}

