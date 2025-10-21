# Profile System Architecture

## Overview

The profile system provides a modular, declarative way to enable/disable groups of packages and features. It's built on NixOS modules and uses the `lib.mkEnableOption` pattern for clean toggles.

## Directory Structure

```
profiles/
├── README.md              # User documentation
├── ARCHITECTURE.md        # This file - technical details
├── default.nix            # System profile loader
├── user-default.nix       # User profile loader
│
├── system/                # System-level profiles (NixOS)
│   ├── development.nix
│   ├── multimedia.nix
│   ├── virtualization.nix (TODO)
│   └── server.nix (TODO)
│
├── user/                  # User-level profiles (Home-Manager)
│   ├── productivity.nix
│   └── minimal.nix (TODO)
│
└── features/              # Feature-specific profiles
    ├── printing.nix
    ├── nvidia-gaming.nix (TODO)
    └── wayland-extras.nix (TODO)

hosts/blazar/
└── profiles.nix           # Profile configuration (user edits this)
```

## Data Flow

```
┌─────────────────────────────────────────────────────────────┐
│ hosts/blazar/profiles.nix                                   │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ {                                                       │ │
│ │   system.development.enable = true;                    │ │
│ │   users.dscv.productivity.enable = true;               │ │
│ │   features.printing.enable = true;                     │ │
│ │ }                                                       │ │
│ └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ flake.nix                                                   │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ modules = [                                             │ │
│ │   ./profiles/default.nix        # System profiles      │ │
│ │   ...                                                   │ │
│ │   home-manager.users.dscv = {                          │ │
│ │     imports = [                                        │ │
│ │       ./profiles/user-default.nix  # User profiles     │ │
│ │     ];                                                  │ │
│ │   };                                                    │ │
│ │ ]                                                       │ │
│ └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                            │
                ┌───────────┴───────────┐
                ▼                       ▼
┌───────────────────────────┐ ┌───────────────────────────┐
│ profiles/default.nix      │ │ profiles/user-default.nix │
│ (System Profile Loader)   │ │ (User Profile Loader)     │
├───────────────────────────┤ ├───────────────────────────┤
│ • Imports all system      │ │ • Imports all user        │
│   profile modules         │ │   profile modules         │
│ • Reads profiles.nix      │ │ • Reads profiles.nix      │
│ • Applies configuration   │ │ • Applies configuration   │
└───────────────────────────┘ └───────────────────────────┘
                │                       │
        ┌───────┴───────┐       ┌───────┴───────┐
        ▼               ▼       ▼               ▼
┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│ system/     │ │ features/   │ │ user/       │ │             │
│ development │ │ printing    │ │ productivity│ │             │
└─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘
```

## Module Pattern

Each profile follows this pattern:

```nix
{ config, lib, pkgs, ... }:

let
  # Reference to this profile's config
  cfg = config.profiles.system.development;
in
{
  # Define the option
  options.profiles.system.development = {
    enable = lib.mkEnableOption "development profile";
  };

  # Apply configuration only if enabled
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ ... ];
    # ... other configuration
  };
}
```

## Profile Types

### System Profiles (`profiles/system/`)

- **Scope**: NixOS system-level
- **Applied to**: Entire system
- **Can configure**:
  - `environment.systemPackages`
  - `services.*`
  - `boot.*`
  - `hardware.*`
  - `networking.*`
  - System-wide settings

### User Profiles (`profiles/user/`)

- **Scope**: Home-Manager user-level
- **Applied to**: Specific user
- **Can configure**:
  - `home.packages`
  - `programs.*`
  - `services.*` (user services)
  - User-specific settings

### Feature Profiles (`profiles/features/`)

- **Scope**: NixOS system-level (specific features)
- **Applied to**: Entire system
- **Purpose**: Standalone features that don't fit in other categories
- **Examples**: Bluetooth, printing, specific hardware support

## Configuration Loading

### System Profiles

1. `flake.nix` imports `profiles/default.nix`
2. `profiles/default.nix`:
   - Imports all system profile modules
   - Reads `hosts/blazar/profiles.nix`
   - Sets `profiles.system.*.enable` based on config

### User Profiles

1. `flake.nix` imports `profiles/user-default.nix` in home-manager
2. `profiles/user-default.nix`:
   - Imports all user profile modules
   - Reads `hosts/blazar/profiles.nix`
   - Extracts user-specific config
   - Sets `profiles.user.*.enable` based on config

## Option Namespace

All profile options are under the `profiles` namespace:

