# Host-specific configuration for blazar
# This file contains only host-specific settings
# All other configuration is in nixos/ modules (flat import pattern)

{ ... }:

{
  # Hostname
  networking.hostName = "blazar";

  # NixOS release version - DO NOT CHANGE without reading release notes
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of your first install.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}

