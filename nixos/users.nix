# User account configuration

{ pkgs, ... }:

{
  # Define user account
  users.users.dscv = {
    isNormalUser = true;
    description = "dscv";

    # User groups
    extraGroups = [
      "wheel" # sudo access
      "networkmanager" # network management
      "video" # video devices
      "audio" # audio devices
      "input" # input devices
      "render" # GPU rendering
    ];

    # ============================================================================
    # PASSWORD CONFIGURATION
    # ============================================================================
    #
    # SECURITY WARNING: initialPassword stores passwords in plain text in the
    # Nix store, which is world-readable! This is a security risk.
    #
    # RECOMMENDED: Use hashedPassword instead:
    #   1. Generate a hashed password: mkpasswd -m sha-512
    #   2. Replace the line below with: hashedPassword = "your-hash-here";
    #
    # TEMPORARY: For initial setup only, using initialPassword
    # TODO: Change to hashedPassword after first login
    #
    # To change password after setup:
    #   sudo passwd dscv
    #
    initialPassword = "changeme";

    # Recommended secure alternative (uncomment and add your hash):
    # hashedPassword = "$6$rounds=656000$...your-hash-here...";

    # User shell (default is bash, can be changed in home-manager)
    shell = pkgs.bash;
  };

  # Enable sudo for wheel group
  security.sudo.wheelNeedsPassword = true;
}

