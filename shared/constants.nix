# Shared constants
# Common values used across system and user configurations
# This provides a single source of truth for shared settings

{
  # ============================================================================
  # USER INFORMATION
  # ============================================================================

  users = {
    mainUser = "dscv";
    description = "David Vitrano";
  };

  # ============================================================================
  # SYSTEM SETTINGS
  # ============================================================================

  system = {
    stateVersion = "24.11";
    timeZone = "America/New_York";
    locale = "en_US.UTF-8";
  };

  # ============================================================================
  # BOOT SETTINGS
  # ============================================================================

  boot = {
    timeout = 2; # Bootloader timeout in seconds
    configurationLimit = 10; # Number of generations to keep in bootloader
  };

  # ============================================================================
  # DISK PARTITIONING
  # ============================================================================

  disk = {
    # Partition sizes
    efiSize = "2G"; # EFI System Partition size
    swapSize = "16G"; # Swap partition size (should match RAM for hibernation)

    # Bcachefs settings
    journalSize = "512M"; # Journal size for bcachefs
    metadataReplicas = 1; # Metadata replication (1 for single disk)
    dataReplicas = 1; # Data replication (1 for single disk)
  };

  # ============================================================================
  # NETWORK SETTINGS
  # ============================================================================

  network = {
    # RTMP streaming port for OBS
    rtmpPort = 1935;
  };

  # ============================================================================
  # PATHS
  # ============================================================================

  paths = {
    wallpapers = "~/Pictures/Wallpapers";
    screenshots = "~/Pictures/Screenshots";
  };

  # ============================================================================
  # PERFORMANCE TUNING
  # ============================================================================

  performance = {
    # Shared memory limits for audio/video processing
    shmmax = 2147483648; # 2GB in bytes
    shmall = 2147483648; # 2GB in bytes
  };
}

