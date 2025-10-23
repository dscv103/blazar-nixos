# User packages
# Applications and tools installed for the user

{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # ============================================================================
    # WEB BROWSERS
    # ============================================================================
    firefox
    # chromium

    # ============================================================================
    # TEXT EDITORS
    # ============================================================================
    # vscode - configured in vscode.nix
    # neovim

    # ============================================================================
    # MEDIA PLAYERS
    # ============================================================================
    mpv # Video player
    # vlc         # Alternative video player

    # ============================================================================
    # IMAGE VIEWERS/EDITORS
    # ============================================================================
    imv # Wayland image viewer
    # gimp        # Image editor

    # ============================================================================
    # DOCUMENT VIEWERS
    # ============================================================================
    # zathura     # PDF viewer
    # evince      # GNOME document viewer

    # ============================================================================
    # COMMUNICATION
    # ============================================================================
    # discord
    # slack
    # telegram-desktop

    # ============================================================================
    # DEVELOPMENT TOOLS
    # ============================================================================
    # Add your development tools here
    # python3
    # nodejs
    # rustc
    # cargo

    # ============================================================================
    # UTILITIES
    # ============================================================================
    # keepassxc   # Password manager
    # syncthing   # File synchronization

    # ============================================================================
    # WAYLAND UTILITIES
    # ============================================================================
    hyprpaper # Wallpaper utility for Wayland (supports PNG, JPEG, WebP, JXL)
  ];

  # ============================================================================
  # PROGRAM CONFIGURATIONS
  # ============================================================================

  nixpkgs.config.allowUnfree = true;
 
  # Firefox with Wayland support
  programs.firefox = {
    enable = true;
    # Additional Firefox configuration can go here
  };

  # MPV configuration
  programs.mpv = {
    enable = true;
    config = {
      hwdec = "auto"; # Hardware decoding
      vo = "gpu"; # Video output
    };
  };
}

