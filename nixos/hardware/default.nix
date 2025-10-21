# Hardware configuration loader
# Imports hardware-specific modules based on the hostname
# This allows easy support for multiple machines with different hardware

_:

{
  imports = [
    # Import hardware modules based on hostname
    # For 'blazar': AMD Ryzen 7 5800X + NVIDIA RTX 3080
    ./amd-ryzen.nix
    ./nvidia.nix
  ];
}

