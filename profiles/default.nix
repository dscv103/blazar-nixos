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
  # OPTIONS - Define profile types
  # ============================================================================

  options.profiles.system = {
    development = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = lib.mdDoc ''
          Enable development profile with Docker, databases, and development tools.
          Includes: Docker, PostgreSQL, Redis, development packages, and kernel parameters.
        '';
      };
    };

    multimedia = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = lib.mdDoc ''
          Enable multimedia profile with OBS, video editing, and audio production tools.
          Includes: OBS Studio, Kdenlive, Audacity, GIMP, and multimedia codecs.
        '';
      };
    };
  };

  options.profiles.features = {
    printing = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = lib.mdDoc ''
          Enable printing and scanning support with CUPS.
          Includes: CUPS printing service, Avahi for network printer discovery, and SANE for scanners.
        '';
      };
    };
  };

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

