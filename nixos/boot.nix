# Bootloader configuration

{ pkgs, ... }:

let
  constants = import ../shared/constants.nix;
in
{
  boot = {
    # Use systemd-boot EFI bootloader
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = constants.boot.configurationLimit;
      };
      efi.canTouchEfiVariables = true;
      timeout = constants.boot.timeout;
    };

    # Alternative: GRUB bootloader (uncomment if preferred)
    # loader.grub = {
    #   enable = true;
    #   device = "nodev";
    #   efiSupport = true;
    #   useOSProber = true;  # Detect other operating systems
    # };

    # Latest kernel for best hardware support
    kernelPackages = pkgs.linuxPackages_latest;
  };
}

