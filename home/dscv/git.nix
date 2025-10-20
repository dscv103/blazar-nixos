# Git configuration

{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    
    # User information
    userName = "dscv";
    userEmail = "dvitrano@me.com";
    
    # Git aliases
    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
      ci = "commit";
      unstage = "reset HEAD --";
      last = "log -1 HEAD";
      visual = "log --oneline --graph --decorate --all";
      amend = "commit --amend";
    };
    
    # Extra configuration
    extraConfig = {
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

