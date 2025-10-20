# Shell configuration (bash/zsh/fish)

{ ... }:

{
  # ========================================================================
  # BASH CONFIGURATION
  # ========================================================================
  programs.bash = {
    enable = true;
    
    # Shell aliases
    shellAliases = {
      # Nix shortcuts
      nrs = "sudo nixos-rebuild switch --flake .#blazar";
      nrb = "sudo nixos-rebuild build --flake .#blazar";
      nrt = "sudo nixos-rebuild test --flake .#blazar";
      nfc = "nix flake check";
      nfu = "nix flake update";
      
      # Common aliases
      ll = "ls -lah";
      la = "ls -A";
      l = "ls -CF";
      ".." = "cd ..";
      "..." = "cd ../..";
      
      # Git shortcuts
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline --graph --decorate";
      
      # System utilities
      update = "sudo nixos-rebuild switch --flake .#blazar";
      cleanup = "sudo nix-collect-garbage -d";
    };
    
    # Bash initialization
    initExtra = ''
      # Custom prompt (simple)
      PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
      
      # History settings
      export HISTSIZE=10000
      export HISTFILESIZE=10000
      export HISTCONTROL=ignoredups:erasedups
      
      # Append to history, don't overwrite
      shopt -s histappend
    '';
  };

  # ========================================================================
  # STARSHIP PROMPT (Optional - uncomment to enable)
  # ========================================================================
  # programs.starship = {
  #   enable = true;
  #   settings = {
  #     add_newline = true;
  #     character = {
  #       success_symbol = "[➜](bold green)";
  #       error_symbol = "[➜](bold red)";
  #     };
  #   };
  # };

  # ========================================================================
  # DIRENV (Optional - for per-directory environments)
  # ========================================================================
  # programs.direnv = {
  #   enable = true;
  #   nix-direnv.enable = true;
  # };
}

