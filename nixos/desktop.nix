# ================================================================================
# DESKTOP ENVIRONMENT CONFIGURATION
# ================================================================================
#
# PURPOSE:
#   Configures the Niri Wayland compositor with XDG portals for desktop integration
#   Provides D-Bus, XWayland, and portal services for a complete desktop experience
#
# DEPENDENCIES:
#   - niri-flake (Niri compositor)
#   - XDG desktop portal packages
#   - D-Bus service
#
# USED BY:
#   - Main system configuration (flake.nix)
#
# CONFIGURATION:
#   - Niri compositor enabled
#   - XDG portals for file picker, screenshot, screencast
#   - XWayland for X11 app compatibility
#   - D-Bus for inter-process communication
#
# RELATED FILES:
#   - home/dscv/niri.nix (user-level Niri configuration)
#   - nixos/sddm.nix (display manager)
#
# ================================================================================

{ pkgs, ... }:

{
  # ================================================================================
  # NIRI COMPOSITOR
  # ================================================================================

  # Enable niri (provided by niri-flake)
  programs.niri.enable = true;

  # ================================================================================
  # XDG DESKTOP PORTALS
  # ================================================================================

  # XDG portals for screen sharing, file pickers, etc.
  xdg.portal = {
    enable = true;

    # wlroots portal for Wayland compositors
    wlr.enable = true;

    # Additional portals
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk # GTK file picker and settings
    ];

    # Portal configuration - specify which portal provides each interface
    config = {
      # Common/fallback configuration
      common = {
        default = [ "gtk" ];
      };

      # Niri-specific configuration
      niri = {
        default = [ "wlr" "gtk" ];
      };
    };
  };

  # ================================================================================
  # ESSENTIAL SERVICES
  # ================================================================================
  # Note: Display manager (SDDM) is configured in nixos/sddm.nix
  # Note: XWayland provides X11 compatibility without full X server

  services = {
    # D-Bus for inter-process communication
    dbus.enable = true;
  };

  # XWayland for X11 app compatibility (lightweight alternative to full X server)
  programs.xwayland.enable = true;

  # PolicyKit for privilege escalation
  security.polkit.enable = true;

  # ================================================================================
  # WAYLAND ENVIRONMENT
  # ================================================================================

  # Set Wayland-specific environment variables
  environment.sessionVariables = {
    # Hint to applications to use Wayland
    NIXOS_OZONE_WL = "1"; # For Electron apps
    MOZ_ENABLE_WAYLAND = "1"; # For Firefox
  };
}

