# ================================================================================
# USER PROFILE LOADER (Home Manager)
# ================================================================================
#
# PURPOSE:
#   Loads user-level profiles for home-manager configuration
#   Applies profile settings from host-specific profiles.nix
#
# DEPENDENCIES:
#   - hostName (passed via home-manager extraSpecialArgs)
#   - hosts/${hostName}/profiles.nix (profile configuration)
#   - Profile modules in user/ subdirectory
#
# USED BY:
#   - Home-manager user configuration (flake.nix)
#
# CONFIGURATION:
#   User profiles are defined in hosts/${hostName}/profiles.nix with structure:
#   {
#     users.${username} = {
#       productivity.enable = true;
#       minimal.enable = false;
#     };
#   }
#
# RELATED FILES:
#   - hosts/${hostName}/profiles.nix (profile configuration)
#   - profiles/user/default.nix (user profile imports)
#   - profiles/default.nix (NixOS-level profiles)
#
# ================================================================================

{ lib, hostName, config, ... }:

let
  # Load profile configuration from host
  profileConfig = import ../hosts/${hostName}/profiles.nix;

  # Get the current username from home-manager
  inherit (config.home) username;

  # Get user-specific profile config, default to empty if not defined
  userProfileConfig = profileConfig.users.${username} or { };
in
{
  # ============================================================================
  # IMPORT USER PROFILE MODULES
  # ============================================================================
  imports = [
    ./user
  ];

  # ============================================================================
  # APPLY USER PROFILE CONFIGURATION
  # ============================================================================
  config = {
    # User profiles (only apply if defined for this user)
    profiles.user = {
      productivity.enable = lib.mkDefault (userProfileConfig.productivity.enable or false);
      # Add other user profiles here as they are created
      # minimal.enable = lib.mkDefault (userProfileConfig.minimal.enable or false);
    };
  };
}

