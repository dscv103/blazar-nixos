# Printing feature profile - System-level printing and scanning support
# Includes CUPS, printer drivers, and scanner support

{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.features.printing;
in
{
  options.profiles.features.printing = {
    enable = lib.mkEnableOption "printing and scanning support with CUPS";
  };

  config = lib.mkIf cfg.enable {
    # ============================================================================
    # PRINTING PACKAGES
    # ============================================================================
    environment.systemPackages = with pkgs; [
      # Printer management
      system-config-printer # CUPS printer configuration tool

      # Scanner support
      simple-scan # Simple scanning utility
      # xsane # Advanced scanning
    ];

    # ============================================================================
    # CUPS PRINTING SERVICE
    # ============================================================================
    services.printing = {
      enable = true;

      # Printer drivers
      drivers = with pkgs; [
        gutenprint # High-quality printer drivers
        hplip # HP printer drivers
        # epson-escpr # Epson printer drivers
        # brlaser # Brother laser printer drivers
        # cnijfilter2 # Canon printer drivers
      ];

      # Enable web interface
      webInterface = true;

      # Allow remote printing
      # listenAddresses = [ "*:631" ];
      # allowFrom = [ "all" ];
      # browsing = true;
      # defaultShared = true;
    };

    # Enable Avahi for network printer discovery
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;

      # Publish printer information
      publish = {
        enable = true;
        userServices = true;
      };
    };

    # ============================================================================
    # SCANNER SUPPORT
    # ============================================================================
    hardware.sane = {
      enable = true;

      # Scanner drivers
      extraBackends = with pkgs; [
        hplipWithPlugin # HP scanner support
        # sane-airscan # Network scanner support
      ];
    };

    # Add user to scanner group (configured per-user in users.nix)
    # users.users.<username>.extraGroups = [ "scanner" "lp" ];
  };
}

