# System profiles default loader
# Imports all system-level profile modules
# System profiles provide collections of packages and services for specific use cases

{
  imports = [
    ./development.nix
    ./multimedia.nix
  ];
}

