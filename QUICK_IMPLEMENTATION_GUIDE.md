# Quick Implementation Guide - High Priority Optimizations

This guide provides step-by-step instructions for implementing the highest priority recommendations from the comprehensive audit.

---

## 🔴 Priority 1: Remove Duplicate Font Packages

**Time:** 10 minutes  
**Impact:** Faster rebuilds, cleaner dependency graph

### Steps:

1. Create new fonts module:

```bash
cat > home/dscv/fonts.nix << 'EOF'
# Font configuration
# Centralized font management for all applications

{ pkgs, ... }:

{
  home.packages = with pkgs; [
    maple-mono.NF  # Maple Mono NerdFont - used by Ghostty, VSCode, Zed
  ];

  fonts.fontconfig.enable = true;
}
EOF
```

2. Edit `home/dscv/ghostty.nix` - remove lines 69-76:

```nix
# Remove this section:
# ============================================================================
# FONTS
# ============================================================================
# Install Maple Mono NerdFont (includes all the icons and ligatures)
home.packages = with pkgs; [
  maple-mono.NF
];

# Make fonts available to the system
fonts.fontconfig.enable = true;
```

3. Edit `home/dscv/vscode.nix` - remove lines 200-206:

```nix
# Remove this section:
# ============================================================================
# FONTS
# ============================================================================
# Ensure Maple Mono font is installed (already in ghostty.nix, but good to be explicit)
home.packages = with pkgs; [
  maple-mono.NF # Maple Mono NerdFont
];
```

4. Edit `flake.nix` - add fonts.nix to imports (around line 134):

```nix
users.dscv = {
  imports = [
    ./home/dscv/home.nix
    ./home/dscv/fonts.nix  # ADD THIS LINE
    ./home/dscv/theme.nix
    # ... rest of imports
  ];
};
```

5. Test:

```bash
sudo nixos-rebuild dry-build --flake .#blazar
```

---

## 🔴 Priority 2: Remove SDDM Package Duplication

**Time:** 5 minutes  
**Impact:** Reduced closure size

### Steps:

1. Edit `nixos/sddm.nix` - remove lines 76-84:

```nix
# Remove this entire section:
# ============================================================================
# SYSTEM PACKAGES
# ============================================================================
environment.systemPackages = [
  sddm-astronaut
  pkgs.kdePackages.qtsvg
  pkgs.kdePackages.qtmultimedia
  pkgs.kdePackages.qtvirtualkeyboard
];
```

2. Test:

```bash
sudo nixos-rebuild dry-build --flake .#blazar
```

---

## 🔴 Priority 3: Disable X Server (Use XWayland)

**Time:** 5 minutes  
**Impact:** 5-10 seconds faster boot, 100-200MB less memory

### Steps:

1. Edit `nixos/desktop.nix` - replace line 54:

```nix
# Replace:
services.xserver.enable = true;

# With:
# XWayland for X11 app compatibility (lightweight)
programs.xwayland.enable = true;
```

2. Update comment at line 47:

```nix
# ============================================================================
# ESSENTIAL SERVICES
# ============================================================================
# Note: Display manager (SDDM) is configured in nixos/sddm.nix
# Note: XWayland provides X11 compatibility without full X server
```

3. Test:

```bash
sudo nixos-rebuild dry-build --flake .#blazar
```

**Note:** If you encounter apps that don't work, you can re-enable X server temporarily.

---

## 🔴 Priority 4: Make Docker On-Demand

**Time:** 5 minutes  
**Impact:** 3-5 seconds faster boot, 200-300MB less idle memory

### Steps:

1. Edit `profiles/system/development.nix` - change line 66:

```nix
# Change:
enableOnBoot = true;

# To:
enableOnBoot = false;  # Start only when needed
```

2. Add usage note in comment:

```nix
virtualisation.docker = {
  enable = true;

  # Start Docker on-demand instead of at boot
  # Use: sudo systemctl start docker
  # Or add alias: alias docker-start='sudo systemctl start docker'
  enableOnBoot = false;
```

3. Optional - add shell alias in `home/dscv/shell.nix`:

```nix
shellAliases = {
  # ... existing aliases ...
  docker-start = "sudo systemctl start docker";
  docker-stop = "sudo systemctl stop docker";
};
```

4. Test:

```bash
sudo nixos-rebuild dry-build --flake .#blazar
```

---

## 🔴 Priority 5: Standardize Comment Styles

**Time:** 15 minutes  
**Impact:** Better readability, consistent codebase

### Standard Format:

```nix
# ============================================================================
# MAJOR SECTION NAME
# ============================================================================

# Subsection description
# ----------------------------------------------------------------------------

# Regular comment for single item
```

### Files to Update:

