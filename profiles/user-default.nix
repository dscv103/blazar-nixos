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
  # IMPORT ALL USER PROFILE MODULES
  # ============================================================================
  # Note: Each profile module defines its own options with lib.mkEnableOption
  # This ensures proper type validation and documentation

  imports = [
    # User profiles
    ./user/productivity.nix
  ];

  # ============================================================================
  # APPLY USER PROFILE CONFIGURATION
  # ============================================================================
  # Load configuration from host-specific profiles.nix and apply defaults

  config = {
    # User profiles
    profiles.user = {
      productivity.enable = lib.mkDefault (userProfiles.productivity.enable or false);
    };
  };
}

