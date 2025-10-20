# Home Manager base configuration for dscv
# This file contains the core home-manager settings

{ config, ... }:

{
  # User information and state version
  home = {
    username = "dscv";
    homeDirectory = "/home/dscv";

    # Home Manager version - should match system.stateVersion
    # This value determines the Home Manager release which was used to
    # initially configure your home directory.
    stateVersion = "24.11";
  };

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # XDG user directories
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
      desktop = "${config.home.homeDirectory}/Desktop";
      documents = "${config.home.homeDirectory}/Documents";
      download = "${config.home.homeDirectory}/Downloads";
      music = "${config.home.homeDirectory}/Music";
      pictures = "${config.home.homeDirectory}/Pictures";
      videos = "${config.home.homeDirectory}/Videos";
      templates = "${config.home.homeDirectory}/Templates";
      publicShare = "${config.home.homeDirectory}/Public";
    };
  };
}

