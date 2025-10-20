# Hardware configuration for blazar
# This file should be generated with: nixos-generate-config --show-hardware-config
# 
# PLACEHOLDER - Replace this with your actual hardware configuration
# Run: nixos-generate-config --show-hardware-config > hosts/blazar/hardware-configuration.nix
#
# This file will contain:
# - File systems configuration (/, /boot, swap, etc.)
# - Boot loader settings
# - Kernel modules
# - Hardware-specific settings

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # PLACEHOLDER: Add your actual hardware configuration here
  # This is a minimal placeholder to allow the flake to build
  # You MUST replace this with the output of nixos-generate-config
  
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # PLACEHOLDER: Configure your actual file systems here
  # Run: nixos-generate-config --show-hardware-config > hosts/blazar/hardware-configuration.nix
  # to generate the actual configuration

  # Minimal placeholder to allow flake to build
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  # Example swap configuration (uncomment and adjust as needed):
  # swapDevices = [
  #   { device = "/dev/disk/by-uuid/YOUR-SWAP-UUID"; }
  # ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}

