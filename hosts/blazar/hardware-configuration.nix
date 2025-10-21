# Hardware configuration for blazar
#
# NOTE: Filesystem configuration is managed by disko (hosts/blazar/disko.nix)
# This file contains only hardware detection and kernel modules
#
# If you need to regenerate this file after hardware changes:
# Run: nixos-generate-config --show-hardware-config
# Then remove the fileSystems and swapDevices sections (managed by disko)

{ config, lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Kernel modules for hardware detection
  boot = {
    initrd = {
      # Available kernel modules for initrd
      availableKernelModules = [
        "xhci_pci"      # USB 3.0 controller
        "ahci"          # SATA controller
        "nvme"          # NVMe SSD support
        "usbhid"        # USB HID devices
        "usb_storage"   # USB storage devices
        "sd_mod"        # SCSI disk support
      ];
      kernelModules = [ ];
    };

    # Kernel modules to load
    kernelModules = [ "kvm-amd" ]; # AMD virtualization support
    extraModulePackages = [ ];
  };

  # ============================================================================
  # FILESYSTEM CONFIGURATION
  # ============================================================================
  # Filesystems are managed by disko (hosts/blazar/disko.nix)
  # Do NOT add fileSystems or swapDevices here - they will conflict with disko
  # ============================================================================

  # Platform and CPU microcode
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}

