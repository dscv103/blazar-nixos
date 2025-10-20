# AMD Ryzen 7 5800X hardware configuration
# CPU-specific optimizations and settings

{ config, lib, ... }:

{
  # Hardware configuration
  hardware = {
    # AMD CPU microcode updates
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    # Enable all firmware (for peripherals and hardware support)
    enableRedistributableFirmware = true;
    enableAllFirmware = true;
  };

  # Boot configuration
  boot = {
    # Enable KVM for virtualization
    kernelModules = [ "kvm-amd" ];

    # AMD P-State driver for better power management (kernel 6.1+)
    # This provides better performance and power efficiency on modern AMD CPUs
    kernelParams = [ "amd_pstate=active" ];
  };

  # CPU frequency governor
  # Options: "schedutil" (balanced), "performance" (max performance), "powersave" (power saving)
  powerManagement.cpuFreqGovernor = lib.mkDefault "schedutil";

  # Platform specification
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}

