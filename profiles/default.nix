# ================================================================================
# PROFILE SYSTEM LOADER
# ================================================================================
#
# PURPOSE:
#   Central loader for the profile system that enables/disables feature sets
#   Loads configuration from host-specific profiles.nix and applies defaults
#
# DEPENDENCIES:
#   - hostName (passed via specialArgs)
#   - hosts/${hostName}/profiles.nix (profile configuration)
#   - Profile modules in system/, user/, features/ subdirectories
#
# USED BY:
#   - Main system configuration (flake.nix)
#
# CONFIGURATION:
#   Profiles are defined in hosts/${hostName}/profiles.nix with structure:
#   {
#     system = { development.enable = true; multimedia.enable = false; };
#     features = { printing.enable = true; };
#     users.${username} = { productivity.enable = true; };
#   }
#
# PROFILE CATEGORIES:
#   - system/    - System-level profiles (development, multimedia)
#   - user/      - User-level profiles (productivity)
#   - features/  - Optional features (printing, virtualization)
#
# RELATED FILES:
#   - hosts/${hostName}/profiles.nix (profile configuration)
#   - profiles/system/default.nix (system profile imports)
#   - profiles/user/default.nix (user profile imports)
#   - profiles/features/default.nix (feature profile imports)
#
# ================================================================================

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

