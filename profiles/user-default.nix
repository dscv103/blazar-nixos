# User profile system loader
# This module loads all user profile definitions for home-manager
# Configuration is loaded from hosts/blazar/profiles.nix

{ config, lib, pkgs, ... }:

let
  # Load profile configuration from host
  profileConfig = import ../hosts/blazar/profiles.nix;
  
  # Get current username from config
  username = config.home.username;
  
  # Get user-specific profile config
  userProfiles = profileConfig.users.${username} or {};
in
{
  # ============================================================================
  # IMPORT ALL USER PROFILE MODULES
  # ============================================================================
  
  imports = [
    # User profiles
    ./user/creative.nix
    ./user/productivity.nix
    ./user/communication.nix
  ];

  # ============================================================================
  # APPLY USER PROFILE CONFIGURATION
  # ============================================================================
  
  # User profiles
  profiles.user = {
    creative.enable = lib.mkDefault (userProfiles.creative.enable or false);
    productivity.enable = lib.mkDefault (userProfiles.productivity.enable or false);
    communication.enable = lib.mkDefault (userProfiles.communication.enable or false);
  };
}

