# VSCode configuration
# Dracula theme with Maple Mono font

{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;

    # Use the default VSCode package
    package = pkgs.vscode;

    # Allow manual extension installation/updates
    mutableExtensionsDir = true;

    # VSCode extensions
    # Note: Using profiles instead of direct extensions for better organization
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        # ====================================================================
        # THEME - DRACULA
        # ====================================================================
        dracula-theme.theme-dracula

        # ====================================================================
        # NIX SUPPORT
        # ====================================================================
        bbenoist.nix # Nix language support
        jnoortheen.nix-ide # Nix IDE features

        # ====================================================================
        # PYTHON SUPPORT
        # ====================================================================
        ms-python.python # Python language support
        ms-python.vscode-pylance # Python language server

        # ====================================================================
        # GENERAL DEVELOPMENT
        # ====================================================================
        vscodevim.vim # Vim keybindings (optional - remove if you don't use vim)
        eamodio.gitlens # Git supercharged

        # ====================================================================
        # UTILITIES
        # ====================================================================
        editorconfig.editorconfig # EditorConfig support
      ];

      # VSCode user settings
      userSettings = {
        # ==================================================================
        # THEME - DRACULA
        # ==================================================================
        "workbench.colorTheme" = "Dracula";
        "workbench.iconTheme" = "vs-minimal"; # Use built-in minimal icons
        "workbench.preferredDarkColorTheme" = "Dracula";

        # ==================================================================
        # FONT - MAPLE MONO
        # ==================================================================
        "editor.fontFamily" = "'Maple Mono', 'monospace'";
        "editor.fontSize" = 14;
        "editor.fontLigatures" = true; # Enable ligatures
        "editor.lineHeight" = 1.6;
        "terminal.integrated.fontFamily" = "'Maple Mono'";
        "terminal.integrated.fontSize" = 14;

        # ==================================================================
        # EDITOR SETTINGS
        # ==================================================================
        "editor.formatOnSave" = true;
        "editor.formatOnPaste" = false;
        "editor.tabSize" = 2;
        "editor.insertSpaces" = true;
        "editor.detectIndentation" = true;
        "editor.renderWhitespace" = "boundary";
        "editor.rulers" = [ 80 120 ];
        "editor.cursorBlinking" = "smooth";
        "editor.cursorSmoothCaretAnimation" = "on";
        "editor.smoothScrolling" = true;
        "editor.minimap.enabled" = true;
        "editor.bracketPairColorization.enabled" = true;
        "editor.guides.bracketPairs" = "active";

        # ==================================================================
        # WORKBENCH SETTINGS
        # ==================================================================
        "workbench.startupEditor" = "none";
        "workbench.tree.indent" = 16;
        "workbench.list.smoothScrolling" = true;

        # ==================================================================
        # TERMINAL SETTINGS
        # ==================================================================
        "terminal.integrated.smoothScrolling" = true;
        "terminal.integrated.cursorBlinking" = true;
        "terminal.integrated.cursorStyle" = "line";

        # ==================================================================
        # FILES SETTINGS
        # ==================================================================
        "files.autoSave" = "afterDelay";
        "files.autoSaveDelay" = 1000;
        "files.trimTrailingWhitespace" = true;
        "files.insertFinalNewline" = true;
        "files.exclude" = {
          "**/.git" = true;
          "**/.svn" = true;
          "**/.hg" = true;
          "**/CVS" = true;
          "**/.DS_Store" = true;
          "**/Thumbs.db" = true;
          "**/__pycache__" = true;
          "**/.pytest_cache" = true;
          "**/.mypy_cache" = true;
          "**/.ruff_cache" = true;
          "**/node_modules" = true;
          "**/.venv" = true;
          "**/venv" = true;
          "**/result" = true;
          "**/result-*" = true;
        };

        # ==================================================================
        # PYTHON SETTINGS
        # ==================================================================
        "python.defaultInterpreterPath" = "python";
        "python.formatting.provider" = "none"; # Use ruff via extension
        "python.linting.enabled" = false; # Use ruff via extension
        "[python]" = {
          "editor.defaultFormatter" = "charliermarsh.ruff"; # Will need to install ruff extension
          "editor.formatOnSave" = true;
          "editor.codeActionsOnSave" = {
            "source.organizeImports" = "explicit";
            "source.fixAll" = "explicit";
          };
          "editor.tabSize" = 4;
        };

        # ==================================================================
        # NIX SETTINGS
        # ==================================================================
        "[nix]" = {
          "editor.defaultFormatter" = "jnoortheen.nix-ide";
          "editor.formatOnSave" = true;
          "editor.tabSize" = 2;
        };
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nil";
        "nix.formatterPath" = "nixpkgs-fmt";

        # ==================================================================
        # JAVASCRIPT/TYPESCRIPT SETTINGS
        # ==================================================================
        "[javascript]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode"; # Will need to install prettier extension
          "editor.tabSize" = 2;
        };
        "[typescript]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
          "editor.tabSize" = 2;
        };
        "[json]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
          "editor.tabSize" = 2;
        };
        "[jsonc]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
          "editor.tabSize" = 2;
        };

        # ==================================================================
        # MARKDOWN SETTINGS
        # ==================================================================
        "[markdown]" = {
          "editor.wordWrap" = "on";
          "editor.quickSuggestions" = {
            "comments" = "off";
            "strings" = "off";
            "other" = "off";
          };
        };

        # ==================================================================
        # GIT SETTINGS
        # ==================================================================
        "git.autofetch" = true;
        "git.confirmSync" = false;
        "git.enableSmartCommit" = true;

        # ==================================================================
        # TELEMETRY (DISABLE)
        # ==================================================================
        "telemetry.telemetryLevel" = "off";
        "redhat.telemetry.enabled" = false;
      };
    };
  };
}

