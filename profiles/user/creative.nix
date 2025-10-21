# Creative profile - User-level creative applications
# Includes GIMP, Inkscape, Krita, and other creative tools

{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.user.creative;
in
{
  options.profiles.user.creative = {
    enable = lib.mkEnableOption "creative profile with GIMP, Inkscape, Krita, etc.";
  };

  config = lib.mkIf cfg.enable {
    # ========================================================================
    # CREATIVE PACKAGES
    # ========================================================================
    
    home.packages = with pkgs; [
      # Image editing
      gimp # GNU Image Manipulation Program
      krita # Digital painting
      
      # Vector graphics
      inkscape # Vector graphics editor
      
      # Photo management
      darktable # Photography workflow
      rawtherapee # RAW photo processor
      
      # 3D modeling (if not in system/multimedia.nix)
      # blender
      
      # Color picking
      gcolor3 # Color picker
      
      # Font management
      font-manager
      
      # Screenshot annotation
      flameshot # Screenshot tool with annotation
      
      # PDF editing
      pdfarranger # Rearrange PDF pages
      
      # Design tools
      # figma-linux # Figma desktop app (unofficial)
      
      # Animation
      # synfigstudio # 2D animation
      
      # Video editing (lightweight)
      # openshot-qt
    ];

    # ========================================================================
    # PROGRAM CONFIGURATIONS
    # ========================================================================
    
    # GIMP configuration
    # xdg.configFile."GIMP/2.10/gimprc".text = ''
    #   # Custom GIMP settings
    # '';

    # Inkscape configuration
    # xdg.configFile."inkscape/preferences.xml".text = ''
    #   # Custom Inkscape settings
    # '';
  };
}

