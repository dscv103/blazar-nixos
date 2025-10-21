# Gaming profile - System-level gaming packages and optimizations
# Includes Steam, Lutris, GameMode, and performance tweaks

{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.system.gaming;
in
{
  options.profiles.system.gaming = {
    enable = lib.mkEnableOption "gaming profile with Steam, Lutris, and optimizations";
  };

  config = lib.mkIf cfg.enable {
    # ========================================================================
    # GAMING PACKAGES
    # ========================================================================
    
    environment.systemPackages = with pkgs; [
      # Gaming platforms
      steam
      lutris
      heroic # Epic Games and GOG launcher
      
      # Game launchers
      bottles # Windows app runner
      
      # Gaming utilities
      gamemode # Optimize system performance for games
      gamescope # SteamOS session compositing window manager
      mangohud # Vulkan and OpenGL overlay for monitoring FPS, temps, etc.
      
      # Game streaming
      sunshine # Self-hosted game streaming (like NVIDIA GameStream)
      
      # Emulators (optional - uncomment if needed)
      # retroarch
      # dolphin-emu
      # pcsx2
      # rpcs3
    ];

    # ========================================================================
    # STEAM CONFIGURATION
    # ========================================================================
    
    programs.steam = {
      enable = true;
      
      # Enable Steam Remote Play
      remotePlay.openFirewall = true;
      
      # Enable Steam Local Network Game Transfers
      localNetworkGameTransfers.openFirewall = true;
      
      # Additional packages for Steam compatibility
      extraCompatPackages = with pkgs; [
        proton-ge-bin # GloriousEggroll's Proton builds
      ];
    };

    # ========================================================================
    # GAMEMODE CONFIGURATION
    # ========================================================================
    
    programs.gamemode = {
      enable = true;
      
      # GameMode settings
      settings = {
        general = {
          # Automatically renice games
          renice = 10;
        };
        
        # GPU optimizations
        gpu = {
          # Apply GPU optimizations (NVIDIA)
          apply_gpu_optimisations = "accept-responsibility";
          gpu_device = 0;
          
          # Set GPU performance mode
          nv_powermizer_mode = 1; # Prefer maximum performance
        };
        
        # CPU optimizations
        cpu = {
          # Set CPU governor to performance
          park_cores = "no";
          pin_cores = "no";
        };
      };
    };

    # ========================================================================
    # GRAPHICS OPTIMIZATIONS
    # ========================================================================
    
    # Enable 32-bit graphics support (required for many games)
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    # ========================================================================
    # KERNEL PARAMETERS FOR GAMING
    # ========================================================================
    
    boot.kernel.sysctl = {
      # Increase file watchers for game launchers
      "fs.inotify.max_user_watches" = 524288;
      
      # Improve responsiveness
      "vm.swappiness" = 10;
    };

    # ========================================================================
    # FIREWALL RULES FOR GAMING
    # ========================================================================
    
    networking.firewall = {
      # Allow game streaming ports (Sunshine)
      allowedTCPPorts = [ 47984 47989 48010 ];
      allowedUDPPorts = [ 47998 47999 48000 48010 ];
    };

    # ========================================================================
    # PERFORMANCE TWEAKS
    # ========================================================================
    
    # Enable fstrim for SSD performance
    services.fstrim.enable = lib.mkDefault true;
  };
}

