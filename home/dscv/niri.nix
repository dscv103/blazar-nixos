# Niri user configuration
# Keybindings, workspaces, window rules, and appearance

{ config, pkgs, lib, ... }:

{
  # Niri configuration using the niri-flake home-manager module
  programs.niri.settings = {
    # ========================================================================
    # INPUTS
    # ========================================================================
    input = {
      keyboard = {
        xkb = {
          layout = "us";
          # variant = "";
          # options = "";
        };
        repeat-delay = 600;
        repeat-rate = 25;
      };

      touchpad = {
        tap = true;
        natural-scroll = true;
        dwt = true;  # Disable while typing
      };

      mouse = {
        natural-scroll = false;
        accel-speed = 0.0;
      };

      # Disable hardware cursor if you experience cursor issues with NVIDIA
      # warp-mouse-to-focus = true;
    };

    # ========================================================================
    # OUTPUTS (MONITORS)
    # ========================================================================
    outputs = {
      # Example output configuration
      # Replace with your actual monitor names (use `niri msg outputs` to list)
      # "DP-1" = {
      #   mode = {
      #     width = 2560;
      #     height = 1440;
      #     refresh = 144.0;
      #   };
      #   position = {
      #     x = 0;
      #     y = 0;
      #   };
      #   scale = 1.0;
      # };
    };

    # ========================================================================
    # LAYOUT
    # ========================================================================
    layout = {
      gaps = 8;
      center-focused-column = "never";
      preset-column-widths = [
        { proportion = 0.33333; }
        { proportion = 0.5; }
        { proportion = 0.66667; }
      ];
      default-column-width = { proportion = 0.5; };
      focus-ring = {
        enable = true;
        width = 2;
        active-color = "#7fc8ff";
        inactive-color = "#505050";
      };
      border = {
        enable = true;
        width = 1;
        active-color = "#ffc87f";
        inactive-color = "#505050";
      };
    };

    # ========================================================================
    # PREFER NO CSDPREFER NO CSD (Client-Side Decorations)
    # ========================================================================
    prefer-no-csd = true;

    # ========================================================================
    # SCREENSHOT PATH
    # ========================================================================
    screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

    # ========================================================================
    # ANIMATIONS
    # ========================================================================
    animations = {
      slowdown = 1.0;
      window-open = {
        duration-ms = 150;
        curve = "ease-out-expo";
      };
      window-close = {
        duration-ms = 150;
        curve = "ease-out-expo";
      };
      window-movement = {
        duration-ms = 200;
        curve = "ease-out-cubic";
      };
      workspace-switch = {
        duration-ms = 200;
        curve = "ease-out-cubic";
      };
    };

    # ========================================================================
    # WINDOW RULES
    # ========================================================================
    window-rules = [
      # Example: Float specific applications
      # {
      #   matches = [{ app-id = "pavucontrol"; }];
      #   default-column-width = { proportion = 0.3; };
      # }
    ];

    # ========================================================================
    # SPAWN AT STARTUP
    # ========================================================================
    spawn-at-startup = [
      { command = ["waybar"]; }
      { command = ["mako"]; }
      # { command = ["nm-applet"]; }
    ];

    # ========================================================================
    # ENVIRONMENT VARIABLES
    # ========================================================================
    environment = {
      # Additional environment variables for niri session
      # XCURSOR_THEME = "Adwaita";
      # XCURSOR_SIZE = "24";
    };

    # ========================================================================
    # KEYBINDINGS
    # ========================================================================
    binds = with config.lib.niri.actions; {
      # Mod key (Super/Windows key)
      "Mod+Return".action = spawn "foot";
      "Mod+D".action = spawn "fuzzel";
      "Mod+Q".action = close-window;

      # Screenshots
      "Print".action = screenshot;
      "Mod+Print".action = screenshot-screen;
      "Mod+Shift+Print".action = screenshot-window;

      # Window focus
      "Mod+Left".action = focus-column-left;
      "Mod+Right".action = focus-column-right;
      "Mod+Up".action = focus-window-up;
      "Mod+Down".action = focus-window-down;
      "Mod+H".action = focus-column-left;
      "Mod+L".action = focus-column-right;
      "Mod+K".action = focus-window-up;
      "Mod+J".action = focus-window-down;

      # Window movement
      "Mod+Shift+Left".action = move-column-left;
      "Mod+Shift+Right".action = move-column-right;
      "Mod+Shift+Up".action = move-window-up;
      "Mod+Shift+Down".action = move-window-down;
      "Mod+Shift+H".action = move-column-left;
      "Mod+Shift+L".action = move-column-right;
      "Mod+Shift+K".action = move-window-up;
      "Mod+Shift+J".action = move-window-down;

      # Workspaces
      "Mod+1".action = focus-workspace 1;
      "Mod+2".action = focus-workspace 2;
      "Mod+3".action = focus-workspace 3;
      "Mod+4".action = focus-workspace 4;
      "Mod+5".action = focus-workspace 5;
      "Mod+6".action = focus-workspace 6;
      "Mod+7".action = focus-workspace 7;
      "Mod+8".action = focus-workspace 8;
      "Mod+9".action = focus-workspace 9;

      # Move to workspace
      "Mod+Shift+1".action = move-column-to-workspace 1;
      "Mod+Shift+2".action = move-column-to-workspace 2;
      "Mod+Shift+3".action = move-column-to-workspace 3;
      "Mod+Shift+4".action = move-column-to-workspace 4;
      "Mod+Shift+5".action = move-column-to-workspace 5;
      "Mod+Shift+6".action = move-column-to-workspace 6;
      "Mod+Shift+7".action = move-column-to-workspace 7;
      "Mod+Shift+8".action = move-column-to-workspace 8;
      "Mod+Shift+9".action = move-column-to-workspace 9;

      # Column width
      "Mod+R".action = switch-preset-column-width;
      "Mod+Shift+R".action = reset-window-height;
      "Mod+F".action = maximize-column;
      "Mod+Shift+F".action = fullscreen-window;

      # Monitor focus
      "Mod+Comma".action = focus-monitor-left;
      "Mod+Period".action = focus-monitor-right;
      "Mod+Shift+Comma".action = move-column-to-monitor-left;
      "Mod+Shift+Period".action = move-column-to-monitor-right;

      # System
      "Mod+Shift+E".action = quit;
      "Mod+Shift+P".action = power-off-monitors;

      # Volume (if you have media keys)
      "XF86AudioRaiseVolume".action = spawn ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+"];
      "XF86AudioLowerVolume".action = spawn ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"];
      "XF86AudioMute".action = spawn ["wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"];
    };
  };

  # Create screenshots directory
  home.file.".config/niri/.keep".text = "";
  xdg.userDirs.extraConfig = {
    XDG_SCREENSHOTS_DIR = "${config.home.homeDirectory}/Pictures/Screenshots";
  };
}

