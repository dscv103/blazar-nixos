# Profile System Quick Guide

## Overview

The profile system allows you to easily enable/disable groups of packages and features without editing multiple configuration files. All profile toggles are centralized in `hosts/blazar/profiles.nix`.

## Quick Start

### 1. Enable a Profile

Edit `hosts/blazar/profiles.nix`:

```nix
{
  system = {
    development.enable = true;  # ← Change false to true
  };
}
```

### 2. Rebuild Your System

```bash
sudo nixos-rebuild switch --flake .#blazar
```

That's it! All development packages and tools are now installed.

## Available Profiles

### System Profiles (NixOS-level)

| Profile         | What It Includes                     | When to Enable          |
| --------------- | ------------------------------------ | ----------------------- |
| **development** | Docker, databases, dev tools         | You're a developer      |
| **multimedia**  | OBS, video editing, audio production | You create videos/music |

### User Profiles (Home-Manager level)

| Profile          | What It Includes                 | When to Enable        |
| ---------------- | -------------------------------- | --------------------- |
| **productivity** | LibreOffice, Obsidian, KeePassXC | You need office tools |

### Feature Profiles (Specific features)

| Profile      | What It Includes                | When to Enable             |
| ------------ | ------------------------------- | -------------------------- |
| **printing** | CUPS, printer drivers, scanners | You have a printer/scanner |

## Common Use Cases

### Developer Workstation

```nix
{
  system = {
    development.enable = true;
  };
  
  users.dscv = {
    productivity.enable = true;
  };
}
```

### Content Creator Setup

```nix
{
  system = {
    multimedia.enable = true;
  };

  users.dscv = {
    productivity.enable = true;
  };
}
```

### Full-Featured Workstation

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

## Profile Details

### Development Profile

**Packages:**
- Docker + Docker Compose
- PostgreSQL, Redis, SQLite clients
- Postman, Insomnia (API testing)
- Wireshark, tcpdump, nmap
- Build tools (make, cmake, pkg-config)

**Services:**
- Docker daemon with auto-prune
- Development ports opened (3000, 8000, etc.)

**Optional Services (commented out):**
- PostgreSQL server
- Redis server
- MySQL/MariaDB server

### Multimedia Profile

**Packages:**
- OBS Studio (with plugins)
- Kdenlive (video editing)
- Blender (3D creation)
- Audacity (audio editing)
- HandBrake (video conversion)
- FFmpeg (full build)

**Features:**
- Hardware video acceleration
- Virtual camera support (v4l2loopback)
- JACK audio support
- RTMP streaming ports

### Productivity Profile (User)

**Packages:**
- LibreOffice
- Obsidian (notes)
- Joplin (notes/tasks)
- KeePassXC (passwords)
- Syncthing (file sync)
- Pandoc (document conversion)

**Services:**
- Syncthing daemon

## Creating Custom Profiles

### 1. Create Profile File

For system profile: `profiles/system/myprofile.nix`
For user profile: `profiles/user/myprofile.nix`

### 2. Use Template

```nix
{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.system.myprofile;  # or .user.myprofile
in
{
  options.profiles.system.myprofile = {
    enable = lib.mkEnableOption "my custom profile";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Your packages here
    ];
  };
}
```

### 3. Import in Loader

Add to `profiles/default.nix` (system) or `profiles/user-default.nix` (user):

```nix
imports = [
  ./system/myprofile.nix
];

profiles.system.myprofile.enable = lib.mkDefault profileConfig.system.myprofile.enable;
```

### 4. Add to Configuration

Add to `hosts/blazar/profiles.nix`:

```nix
{
  system = {
    myprofile.enable = false;
  };
}
```

## Tips and Tricks

### Temporarily Test a Profile

Instead of editing `profiles.nix`, you can override on rebuild:

```bash
sudo nixos-rebuild switch --flake .#blazar --override-input profiles.system.gaming.enable true
```

### Check What's Enabled

```bash
nix eval .#nixosConfigurations.blazar.config.profiles.system.gaming.enable
```

### List All Packages from a Profile

```bash
nix-store --query --requisites /run/current-system | grep -i steam
```

### Disable All Profiles Quickly

Set all to `false` in `hosts/blazar/profiles.nix` or use a minimal profile.

### Profile Combinations

Profiles are designed to work together. Enable as many as you need!

## Troubleshooting

### Profile Not Taking Effect

1. Check `hosts/blazar/profiles.nix` has `enable = true`
2. Verify profile is imported in `profiles/default.nix`
3. Rebuild: `sudo nixos-rebuild switch --flake .#blazar`
4. Check for errors: `journalctl -xe`

### Too Many Packages

Disable unused profiles to reduce system size:

```bash
# Check system size
nix path-info -Sh /run/current-system

# Clean up old generations
sudo nix-collect-garbage -d
```

### Conflicts Between Profiles

Profiles are designed not to conflict, but if you encounter issues:

1. Check for duplicate package definitions
2. Review service configurations
3. Disable one profile at a time to isolate the issue

## Performance Impact

| Profile      | Disk Space | Build Time | RAM Usage |
| ------------ | ---------- | ---------- | --------- |
| development  | ~5 GB      | +3 min     | +1 GB     |
| multimedia   | ~8 GB      | +4 min     | +1.5 GB   |
| productivity | ~2 GB      | +2 min     | +500 MB   |

*Estimates vary based on dependencies and cache*

## Next Steps

1. Review `profiles/README.md` for detailed documentation
2. Check individual profile files in `profiles/system/` and `profiles/user/`
3. Customize `hosts/blazar/profiles.nix` for your needs
4. Create custom profiles for your specific workflows

## See Also

- `profiles/README.md` - Detailed profile documentation
- `hosts/blazar/profiles.nix` - Profile configuration file
- `CONFIG_README.md` - Overall system configuration guide

