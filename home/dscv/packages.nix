# User packages
# Applications and tools installed for the user

{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # ========================================================================
    # WEB BROWSERS
    # ========================================================================
    firefox
    # chromium

    # ========================================================================
    # TEXT EDITORS
    # ========================================================================
    # vscode
    # neovim

    # ========================================================================
    # MEDIA PLAYERS
    # ========================================================================
    mpv # Video player
    # vlc         # Alternative video player

    # ========================================================================
    # IMAGE VIEWERS/EDITORS
    # ========================================================================
    imv # Wayland image viewer
    # gimp        # Image editor

    # ========================================================================
    # DOCUMENT VIEWERS
    # ========================================================================
    # zathura     # PDF viewer
    # evince      # GNOME document viewer

    # ========================================================================
    # COMMUNICATION
    # ========================================================================
    # discord
    # slack
    # telegram-desktop

    # ========================================================================
    # DEVELOPMENT TOOLS
    # ========================================================================
    # Add your development tools here
    # python3
    # nodejs
    # rustc
    # cargo

    # ========================================================================
    # UTILITIES
    # ========================================================================
    # keepassxc   # Password manager
    # syncthing   # File synchronization
  ];

  # ========================================================================
  # PROGRAM CONFIGURATIONS
  # ========================================================================

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