1. **flake.nix** - Already good, use as reference
2. **nixos/*.nix** - Update to match flake.nix style
3. **home/dscv/*.nix** - Update to match flake.nix style
4. **profiles/*.nix** - Update to match flake.nix style

### Example Fix for `nixos/packages.nix`:

```nix
# Before:
# ========================================================================
# TERMINAL EMULATORS
# ========================================================================

# After:
# ============================================================================
# TERMINAL EMULATORS
# ============================================================================
```

Use find and replace:
- Find: `# ========================================================================`
- Replace: `# ============================================================================`

---

## 🔴 Priority 6: Fix Hardcoded Hostname

**Time:** 20 minutes  
**Impact:** Multi-host support, better maintainability

### Steps:

1. Edit `flake.nix` - add hostName to specialArgs (around line 78):

```nix
specialArgs = {
  inherit inputs;
  hostName = "blazar";  # ADD THIS LINE
};
```

2. Edit `profiles/default.nix`:

```nix
# Change line 5-9:
{ lib, hostName, ... }:  # ADD hostName parameter

let
  # Load profile configuration from host
  profileConfig = import ../hosts/${hostName}/profiles.nix;  # USE hostName variable
in
```

3. Edit `profiles/user-default.nix`:

```nix
# Change line 5-9:
{ config, lib, hostName, ... }:  # ADD hostName parameter

let
  # Load profile configuration from host
  profileConfig = import ../hosts/${hostName}/profiles.nix;  # USE hostName variable
```

4. Edit `nixos/sddm.nix`:

```nix
# Change line 9-13:
{ pkgs, lib, hostName, ... }:  # ADD hostName parameter

let
  # Import host-specific variables
  inherit (import ../hosts/${hostName}/variables.nix) sddmTheme;  # USE hostName variable
```

5. Test:

```bash
sudo nixos-rebuild dry-build --flake .#blazar
```

---

## 🔴 Priority 7: Add Type Validation to Profiles

**Time:** 30 minutes  
**Impact:** Type safety, better error messages

### Steps:

1. Edit `profiles/default.nix` - add options:

```nix
{ lib, hostName, ... }:

let
  profileConfig = import ../hosts/${hostName}/profiles.nix;
in
{
  # ============================================================================
  # OPTIONS - Define profile types
  # ============================================================================
  
  options.profiles.system = {
    development = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable development profile with Docker, databases, and dev tools";
      };
    };
    
    multimedia = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable multimedia profile with OBS, video editing, and audio tools";
      };
    };
  };
  
  options.profiles.features = {
    printing = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable printing and scanning support with CUPS";
      };
    };
  };

  # ============================================================================
  # IMPORT ALL PROFILE MODULES
  # ============================================================================

  imports = [
    ./system/development.nix
    ./system/multimedia.nix
    ./features/printing.nix
  ];

  # ============================================================================
  # APPLY PROFILE CONFIGURATION
  # ============================================================================

  config.profiles.system = {
    development.enable = lib.mkDefault profileConfig.system.development.enable;
    multimedia.enable = lib.mkDefault profileConfig.system.multimedia.enable;
  };

  config.profiles.features = {
    printing.enable = lib.mkDefault profileConfig.features.printing.enable;
  };
}
```

2. Test:

```bash
sudo nixos-rebuild dry-build --flake .#blazar
```

---

## Testing All Changes

After implementing all high-priority changes:

1. **Dry build:**
```bash
sudo nixos-rebuild dry-build --flake .#blazar
```

2. **Check for errors:**
```bash
nix flake check
```

3. **Build and switch:**
```bash
sudo nixos-rebuild switch --flake .#blazar
```

4. **Verify boot time:**
```bash
systemd-analyze
systemd-analyze blame
```

5. **Check memory usage:**
```bash
free -h
```

6. **Verify services:**
```bash
systemctl list-units --type=service --state=running
```

---

## Rollback if Needed

If something breaks:

```bash
# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback to previous generation
sudo nixos-rebuild switch --rollback

# Or boot into previous generation from bootloader
```

---

## Expected Results

After implementing all high-priority changes:

- ✅ **Build time:** 20-30% faster evaluation
- ✅ **Boot time:** 8-13 seconds faster
- ✅ **Memory usage:** 300-500MB less at idle
- ✅ **Code quality:** More maintainable and consistent
- ✅ **Multi-host ready:** Easy to add new machines
- ✅ **Type safety:** Better error messages

---

## Next Steps

After completing high-priority items, move to medium-priority optimizations:

1. Binary cache optimization
2. Conditional profile loading
3. Hardware config reorganization
4. Documentation consolidation

See `COMPREHENSIVE_AUDIT_REPORT.md` for full details.

