# Network configuration

_:

{
  networking = {
    # Enable NetworkManager for easy network management
    networkmanager.enable = true;

    # Firewall configuration
    firewall = {
      enable = true;
      # allowedTCPPorts = [ ];
      # allowedUDPPorts = [ ];
    };

    # Enable IPv6
    enableIPv6 = true;

    # Hostname is set in hosts/blazar/configuration.nix
  };
}

