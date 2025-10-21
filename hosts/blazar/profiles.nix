# Profile configuration for blazar
# Enable or disable profiles by setting enable = true/false

{
  # ============================================================================
  # SYSTEM PROFILES
  # ============================================================================
  # System-level configurations that affect the entire NixOS system

  system = {
    # Gaming profile - Steam, Lutris, GameMode, performance optimizations
    gaming.enable = false;

    # Development profile - Docker, databases, additional dev tools
    development.enable = false;

    # Multimedia profile - OBS, video editing, audio production
    multimedia.enable = false;

    # Virtualization profile - VirtualBox, QEMU/KVM, virt-manager
    virtualization.enable = false;

    # Server profile - Web servers, databases, monitoring
    server.enable = false;
  };

  # ============================================================================
  # USER PROFILES (per-user configuration)
  # ============================================================================
  # User-level configurations managed by home-manager

  users.dscv = {
    # Creative profile - GIMP, Inkscape, Krita, Blender
    creative.enable = false;

    # Productivity profile - LibreOffice, Thunderbird, note-taking
    productivity.enable = false;

    # Communication profile - Discord, Slack, Telegram, Zoom
    communication.enable = false;

    # Minimal profile - Reduce packages to essentials only
    minimal.enable = false;
  };

  # ============================================================================
  # FEATURE PROFILES
  # ============================================================================
  # Specific features that can be enabled independently

  features = {
    # NVIDIA gaming optimizations - CUDA, GPU acceleration
    nvidia-gaming.enable = false;

    # Wayland extras - Screen recording, color pickers, clipboard managers
    wayland-extras.enable = false;

    # Printing and scanning support
    printing.enable = false;

    # Bluetooth support
    bluetooth.enable = false;
  };
}