```
config.profiles
├── system
│   ├── development.enable
│   ├── multimedia.enable
│   ├── virtualization.enable (TODO)
│   └── server.enable (TODO)
│
├── user
│   ├── productivity.enable
│   └── minimal.enable (TODO)
│
└── features
    ├── printing.enable
    ├── nvidia-gaming.enable (TODO)
    └── wayland-extras.enable (TODO)
```

## Adding a New Profile

### 1. Create Profile Module

**System profile**: `profiles/system/myprofile.nix`

```nix
{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.system.myprofile;
in
{
  options.profiles.system.myprofile = {
    enable = lib.mkEnableOption "my custom profile";
  };

  config = lib.mkIf cfg.enable {
    # Your configuration here
  };
}
```

### 2. Import in Loader

Edit `profiles/default.nix`:

```nix
{
  imports = [
    ./system/development.nix
    ./system/multimedia.nix
    ./system/myprofile.nix  # Add this
  ];

  profiles.system = {
    development.enable = lib.mkDefault profileConfig.system.development.enable;
    multimedia.enable = lib.mkDefault profileConfig.system.multimedia.enable;
    myprofile.enable = lib.mkDefault profileConfig.system.myprofile.enable;  # Add this
  };
}
```

### 3. Add to Configuration File

Edit `hosts/blazar/profiles.nix`:

```nix
{
  system = {
    development.enable = false;
    multimedia.enable = false;
    myprofile.enable = false;  # Add this
  };
}
```

## Design Principles

### 1. Separation of Concerns

- **Configuration** (`hosts/blazar/profiles.nix`): What to enable
- **Definition** (`profiles/*/`): How it's implemented
- **Loading** (`profiles/default.nix`): Wiring it together

### 2. Declarative

All profiles are declared in one place (`profiles.nix`), making it easy to see what's enabled.

### 3. Composable

Profiles can be combined freely. They should not conflict with each other.

### 4. Overridable

Using `lib.mkDefault` allows profiles to be overridden by other modules if needed.

### 5. Self-Documenting

Each profile includes comments explaining what it provides and when to use it.

## Benefits

### For Users

- **Simple**: One file to edit (`profiles.nix`)
- **Clear**: See all enabled features at a glance
- **Safe**: Type-checked, validated configuration
- **Fast**: Only rebuild what changed

### For Maintainers

- **Modular**: Each profile is independent
- **Testable**: Can test profiles individually
- **Extensible**: Easy to add new profiles
- **Maintainable**: Clear structure and patterns

## Comparison with Alternatives

### vs. Commenting Out Packages

**Before (manual):**
```nix
environment.systemPackages = with pkgs; [
  steam
  # lutris  # Commented out
  # gamemode  # Commented out
];
```

**After (profiles):**
```nix
# In profiles.nix
system.gaming.enable = false;  # One line to disable everything
```

### vs. Multiple Configuration Files

**Before (scattered):**
- `gaming.nix` - manually imported
- `development.nix` - manually imported
- Need to edit `flake.nix` to enable/disable

**After (centralized):**
- All imports in `profiles/default.nix`
- All toggles in `hosts/blazar/profiles.nix`
- No need to edit `flake.nix`

## Future Enhancements

### Planned Features

1. **Profile Dependencies**: Automatically enable required profiles
2. **Profile Conflicts**: Warn about conflicting profiles
3. **Profile Presets**: Pre-configured combinations (e.g., "developer", "gamer")
4. **Profile Metrics**: Show disk space and build time per profile
5. **Profile Validation**: Check for common misconfigurations

### Potential Profiles

- `system/virtualization.nix` - VirtualBox, QEMU/KVM
- `system/server.nix` - Web servers, databases
- `user/minimal.nix` - Minimal package set
- `features/nvidia-gaming.nix` - NVIDIA-specific gaming optimizations
- `features/wayland-extras.nix` - Additional Wayland tools

## Technical Details

### Why `lib.mkDefault`?

Using `lib.mkDefault` in the loader allows profiles to be overridden:

```nix
# In profiles/default.nix
profiles.system.gaming.enable = lib.mkDefault profileConfig.system.gaming.enable;

# Can be overridden in another module
profiles.system.gaming.enable = lib.mkForce true;
```

### Why Separate Loaders?

System and user profiles have different scopes:
- System profiles: NixOS module system
- User profiles: Home-Manager module system

They need separate loaders to access the correct configuration context.

### Why Not Use Flake Inputs?

Profiles are configuration, not dependencies. They should be:
- Part of the repository
- Version-controlled with the config
- Easy to modify without changing flake.lock

## See Also

- `profiles/README.md` - User documentation
- `PROFILES_GUIDE.md` - Quick start guide
- NixOS Module System: https://nixos.org/manual/nixos/stable/#sec-writing-modules

