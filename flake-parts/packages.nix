# Custom package definitions
# Define custom packages here that will be available as flake outputs
# Access with: nix build .#<package-name>

{ inputs, ... }:

{
  perSystem = { config, self', inputs', pkgs, system, lib, ... }: {
    packages = {
      # Example custom package
      # my-custom-package = pkgs.stdenv.mkDerivation {
      #   pname = "my-custom-package";
      #   version = "1.0.0";
      #   src = ./.;
      #   buildInputs = [ ];
      #   installPhase = ''
      #     mkdir -p $out/bin
      #     cp my-script $out/bin/
      #   '';
      # };
    };
  };
}

