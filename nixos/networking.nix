# Network configuration

{ config, lib, pkgs, ... }:

{
  # Enable NetworkManager for easy network management
  networking.networkmanager.enable = true;

  # Firewall configuration
  networking.firewall = {
    enable = true;
    # allowedTCPPorts = [ ];
    # allowedUDPPorts = [ ];
  };

  # Enable IPv6
  networking.enableIPv6 = true;

  # Hostname is set in hosts/blazar/configuration.nix
}

