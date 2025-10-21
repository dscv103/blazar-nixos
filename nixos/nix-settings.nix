# Nix daemon settings and configuration
# Note: Binary caches are configured in flake.nix

_:

{
  # Nix settings
  nix.settings = {
    # Allow unfree packages
    allowed-unfree = true;

    # Build settings
    max-jobs = "auto";
    cores = 0; # Use all available cores

    # Trusted users (can use --option and override settings)
    trusted-users = [ "root" "@wheel" ];

    # Keep build dependencies for debugging
    keep-outputs = true;
    keep-derivations = true;
  };

  # Allow unfree packages globally
  nixpkgs.config.allowUnfree = true;

  # Automatic Nix store optimization is configured in flake.nix
  # Garbage collection is configured in flake.nix
}

