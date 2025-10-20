# User account configuration

{ config, lib, pkgs, ... }:

{
  # Define user account
  users.users.dscv = {
    isNormalUser = true;
    description = "dscv";
    
    # User groups
    extraGroups = [
      "wheel"          # sudo access
      "networkmanager" # network management
      "video"          # video devices
      "audio"          # audio devices
      "input"          # input devices
      "render"         # GPU rendering
    ];
    
    # Set initial password (change after first login!)
    # Use 'mkpasswd -m sha-512' to generate a hashed password
    # Or set password interactively with: passwd dscv
    initialPassword = "changeme";
    
    # Alternative: Use hashedPassword for better security
    # hashedPassword = "...";
    
    # User shell (default is bash, can be changed in home-manager)
    shell = pkgs.bash;
  };

  # Enable sudo for wheel group
  security.sudo.wheelNeedsPassword = true;
}

