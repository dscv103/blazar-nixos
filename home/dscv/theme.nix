# Dracula theme configuration
# GTK, Qt, icons, and cursor theme

{ config, pkgs, ... }:

{
  # ================================================================================
  # DCONF SETTINGS (for GNOME applications)
  # ================================================================================
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      gtk-theme = "Dracula";
      color-scheme = "prefer-dark";
    };
  };

  # ================================================================================
  # CURSOR THEME
  # ================================================================================
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 16;
  };

  # ================================================================================
  # QT THEME
  # ================================================================================
  qt = {
    enable = true;
    platformTheme.name = "gtk";
  };

  # ================================================================================
  # GTK THEME
  # ================================================================================
  gtk = {
    enable = true;

    theme = {
      name = "Dracula";
      package = pkgs.dracula-theme;
    };

    iconTheme = {
      name = "Dracula";
      package = pkgs.dracula-theme;
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  # ================================================================================
  # GTK 4.0 THEME FILES
  # ================================================================================
  xdg.configFile = {
    "gtk-4.0/assets".source =
      "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";
    "gtk-4.0/gtk.css".source =
      "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css";
    "gtk-4.0/gtk-dark.css".source =
      "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";
  };
}

