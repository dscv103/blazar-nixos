# ================================================================================
# FONT CONFIGURATION
# ================================================================================
# Centralized font management for all applications
# Used by: Ghostty, VSCode, Zed, and other terminal/editor applications

{ pkgs, ... }:

{
  # ================================================================================
  # FONT PACKAGES
  # ================================================================================
  home.packages = with pkgs; [
    maple-mono.NF # Maple Mono NerdFont - includes all icons and ligatures
  ];

  # ================================================================================
  # FONT CONFIGURATION
  # ================================================================================
  # Make fonts available to the system
  fonts.fontconfig.enable = true;
}

