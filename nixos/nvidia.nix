# NVIDIA driver configuration with Wayland support
# Optimized for NVIDIA GPUs with niri compositor

{ config, pkgs, ... }:

{
  # ============================================================================
  # NVIDIA DRIVER CONFIGURATION
  # ============================================================================

  # Set video drivers
  services.xserver.videoDrivers = [ "nvidia" ];

  # NVIDIA hardware configuration
  hardware.nvidia = {
    # Modesetting is REQUIRED for Wayland
    modesetting.enable = true;

    # Power management (experimental, can cause issues)
    # Only enable if you experience suspend/resume issues
    powerManagement.enable = false;
    powerManagement.finegrained = false;

    # Use proprietary driver (open-source driver is still beta)
    # Set to true for RTX 20-series and newer if you want to try open driver
    open = false;

    # Enable nvidia-settings GUI tool
    nvidiaSettings = true;

    # Driver version - use stable for reliability
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    # Alternative versions:
    # package = config.boot.kernelPackages.nvidiaPackages.beta;
    # package = config.boot.kernelPackages.nvidiaPackages.production;
    # package = config.boot.kernelPackages.nvidiaPackages.vulkan_beta;

    # GPU System Processor (GSP) - Recommended for RTX 20-series and newer
    # Offloads GPU initialization to GPU firmware
    # gsp.enable = true;
  };

  # ============================================================================
  # GRAPHICS SUPPORT (renamed from hardware.opengl in NixOS 24.05+)
  # ============================================================================

  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Required for 32-bit applications (Steam, Wine, etc.)

    # Additional graphics packages for video acceleration
    extraPackages = with pkgs; [
      vaapiVdpau
      libvdpau-va-gl
      nvidia-vaapi-driver
    ];
  };

  # ============================================================================
  # KERNEL PARAMETERS & BOOT SETTINGS
  # ============================================================================

  boot = {
    # CRITICAL: Enable NVIDIA DRM kernel mode setting (required for Wayland)
    kernelParams = [
      "nvidia-drm.modeset=1"
      "nvidia-drm.fbdev=1" # Enable framebuffer device (kernel 6.6+)
      # "nvidia.NVreg_PreserveVideoMemoryAllocations=1"  # Uncomment for suspend/resume issues
    ];

    # Load NVIDIA modules early in boot
    initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];

    # Ensure NVIDIA modules are loaded
    extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
  };

  # ============================================================================
  # ENVIRONMENT VARIABLES - Required for NVIDIA + Wayland
  # ============================================================================

  environment.sessionVariables = {
    # NVIDIA Wayland compatibility
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";

    # Wayland-specific fixes
    WLR_NO_HARDWARE_CURSORS = "1"; # Fix cursor rendering issues

    # NVIDIA-specific optimizations
    __GL_GSYNC_ALLOWED = "1"; # Enable G-Sync
    __GL_VRR_ALLOWED = "1"; # Enable Variable Refresh Rate

    # Additional performance settings (optional)
    # __GL_SHADER_DISK_CACHE = "1";
    # __GL_SHADER_DISK_CACHE_PATH = "/tmp/nvidia-shader-cache";
  };
}

