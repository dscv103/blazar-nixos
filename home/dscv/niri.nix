# Niri user configuration
# Keybindings, workspaces, window rules, and appearance

_:

{
  # Niri configuration using the niri-flake home-manager module
  # Note: The niri-flake provides the programs.niri module automatically
  # Configuration is done via KDL file or programs.niri.config

  # Use raw KDL configuration file for maximum compatibility
  xdg.configFile."niri/config.kdl".text = ''
    input {
        keyboard {
            xkb {
                layout "us"
            }
            repeat-delay 600
            repeat-rate 25
        }

        touchpad {
            tap
            natural-scroll
            dwt
        }

        mouse {
            accel-speed 0.0
        }
    }

    output "DP-1" {
        // Configure your actual monitor here
        // Use `niri msg outputs` to list available outputs
        // mode "2560x1440@144"
        // position x=0 y=0
        // scale 1.0
    }

    layout {
        gaps 8
        center-focused-column "never"

        preset-column-widths {
            proportion 0.33333
            proportion 0.5
            proportion 0.66667
        }

        default-column-width { proportion 0.5; }

        focus-ring {
            width 2
            active-color "#7fc8ff"
            inactive-color "#505050"
        }

        border {
            width 1
            active-color "#ffc87f"
            inactive-color "#505050"
        }
    }

    prefer-no-csd

    screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

    animations {
        slowdown 1.0
    }

    spawn-at-startup "waybar"
    spawn-at-startup "mako"
    spawn-at-startup "hyprpaper"

    environment {
        // XCURSOR_THEME "Adwaita"
        // XCURSOR_SIZE "24"
    }


    binds {
        // Mod key is Super/Windows key
        Mod+Return { spawn "foot"; }
        Mod+D { spawn "fuzzel"; }
        Mod+Q { close-window; }

        // Screenshots
        Print { screenshot; }
        Mod+Print { screenshot-screen; }
        Mod+Shift+Print { screenshot-window; }

        // Window focus
        Mod+Left { focus-column-left; }
        Mod+Right { focus-column-right; }
        Mod+Up { focus-window-up; }
        Mod+Down { focus-window-down; }
        Mod+H { focus-column-left; }
        Mod+L { focus-column-right; }
        Mod+K { focus-window-up; }
        Mod+J { focus-window-down; }

        // Window movement
        Mod+Shift+Left { move-column-left; }
        Mod+Shift+Right { move-column-right; }
        Mod+Shift+Up { move-window-up; }
        Mod+Shift+Down { move-window-down; }
        Mod+Shift+H { move-column-left; }
        Mod+Shift+L { move-column-right; }
        Mod+Shift+K { move-window-up; }
        Mod+Shift+J { move-window-down; }

        // Workspaces
        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }
        Mod+5 { focus-workspace 5; }
        Mod+6 { focus-workspace 6; }
        Mod+7 { focus-workspace 7; }
        Mod+8 { focus-workspace 8; }
        Mod+9 { focus-workspace 9; }

        // Move to workspace
        Mod+Shift+1 { move-column-to-workspace 1; }
        Mod+Shift+2 { move-column-to-workspace 2; }
        Mod+Shift+3 { move-column-to-workspace 3; }
        Mod+Shift+4 { move-column-to-workspace 4; }
        Mod+Shift+5 { move-column-to-workspace 5; }
        Mod+Shift+6 { move-column-to-workspace 6; }
        Mod+Shift+7 { move-column-to-workspace 7; }
        Mod+Shift+8 { move-column-to-workspace 8; }
        Mod+Shift+9 { move-column-to-workspace 9; }

        // Column width
        Mod+R { switch-preset-column-width; }
        Mod+Shift+R { reset-window-height; }
        Mod+F { maximize-column; }
        Mod+Shift+F { fullscreen-window; }

        // Monitor focus
        Mod+Comma { focus-monitor-left; }
        Mod+Period { focus-monitor-right; }
        Mod+Shift+Comma { move-column-to-monitor-left; }
        Mod+Shift+Period { move-column-to-monitor-right; }

        // System
        Mod+Shift+E { quit; }
        Mod+Shift+P { power-off-monitors; }

        // Volume (if you have media keys)
        XF86AudioRaiseVolume { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+"; }
        XF86AudioLowerVolume { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"; }
        XF86AudioMute { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
    }
  '';

  # Create screenshots directory
  home.file."Pictures/Screenshots/.keep".text = "";

  # Create wallpapers directory with README
  home.file."Pictures/Wallpapers/.keep".text = "";
  home.file."Pictures/Wallpapers/README.md".text = ''
    # Wallpapers Directory

    Place your wallpaper images in this directory.

    ## Supported Formats

    Hyprpaper supports:
    - PNG
    - JPEG/JPG
    - WebP (including animated WebP)
    - JPEG XL (JXL)

    ## Usage

    The default wallpaper is configured in `~/.config/hypr/hyprpaper.conf`.

    ### Setting a Wallpaper

    1. Add your wallpaper image to this directory
    2. Edit `~/.config/hypr/hyprpaper.conf`:
       ```
       preload = ~/Pictures/Wallpapers/your-image.webp
       wallpaper = ,~/Pictures/Wallpapers/your-image.webp
       ```
    3. Reload hyprpaper: `killall hyprpaper && hyprpaper &`

    ### Using Multiple Wallpapers (Multi-Monitor)

    ```
    preload = ~/Pictures/Wallpapers/monitor1.webp
    preload = ~/Pictures/Wallpapers/monitor2.webp
    wallpaper = DP-1,~/Pictures/Wallpapers/monitor1.webp
    wallpaper = HDMI-A-1,~/Pictures/Wallpapers/monitor2.webp
    ```

    Use `niri msg outputs` to see your monitor names.

    ### Dynamic Wallpaper Changes

    Use hyprctl to change wallpapers on the fly:
    ```bash
    hyprctl hyprpaper preload ~/Pictures/Wallpapers/new-image.webp
    hyprctl hyprpaper wallpaper ",~/Pictures/Wallpapers/new-image.webp"
    ```

    ### Configuration Options

    - `splash = false` - Disable the hyprpaper splash text
    - `ipc = on` - Enable IPC for dynamic control (default: on)

    ## Example Wallpaper Sources

    - https://unsplash.com (free high-quality photos)
    - https://wallhaven.cc (community wallpapers)
    - https://www.pexels.com (free stock photos)
  '';

  # Hyprpaper configuration
  xdg.configFile."hypr/hyprpaper.conf".text = ''
    # Hyprpaper configuration
    # See https://wiki.hypr.land/Hypr-Ecosystem/hyprpaper/

    # Preload wallpapers (loads them into memory)
    preload = ~/Pictures/Wallpapers/wallpaper.webp

    # Set wallpaper for all monitors
    # Format: wallpaper = monitor,path
    # Use "," for all monitors or specify monitor name (e.g., "DP-1")
    wallpaper = ,~/Pictures/Wallpapers/wallpaper.webp

    # Disable splash text
    splash = false

    # Enable IPC for dynamic wallpaper changes
    ipc = on
  '';
}

