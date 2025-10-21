# NixOS Profiles System

This directory contains modular profiles that can be easily toggled on/off to customize your system configuration.

## Overview

Profiles are organized into categories:
- **System Profiles** (`system/`) - NixOS-level configurations
- **User Profiles** (`user/`) - Home-manager user configurations
- **Feature Profiles** (`features/`) - Specific features that can be enabled/disabled

## How to Use Profiles

### Enabling/Disabling Profiles

Edit `hosts/blazar/profiles.nix` to enable or disable profiles:

```nix
{
  # System profiles
  system = {
    development.enable = true;   # Enable development tools
    multimedia.enable = false;   # Disable multimedia profile
  };

  # User profiles (per-user)
  users.dscv = {
    productivity.enable = true;  # Enable productivity apps
  };
}
```

### Available System Profiles

#### `system/development.nix`
Development tools and environments:
- Docker, Podman
- Database tools (PostgreSQL, Redis)
- Additional development utilities

#### `system/multimedia.nix`
Multimedia creation and editing:
- OBS Studio
- Kdenlive, Blender
- Audio production tools

#### `system/virtualization.nix` (TODO)
Virtualization and containers:
- VirtualBox, QEMU/KVM
- Virt-manager
- Container runtimes

#### `system/server.nix` (TODO)
Server-related services:
- Web servers (nginx, apache)
- Database servers
- Monitoring tools

### Available User Profiles

#### `user/productivity.nix`
Productivity applications:
- LibreOffice
- Obsidian, Joplin
- KeePassXC, Syncthing
- Note-taking apps

#### `user/minimal.nix` (TODO)
Minimal user environment:
- Only essential tools
- Lightweight alternatives
- Reduced package count

### Available Feature Profiles

#### `features/printing.nix`
Printing and scanning:
- CUPS
- Scanner support
- Printer drivers

#### `features/nvidia-gaming.nix` (TODO)
NVIDIA-specific gaming optimizations:
- NVIDIA-specific settings
- CUDA support
- GPU acceleration

#### `features/wayland-extras.nix` (TODO)
Additional Wayland tools:
- Screen recording
- Color pickers
- Clipboard managers

## Creating Custom Profiles

### System Profile Template

Create `system/myprofile.nix`:

```nix
{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.system.myprofile;
in
{
  options.profiles.system.myprofile = {
    enable = lib.mkEnableOption "My custom system profile";
  };

  config = lib.mkIf cfg.enable {
    # System packages
    environment.systemPackages = with pkgs; [
      # Add packages here
    ];

    # System services
    # services.myservice.enable = true;
  };
}
```

### User Profile Template

Create `user/myprofile.nix`:

```nix
{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.user.myprofile;
in
{
  options.profiles.user.myprofile = {
    enable = lib.mkEnableOption "My custom user profile";
  };

  config = lib.mkIf cfg.enable {
    # User packages
    home.packages = with pkgs; [
      # Add packages here
    ];

    # Program configurations
    # programs.myapp.enable = true;
  };
}
```

## Profile Combinations

You can enable multiple profiles simultaneously. They are designed to work together:

```nix
{
  system = {
    development.enable = true;
    multimedia.enable = true;
  };

  users.dscv = {
    productivity.enable = true;
  };

  features = {
    printing.enable = true;
  };
}
```

## Best Practices

1. **Keep profiles focused** - Each profile should have a clear purpose
2. **Avoid conflicts** - Profiles should not conflict with each other
3. **Document dependencies** - Note if a profile requires another profile
4. **Use lib.mkIf** - Always wrap config in `lib.mkIf cfg.enable`
5. **Test individually** - Test each profile independently before combining

## Troubleshooting

### Profile not taking effect
- Check that the profile is imported in `flake.nix`
- Verify `enable = true` in `hosts/blazar/profiles.nix`
- Rebuild with `sudo nixos-rebuild switch --flake .#blazar`

### Conflicts between profiles
- Check for duplicate package definitions
- Review service configurations
- Use `lib.mkDefault` for overridable defaults

### Performance issues
- Disable unused profiles
- Use `nix-store --gc` to clean up old packages
- Check `nix-store --query --requisites /run/current-system` for dependencies

