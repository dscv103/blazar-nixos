# Shared theme constants
# Dracula color scheme and theme settings used across the configuration
# This provides a single source of truth for theme values

{
  # ============================================================================
  # DRACULA COLOR PALETTE
  # ============================================================================
  # Official Dracula color scheme
  # https://draculatheme.com/contribute
  
  colors = {
    background = "#282a36";
    currentLine = "#44475a";
    foreground = "#f8f8f2";
    comment = "#6272a4";
    cyan = "#8be9fd";
    green = "#50fa7b";
    orange = "#ffb86c";
    pink = "#ff79c6";
    purple = "#bd93f9";
    red = "#ff5555";
    yellow = "#f1fa8c";
  };

  # ============================================================================
  # THEME NAMES
  # ============================================================================
  
  names = {
    gtk = "Dracula";
    icon = "Dracula";
    cursor = "Bibata-Modern-Classic";
    colorScheme = "prefer-dark";
  };

  # ============================================================================
  # FONT CONFIGURATION
  # ============================================================================
  
  fonts = {
    main = "Maple Mono";
    nerdFont = "Maple Mono NF";
    size = {
      terminal = 14;
      editor = 14;
      ui = 14;
    };
  };
}

