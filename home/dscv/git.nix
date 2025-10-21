# Git configuration

_:

{
  programs.git = {
    enable = true;

    # Git configuration (using modern settings structure)
    settings = {
      # User information
      user = {
        name = "dscv";
        email = "dvitrano@me.com";
      };

      # Git aliases
      alias = {
        st = "status";
        co = "checkout";
        br = "branch";
        ci = "commit";
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
        visual = "log --oneline --graph --decorate --all";
        amend = "commit --amend";
      };

      # Additional configuration
      init = {
        defaultBranch = "main";
      };
      pull = {
        rebase = false;
      };
      core = {
        editor = "vim";
      };
      color = {
        ui = "auto";
      };
    };
  };
}

