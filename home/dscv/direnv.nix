# Direnv configuration
# Automatic environment switching for project directories

_:

{
  # ================================================================================
  # DIRENV
  # ================================================================================
  programs.direnv = {
    enable = true;

    # Enable nix-direnv for better Nix integration
    nix-direnv.enable = true;

    # Enable stdlib for additional direnv functions
    enableBashIntegration = true;
    enableZshIntegration = true;

    # Configuration
    config = {
      # Whitelist directories (optional - direnv will ask for permission by default)
      # whitelist = {
      #   prefix = [
      #     "~/projects"
      #     "~/work"
      #   ];
      # };

      # Global settings
      global = {
        # Hide direnv output
        hide_env_diff = false;

        # Warn on timeout
        warn_timeout = "30s";
      };
    };
  };
}

