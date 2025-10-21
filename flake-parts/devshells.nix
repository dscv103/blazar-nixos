# Development shells
# Define development environments for different projects
# Access with: nix develop or nix develop .#<shell-name>

{ inputs, ... }:

{
  perSystem = { config, self', inputs', pkgs, system, lib, ... }: {
    devShells = {
      # ======================================================================
      # DEFAULT SHELL - Full-stack development environment
      # ======================================================================
      default = pkgs.mkShell {
        name = "fullstack-dev";

        buildInputs = with pkgs; [
          # ====================================================================
          # PYTHON 3.13 ECOSYSTEM
          # ====================================================================
          python313 # Python 3.13.6
          uv # Extremely fast Python package installer and resolver
          hatch # Modern, extensible Python project manager
          ruff # Extremely fast Python linter and code formatter
          pyright # Type checker for Python (pyrefly alternative)
          bandit # Security oriented static analyser for Python

          # Python testing and coverage
          python313Packages.pytest # Testing framework
          python313Packages.pytest-cov # Coverage plugin for pytest
          python313Packages.coverage # Code coverage measurement

          # ====================================================================
          # NODE.JS ECOSYSTEM
          # ====================================================================
          nodejs_24 # Node.js 24.7.0 (latest)
          pnpm_10 # Fast, disk space efficient package manager (v10.15.0)
          bun # Incredibly fast JavaScript runtime and package manager

          # ====================================================================
          # FORMATTING AND LINTING
          # ====================================================================
          treefmt # One CLI to format the code tree

          # ====================================================================
          # NIX TOOLS
          # ====================================================================
          nixpkgs-fmt # Nix code formatter
          nil # Nix language server

          # ====================================================================
          # UTILITIES
          # ====================================================================
          git
          direnv # Automatic environment switching
          nix-direnv # Fast direnv integration for Nix
        ];

        shellHook = ''
          echo "╔════════════════════════════════════════════════════════════════╗"
          echo "║  Full-Stack Development Environment                            ║"
          echo "╚════════════════════════════════════════════════════════════════╝"
          echo ""
          echo "🐍 Python Tools:"
          echo "   • Python:    $(python --version)"
          echo "   • uv:        $(uv --version)"
          echo "   • hatch:     $(hatch --version)"
          echo "   • ruff:      $(ruff --version)"
          echo "   • pyright:   $(pyright --version)"
          echo "   • pytest:    $(pytest --version)"
          echo "   • bandit:    $(bandit --version)"
          echo ""
          echo "📦 Node.js Tools:"
          echo "   • Node.js:   $(node --version)"
          echo "   • pnpm:      $(pnpm --version)"
          echo "   • bun:       $(bun --version)"
          echo ""
          echo "🔧 Formatting & Linting:"
          echo "   • treefmt:   $(treefmt --version)"
          echo "   • ruff:      Linter, formatter, and import sorter"
          echo ""
          echo "💡 Quick Start:"
          echo "   • Python:    uv init / hatch new <project>"
          echo "   • Node.js:   pnpm init / bun init"
          echo "   • Format:    treefmt"
          echo ""
        '';

        # Environment variables
        env = {
          # Python
          PYTHONUNBUFFERED = "1";

          # UV configuration
          UV_PYTHON = "${pkgs.python313}/bin/python";

          # Node.js
          NODE_ENV = "development";
        };
      };

      # ======================================================================
      # NIXOS CONFIG SHELL - Minimal shell for NixOS configuration work
      # ======================================================================
      nixos = pkgs.mkShell {
        name = "nixos-config-dev";

        buildInputs = with pkgs; [
          # Nix tools
          nixpkgs-fmt
          nil # Nix language server

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
