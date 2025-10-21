# Bluetooth feature profile - System-level bluetooth support
# Includes Bluez, bluetooth audio, and device management

{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.features.bluetooth;
in
{
  options.profiles.features.bluetooth = {
    enable = lib.mkEnableOption "bluetooth support with Bluez and audio";
  };

  config = lib.mkIf cfg.enable {
    # ========================================================================
    # BLUETOOTH PACKAGES
    # ========================================================================
    
    environment.systemPackages = with pkgs; [
      # Bluetooth management
      bluez # Bluetooth protocol stack
      bluez-tools # Additional Bluetooth tools
      
      # GUI tools
      # blueberry # Bluetooth manager (GTK)
      # blueman # Bluetooth manager (alternative)
    ];

    # ========================================================================
    # BLUETOOTH SERVICE
    # ========================================================================
    
    hardware.bluetooth = {
      enable = true;
      
      # Enable A2DP sink (high-quality audio)
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true; # Enable experimental features
        };
      };
      
      # Power on bluetooth controller on boot
      powerOnBoot = true;
    };

    # Enable bluetooth manager service
    services.blueman.enable = true;

    # ========================================================================
    # BLUETOOTH AUDIO
    # ========================================================================
    
    # PipeWire bluetooth support
    services.pipewire = {
      # Enable bluetooth audio codecs
      wireplumber.extraConfig = {
        "monitor.bluez.properties" = {
          "bluez5.enable-sbc-xq" = true;
          "bluez5.enable-msbc" = true;
          "bluez5.enable-hw-volume" = true;
          "bluez5.roles" = [ "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag" ];
        };
      };
    };
  };
}

