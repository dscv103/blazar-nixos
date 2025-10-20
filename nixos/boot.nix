# Bootloader configuration

{ pkgs, ... }:

{
  boot = {
    # Use systemd-boot EFI bootloader
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10; # Keep multiple generations for easy rollback
      };
      efi.canTouchEfiVariables = true;
      timeout = 5; # Bootloader timeout (seconds)
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

