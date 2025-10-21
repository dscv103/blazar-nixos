# Productivity profile - User-level productivity applications
# Includes LibreOffice, Thunderbird, note-taking apps

{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.user.productivity;
in
{
  options.profiles.user.productivity = {
    enable = lib.mkEnableOption "productivity profile with office suite and productivity tools";
  };

  config = lib.mkIf cfg.enable {
    # ============================================================================
    # PRODUCTIVITY PACKAGES
    # ============================================================================
    home.packages = with pkgs; [
      # Office suite
      libreoffice-fresh # Latest LibreOffice

      # PDF tools
      evince # PDF viewer (GNOME)
      okular # PDF viewer (KDE)

      # Note-taking
      obsidian # Knowledge base and note-taking
      joplin-desktop # Note-taking and to-do app
      # logseq # Knowledge management
      # notion-app-enhanced # Notion desktop app

      # Task management
      # super-productivity # Task management and time tracking

      # Calendar
      # gnome.gnome-calendar

      # Mind mapping
      # xmind # Mind mapping tool

      # Password management
      keepassxc # Password manager

      # Cloud storage
      # nextcloud-client # Nextcloud sync client
      # dropbox # Dropbox client

      # File synchronization
      syncthing # Continuous file synchronization

      # Document conversion
      pandoc # Universal document converter

      # Markdown editors
      # marktext # Markdown editor
      # typora # Markdown editor (unfree)

      # Spreadsheet tools
      # gnumeric # Lightweight spreadsheet

      # Presentation tools (included in LibreOffice)

      # Time tracking
      # timewarrior # Command-line time tracking
    ];

    # ============================================================================
    # PROGRAM CONFIGURATIONS
    # ============================================================================
    # Syncthing configuration
    services.syncthing = {
      enable = true;
      # tray.enable = true; # Enable system tray icon
    };

    # KeePassXC configuration
    # programs.keepassxc = {
    #   enable = true;
    #   settings = {
    #     # Custom settings
    #   };
    # };
  };
}

