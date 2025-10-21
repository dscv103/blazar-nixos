# User profile system loader
# This module loads all user profile definitions for home-manager
# Configuration is loaded from hosts/blazar/profiles.nix

{ config, lib, ... }:

let
  # Load profile configuration from host
  profileConfig = import ../hosts/blazar/profiles.nix;

  # Get current username from config
  inherit (config.home) username;

  # Get user-specific profile config
  userProfiles = profileConfig.users.${username} or { };
in
{
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

  # User profiles
  profiles.user = {
    productivity.enable = lib.mkDefault (userProfiles.productivity.enable or false);
  };
}

