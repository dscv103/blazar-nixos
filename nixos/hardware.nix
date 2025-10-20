# AMD Ryzen 7 5800X hardware configuration
# CPU-specific optimizations and settings

{ config, lib, pkgs, ... }:

{
  # AMD CPU microcode updates
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Enable KVM for virtualization
  boot.kernelModules = [ "kvm-amd" ];

  # CPU frequency governor
  # Options: "schedutil" (balanced), "performance" (max performance), "powersave" (power saving)
  powerManagement.cpuFreqGovernor = lib.mkDefault "schedutil";

  # AMD P-State driver for better power management (kernel 6.1+)
  # This provides better performance and power efficiency on modern AMD CPUs
  boot.kernelParams = [
    "amd_pstate=active"
  ];

  # Enable all firmware (for peripherals and hardware support)
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;

  # Platform specification
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}

