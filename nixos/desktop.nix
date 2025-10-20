# Desktop environment configuration
# Niri compositor with XDG portals and display manager

{ config, lib, pkgs, ... }:

{
  # ============================================================================
  # NIRI COMPOSITOR
  # ============================================================================
  
  # Enable niri (provided by niri-flake)
  programs.niri.enable = true;

  # ============================================================================
  # XDG DESKTOP PORTALS
  # ============================================================================
  
  # XDG portals for screen sharing, file pickers, etc.
  xdg.portal = {
    enable = true;
    
    # wlroots portal for Wayland compositors
    wlr.enable = true;
    
    # Additional portals
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk  # GTK file picker and settings
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

  # ============================================================================
  # DISPLAY MANAGER - GREETD with TUIGREET
  # ============================================================================
  
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd niri-session";
        user = "greeter";
      };
    };
  };

  # Alternative: SDDM (uncomment if preferred)
  # services.displayManager.sddm = {
  #   enable = true;
  #   wayland.enable = true;
  # };

  # ============================================================================
  # ESSENTIAL SERVICES
  # ============================================================================
  
  # PolicyKit for privilege escalation
  security.polkit.enable = true;

  # D-Bus for inter-process communication
  services.dbus.enable = true;

  # Enable X server (required for some compatibility)
  services.xserver.enable = true;

  # ============================================================================
  # WAYLAND ENVIRONMENT
  # ============================================================================
  
  # Set Wayland-specific environment variables
  environment.sessionVariables = {
    # Hint to applications to use Wayland
    NIXOS_OZONE_WL = "1";  # For Electron apps
    MOZ_ENABLE_WAYLAND = "1";  # For Firefox
  };
}

