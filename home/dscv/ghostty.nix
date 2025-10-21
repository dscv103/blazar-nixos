# Ghostty terminal emulator configuration
# Fast, native, feature-rich terminal with Dracula theme and Maple Mono font

{ pkgs, ... }:

{
  # ================================================================================
  # GHOSTTY TERMINAL
  # ================================================================================
  programs.ghostty = {
    enable = true;

    # Ghostty settings
    settings = {
      # ======================================================================
      # THEME - DRACULA
      # ======================================================================
      # Ghostty has built-in Dracula theme support
      theme = "Dracula";

      # ======================================================================
      # FONT CONFIGURATION
      # ======================================================================
      # Maple Mono font family
      font-family = "Maple Mono";
      font-size = 14;

      # Font features
      font-feature = [
        "-calt" # Disable contextual alternates if needed
        "-liga" # Disable ligatures if needed (remove this line to enable ligatures)
      ];

      # ======================================================================
      # WINDOW SETTINGS
      # ======================================================================
      window-padding-x = 10;
      window-padding-y = 10;
      window-decoration = true;

      # ======================================================================
      # CURSOR
      # ======================================================================
      cursor-style = "block";
      cursor-style-blink = false;

      # ======================================================================
      # SHELL INTEGRATION
      # ======================================================================
      shell-integration = true;
      shell-integration-features = "cursor,sudo,title";

      # ======================================================================
      # PERFORMANCE
      # ======================================================================
      # Ghostty is already very fast, these are optional optimizations
      copy-on-select = false;

      # ======================================================================
      # MISC
      # ======================================================================
      confirm-close-surface = false;
      mouse-hide-while-typing = true;
    };
  };
}

