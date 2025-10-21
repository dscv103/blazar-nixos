# User profile system loader
# This module loads all user profile definitions for home-manager
# Configuration is loaded from the host-specific profiles.nix file

{ config, lib, hostName, ... }:

let
  # Load profile configuration from host
  profileConfig = import ../hosts/${hostName}/profiles.nix;

  # Get current username from config
  inherit (config.home) username;

  # Get user-specific profile config
  userProfiles = profileConfig.users.${username} or { };
in
{
  # ============================================================================
  # OPTIONS - Define user profile types
  # ============================================================================

  options.profiles.user = {
    productivity = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = lib.mdDoc ''
          Enable productivity profile with office and organization tools.
          Includes: LibreOffice, Obsidian, KeePassXC, Syncthing, and productivity applications.
        '';
      };
    };
  };

  # ============================================================================
  # IMPORT ALL USER PROFILE MODULES
  # ============================================================================

  imports = [
    # User profiles
    ./user/productivity.nix
  ];

  # ============================================================================
  # APPLY USER PROFILE CONFIGURATION
  # ============================================================================

  config = {
    # User profiles
    profiles.user = {
      productivity.enable = lib.mkDefault (userProfiles.productivity.enable or false);
    };
  };
}

