# Multimedia profile - System-level multimedia creation and editing tools
# Includes OBS, video editing, audio production

{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.system.multimedia;
in
{
  options.profiles.system.multimedia = {
    enable = lib.mkEnableOption "multimedia profile with OBS, video editing, and audio tools";
  };

  config = lib.mkIf cfg.enable {
    # ========================================================================
    # MULTIMEDIA PACKAGES
    # ========================================================================
    
    environment.systemPackages = with pkgs; [
      # Video recording and streaming
      obs-studio
      obs-studio-plugins.obs-pipewire-audio-capture
      obs-studio-plugins.obs-vaapi
      obs-studio-plugins.obs-vkcapture
      
      # Video editing
      kdenlive # Professional video editor
      shotcut # Simple video editor
      
      # 3D and animation
      blender # 3D creation suite
      
      # Audio editing
      audacity # Audio editor
      
      # Audio production (DAW)
      # ardour # Professional DAW
      # reaper # Commercial DAW (unfree)
      
      # Image editing (basic tools - advanced in user/creative.nix)
      imagemagick
      ffmpeg-full
      
      # Screen recording
      simplescreenrecorder
      
      # Video conversion
      handbrake
      
      # Codecs and libraries
      gst_all_1.gstreamer
      gst_all_1.gst-plugins-base
      gst_all_1.gst-plugins-good
      gst_all_1.gst-plugins-bad
      gst_all_1.gst-plugins-ugly
      gst_all_1.gst-libav
      gst_all_1.gst-vaapi
    ];

    # ========================================================================
    # AUDIO CONFIGURATION
    # ========================================================================
    
    # Enable JACK support for professional audio
    services.pipewire.jack.enable = lib.mkDefault true;

    # Real-time audio priority
    security.rtkit.enable = lib.mkDefault true;

    # ========================================================================
    # VIDEO ACCELERATION
    # ========================================================================
    
    # Enable hardware video acceleration
    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        # VA-API (Video Acceleration API)
        vaapiVdpau
        libvdpau-va-gl
        
        # NVIDIA VA-API driver
        nvidia-vaapi-driver
      ];
    };

    # ========================================================================
    # OBS STUDIO CONFIGURATION
    # ========================================================================
    
    # Enable v4l2loopback for virtual camera support
    boot.extraModulePackages = with config.boot.kernelPackages; [
      v4l2loopback
    ];
    
    boot.kernelModules = [ "v4l2loopback" ];
    
    boot.extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=10 card_label="OBS Virtual Camera" exclusive_caps=1
    '';

    # ========================================================================
    # PERFORMANCE OPTIMIZATIONS
    # ========================================================================
    
    boot.kernel.sysctl = {
      # Increase shared memory for audio/video processing
      "kernel.shmmax" = 2147483648; # 2GB
      "kernel.shmall" = 2147483648;
    };

    # ========================================================================
    # FIREWALL RULES FOR STREAMING
    # ========================================================================
    
    networking.firewall = {
      # RTMP streaming (OBS)
      allowedTCPPorts = [ 1935 ];
    };
  };
}

