# SDDM display manager configuration
# SDDM with astronaut theme for Wayland

{ pkgs
, lib
, ...
}:

let
  # Import host-specific variables
  # Note: This assumes the hostname is "blazar"
  # For multi-host setups, you would pass the host variable
  inherit (import ../hosts/blazar/variables.nix) sddmTheme;

  # Configure sddm-astronaut theme with theme-specific settings
  sddm-astronaut = pkgs.sddm-astronaut.override {
    embeddedTheme = "${sddmTheme}";
    themeConfig =
      if lib.hasSuffix "black_hole" sddmTheme then
        {
          ScreenPadding = "";
          FormPosition = "center"; # left, center, right
        }
      else if lib.hasSuffix "astronaut" sddmTheme then
        {
          PartialBlur = "false";
          FormPosition = "center"; # left, center, right
        }
      else if lib.hasSuffix "purple_leaves" sddmTheme then
        {
          PartialBlur = "false";
        }
      else
        { };
  };
in
{
  # ============================================================================
  # SDDM DISPLAY MANAGER
  # ============================================================================
  services.displayManager = {
    sddm = {
      enable = true;

      # Enable Wayland support
      wayland.enable = true;

      # Enable HiDPI support
      enableHidpi = true;

      # Use KDE's SDDM package for better Wayland support
      package = lib.mkForce pkgs.kdePackages.sddm;

      # Extra packages required for SDDM and the astronaut theme
      extraPackages = [
        sddm-astronaut
        pkgs.kdePackages.qtsvg # SDDM dependency for SVG rendering
        pkgs.kdePackages.qtmultimedia # SDDM dependency for multimedia
        pkgs.kdePackages.qtvirtualkeyboard # SDDM dependency for virtual keyboard
      ];

      # SDDM settings
      settings = {
        Theme = {
          # Use Bibata cursor theme (matches system theme)
          CursorTheme = "Bibata-Modern-Classic";
        };
      };

      # Set the astronaut theme
      theme = "sddm-astronaut-theme";
    };
  };

  # ============================================================================
  # SYSTEM PACKAGES
  # ============================================================================
  environment.systemPackages = [
    sddm-astronaut
    pkgs.kdePackages.qtsvg
    pkgs.kdePackages.qtmultimedia
    pkgs.kdePackages.qtvirtualkeyboard
  ];
}

