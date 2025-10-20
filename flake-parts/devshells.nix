# Development shells
# Define development environments for different projects
# Access with: nix develop or nix develop .#<shell-name>

{ inputs, ... }:

{
  perSystem = { config, self', inputs', pkgs, system, lib, ... }: {
    devShells = {
      # Default development shell
      default = pkgs.mkShell {
        name = "nixos-config-dev";
        
        buildInputs = with pkgs; [
          # Nix tools
          nixpkgs-fmt
          nil  # Nix language server
          
          # Useful utilities
          git
        ];
        
        shellHook = ''
          echo "NixOS configuration development environment"
          echo "Run 'nixos-rebuild' commands to build and test the configuration"
        '';
      };
    };
  };
}

