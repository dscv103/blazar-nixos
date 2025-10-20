# System-wide packages
# Essential packages for the desktop environment

{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # ========================================================================
    # TERMINAL EMULATORS
    # ========================================================================
    foot          # Lightweight Wayland terminal (recommended for niri)
    # alacritty   # GPU-accelerated terminal
    # kitty       # Feature-rich terminal

    # ========================================================================
    # APPLICATION LAUNCHERS
    # ========================================================================
    fuzzel        # Wayland-native dmenu replacement
    # wofi        # Alternative launcher
    # rofi-wayland # Rofi for Wayland

    # ========================================================================
    # STATUS BAR
    # ========================================================================
    waybar        # Highly customizable status bar

    # ========================================================================
    # NOTIFICATIONS
    # ========================================================================
    mako          # Lightweight notification daemon
    libnotify     # Send notifications (notify-send command)

    # ========================================================================
    # SCREEN UTILITIES
    # ========================================================================
    grim          # Screenshot utility
    slurp         # Region selector for screenshots
    swappy        # Screenshot editor
    wl-clipboard  # Wayland clipboard utilities (wl-copy, wl-paste)
    cliphist      # Clipboard history manager

    # ========================================================================
    # SCREEN LOCKING
    # ========================================================================
    swaylock      # Screen locker
    # swaylock-effects  # Screen locker with effects

    # ========================================================================
    # FILE MANAGERS
    # ========================================================================
    nautilus      # GNOME Files (GTK)
    # thunar      # XFCE file manager (lightweight)
    # nnn         # Terminal file manager
    # ranger      # Terminal file manager

    # ========================================================================
    # WAYLAND UTILITIES
    # ========================================================================
    wayland-utils # wayland-info and other utilities
    wev           # Wayland event viewer (for debugging keybindings)
    wlr-randr     # Display configuration tool

    # ========================================================================
    # SYSTEM UTILITIES
    # ========================================================================
    git           # Version control
    vim           # Text editor
    wget          # Download utility
    curl          # HTTP client
    htop          # Process viewer
    btop          # Modern process viewer
    tree          # Directory tree viewer
    unzip         # Archive extraction
    zip           # Archive creation
    p7zip         # 7z archive support
    
    # ========================================================================
    # NETWORK UTILITIES
    # ========================================================================
    networkmanagerapplet  # NetworkManager GUI
    
    # ========================================================================
    # AUDIO UTILITIES
    # ========================================================================
    pavucontrol   # PulseAudio/PipeWire volume control
    
    # ========================================================================
    # DEVELOPMENT TOOLS
    # ========================================================================
    nixpkgs-fmt   # Nix code formatter
    nil           # Nix language server
  ];
}

