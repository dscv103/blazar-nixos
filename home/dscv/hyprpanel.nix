# HyprPanel configuration
# A highly customizable panel for Wayland compositors

{ ... }:

{
  programs.hyprpanel = {
    enable = true;

    # Don't assert notification daemons since we're using HyprPanel's built-in notifications
    # This prevents conflicts with mako
    dontAssertNotificationDaemons = true;

    # HyprPanel configuration
    settings = {
      # ======================================================================
      # BAR LAYOUT
      # ======================================================================
      layout = {
        bar.layouts = {
          # Default monitor layout
          "0" = {
            left = [ "dashboard" "workspaces" "windowtitle" ];
            middle = [ "media" ];
            right = [ "volume" "network" "bluetooth" "battery" "systray" "clock" "notifications" ];
          };
        };
      };

      # ======================================================================
      # BAR MODULES
      # ======================================================================
      bar = {
        launcher.autoDetectIcon = true;
        workspaces.show_icons = true;
      };

      # ======================================================================
      # MENUS
      # ======================================================================
      menus = {
        clock = {
          time = {
            military = true;
            hideSeconds = false;
          };
          weather.unit = "metric";
        };

        dashboard = {
          directories.enabled = true;
          stats.enable_gpu = false; # Set to true if you have NVIDIA GPU with python-gpustat
        };
      };

      # ======================================================================
      # THEME - DRACULA
      # ======================================================================
      theme = {
        # Bar appearance
        bar = {
          transparent = false;
          floating = false;
        };

        # Font configuration
        font = {
          name = "JetBrainsMono Nerd Font";
          size = "14px";
        };

        # Dracula color scheme
        # These colors match the Dracula theme
        # You can import the full Dracula theme from the GUI:
        # Settings > Theming > General Settings > Import > Select dracula.json
        #
        # The Dracula theme file is located in the HyprPanel themes directory
        # After first launch, you can import it through the GUI for full theming
      };
    };
  };
}

