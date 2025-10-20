# Nixpkgs overlays
# Define overlays to modify or add packages to nixpkgs

{ inputs, ... }:

{
  perSystem = { config, self', inputs', pkgs, system, lib, ... }: {
    # Per-system overlays can be defined here
    # overlayAttrs = {
    #   # Attributes to add to pkgs
    # };
  };

  flake = {
    # Flake-level overlays that can be used by other flakes
    overlays = {
      # default = final: prev: {
      #   # Override or add packages here
      #   # my-package = prev.my-package.overrideAttrs (old: {
      #   #   version = "custom";
      #   # });
      # };
    };
  };
}

