# Bootloader configuration

{ config, lib, pkgs, ... }:

{
  # Use systemd-boot EFI bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Keep multiple generations for easy rollback
  boot.loader.systemd-boot.configurationLimit = 10;

  # Bootloader timeout (seconds)
  boot.loader.timeout = 5;

  # Alternative: GRUB bootloader (uncomment if preferred)
  # boot.loader.grub = {
  #   enable = true;
  #   device = "nodev";
  #   efiSupport = true;
  #   useOSProber = true;  # Detect other operating systems
  # };

  # Latest kernel for best hardware support
  boot.kernelPackages = pkgs.linuxPackages_latest;
}

