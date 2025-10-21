# Zed IDE configuration
# Dracula theme with Maple Mono font

{ pkgs, ... }:

{
  programs.zed-editor = {
    enable = true;

    # Use the default Zed package
    package = pkgs.zed-editor;

    # Install Dracula theme extension
    extensions = [
      "dracula-theme"
    ];

    # Zed user settings
    userSettings = {
      # ====================================================================
      # THEME - DRACULA
      # ====================================================================
      theme = {
        mode = "dark";
        light = "One Light";
        dark = "Dracula";
      };

      # ====================================================================
      # FONT - MAPLE MONO
      # ====================================================================
      buffer_font_family = "Maple Mono";
      buffer_font_size = 14;
      buffer_font_features = {
        # Enable ligatures
        calt = true;
      };

      # UI font
      ui_font_family = "Maple Mono";
      ui_font_size = 14;

      # Terminal font
      terminal = {
        font_family = "Maple Mono";
        font_size = 14;
        line_height = "comfortable";
      };

      # ====================================================================
      # EDITOR SETTINGS
      # ====================================================================
      # Cursor
      cursor_blink = true;

      # Scrolling
      scroll_sensitivity = 1.0;

      # Line numbers
      relative_line_numbers = false;

      # Indentation
      tab_size = 2;
      hard_tabs = false;

      # Wrapping
      soft_wrap = "none";

      # Whitespace
      show_whitespaces = "selection";

      # Rulers
      vertical_scroll_margin = 3;

      # Auto-save
      autosave = "on_focus_change";

      # Format on save
      format_on_save = "on";

      # Trim trailing whitespace
      remove_trailing_whitespace_on_save = true;

      # Ensure newline at end of file
      ensure_final_newline_on_save = true;

      # ====================================================================
      # UI SETTINGS
      # ====================================================================
      # Toolbar
      toolbar = {
        breadcrumbs = true;
        quick_actions = true;
      };

      # Tabs
      tabs = {
        close_position = "right";
        git_status = true;
      };

      # Project panel
      project_panel = {
        button = true;
        default_width = 240;
        dock = "left";
        git_status = true;
      };

      # Outline panel
      outline_panel = {
        button = true;
        default_width = 240;
        dock = "right";
      };

      # Collaboration panel
      collaboration_panel = {
        button = true;
        dock = "left";
      };

      # ====================================================================
      # GIT SETTINGS
      # ====================================================================
      git = {
        git_gutter = "tracked_files";
        inline_blame = {
          enabled = true;
        };
      };

      # ====================================================================
      # LANGUAGE SETTINGS
      # ====================================================================
      # Python
      languages = {
        Python = {
          tab_size = 4;
          format_on_save = {
            external = {
              command = "ruff";
              arguments = [ "format" "-" ];
            };
          };
          code_actions_on_format = {
            source.organizeImports = true;
            source.fixAll = true;
          };
        };

        # Nix
        Nix = {
          tab_size = 2;
          format_on_save = {
            external = {
              command = "nixpkgs-fmt";
            };
          };
        };

        # JavaScript/TypeScript
        JavaScript = {
          tab_size = 2;
          format_on_save = "on";
        };

        TypeScript = {
          tab_size = 2;
          format_on_save = "on";
        };

        # JSON
        JSON = {
          tab_size = 2;
          format_on_save = "on";
        };

        # Markdown
        Markdown = {
          soft_wrap = "editor_width";
        };
      };

      # ====================================================================
      # LSP SETTINGS
      # ====================================================================
      lsp = {
        # Nil (Nix LSP)
        nil = {
          binary = {
            path = "${pkgs.nil}/bin/nil";
          };
        };

        # Python LSP (Pyright/Pylance alternative)
        # Zed has built-in Python support
        python-language-server = {
          binary = {
            path = "${pkgs.python313}/bin/python";
          };
        };
      };

      # ====================================================================
      # TELEMETRY (DISABLE)
      # ====================================================================
      telemetry = {
        diagnostics = false;
        metrics = false;
      };

      # ====================================================================
      # PERFORMANCE
      # ====================================================================
      # File watching
      file_scan_exclusions = [
        "**/.git"
        "**/.svn"
        "**/.hg"
        "**/CVS"
        "**/.DS_Store"
        "**/Thumbs.db"
        "**/__pycache__"
        "**/.pytest_cache"
        "**/.mypy_cache"
        "**/.ruff_cache"
        "**/node_modules"
        "**/.venv"
        "**/venv"
        "**/result"
        "**/result-*"
      ];

      # ====================================================================
      # VIM MODE (OPTIONAL)
      # ====================================================================
      # Uncomment to enable vim mode
      # vim_mode = true;

      # ====================================================================
      # COLLABORATION
      # ====================================================================
      # Enable collaboration features
      features = {
        copilot = false; # Set to true if you have GitHub Copilot
      };
    };

    # ====================================================================
    # KEYBINDINGS (OPTIONAL)
    # ====================================================================
    userKeymaps = [
      # Add custom keybindings here
      # Example:
      # {
      #   context = "Editor";
      #   bindings = {
      #     "ctrl-/" = "editor::ToggleComments";
      #   };
      # }
    ];
  };

  # ============================================================================
  # FONTS
  # ============================================================================
  # Ensure Maple Mono font is installed (already in ghostty.nix and vscode.nix)
  home.packages = with pkgs; [
    maple-mono.NF # Maple Mono NerdFont
  ];
}

