# Research Findings - NixOS Configuration Update
## October 2025

This document summarizes the research conducted to verify and update the NixOS implementation plan and checklist with current best practices and accurate configuration syntax as of October 2025.

---

## Research Methodology

1. **Web searches** for current NixOS documentation and community discussions
2. **NixOS options search** using the official search.nixos.org database
3. **GitHub repository verification** for niri-flake and related projects
4. **Cross-referencing** multiple sources to confirm accuracy

---

## Key Findings and Updates

### 1. Hardware Graphics Configuration ✅ CRITICAL UPDATE

**Finding**: NixOS renamed `hardware.opengl` to `hardware.graphics` in version 24.05+

**Evidence**:
- Multiple GitHub issues and discussions from 2024 confirming the rename
- NixOS options search shows `hardware.graphics.*` as current options
- No `hardware.opengl` options found in current NixOS unstable

**Updates Made**:
- Changed all references from `hardware.opengl` to `hardware.graphics`
- Added version note: "renamed from hardware.opengl in NixOS 24.05+"
- Added backward compatibility note for older NixOS versions

**Impact**: HIGH - This is a breaking change that would cause configuration errors on NixOS 24.05+

**References**:
- https://discourse.nixos.org/t/nvidia-open-breaks-hardware-acceleration/58770
- NixOS options: hardware.graphics.enable, hardware.graphics.enable32Bit

---

### 2. NVIDIA Wayland Configuration ✅ VERIFIED & ENHANCED

**Findings**:

#### a) Core Options - Still Valid
- `hardware.nvidia.modesetting.enable = true;` - REQUIRED for Wayland
- `nvidia-drm.modeset=1` kernel parameter - CRITICAL
- `nvidia-drm.fbdev=1` kernel parameter - Valid for kernel 6.6+
- Environment variables (LIBVA_DRIVER_NAME, GBM_BACKEND, etc.) - All current

**Evidence**:
- NixOS options search confirms all hardware.nvidia.* options
- GitHub issues from 2024-2025 show active use of these parameters
- NVIDIA developer forums confirm fbdev parameter for recent kernels

#### b) GPU System Processor (GSP) - NEW INFORMATION
- `hardware.nvidia.gsp.enable` option exists and is valid
- Recommended for RTX 20-series and newer cards
- Offloads GPU initialization to GPU firmware
- Becoming default in newer driver versions

**Evidence**:
- NixOS option: hardware.nvidia.gsp.enable (boolean)
- Description: "Whether to enable the GPU System Processor (GSP) on the video card"

#### c) forceFullCompositionPipeline - DEPRECATED WARNING
- Option still exists but NOT recommended for Wayland
- Can reduce performance and cause WebGL issues
- Generally unnecessary with proper Wayland configuration

**Updates Made**:
- Added section on GSP for RTX cards
- Updated warnings about forceFullCompositionPipeline
- Clarified which options are critical vs optional
- Added note about nvidia-drm.fbdev=1 for kernel 6.6+

**Impact**: MEDIUM - Adds important information for RTX card users, clarifies deprecated options

**References**:
- NixOS options search: hardware.nvidia.*
- https://github.com/NixOS/nixpkgs/issues/302059 (fbdev parameter discussion)

---

### 3. Niri Compositor & Flake ✅ VERIFIED

**Findings**:

#### a) Repository & Structure - Current
- Repository: `github:sodiboo/niri-flake` - Active and maintained
- Modules: `nixosModules.niri` and `homeModules.niri` - Correct
- Binary cache: `niri.cachix.org` - Active
- Trusted public key: `niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964=`

**Evidence**:
- Direct fetch from https://github.com/sodiboo/niri-flake
- README confirms module structure and binary cache
- Last updated: Recent (active development)

#### b) Configuration Method - Verified
- `programs.niri.settings` - Preferred declarative configuration
- `programs.niri.config` - Alternative for raw KDL or structured config
- Build-time validation - Confirmed feature
- Automatic binary cache setup via NixOS module

**Evidence**:
- niri-flake README and docs.md
- NixOS options: programs.niri.enable, programs.niri.package

#### c) Package Versions
- `niri-stable` - Latest stable release
- `niri-unstable` - Latest commit to main branch
- Available via overlay: `inputs.niri.overlays.niri`

**Updates Made**:
- Confirmed repository URL and structure
- Added note about automatic binary cache configuration
- Added reference to official documentation
- Clarified package version options

**Impact**: LOW - Information was mostly correct, added clarifications

**References**:
- https://github.com/sodiboo/niri-flake
- https://github.com/sodiboo/niri-flake/blob/main/docs.md

---

### 4. XDG Desktop Portal Configuration ⚠️ SYNTAX UPDATE

**Finding**: Portal configuration syntax has evolved

**Old Syntax** (in original plan):
```nix
xdg.portal = {
  enable = true;
  wlr.enable = true;
  extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  config.common.default = "*";  # ← Outdated
};
```

**Current Syntax** (2025):
```nix
xdg.portal = {
  enable = true;
  wlr.enable = true;
  extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  config = {
    common = {
      default = [ "gtk" ];
    };
    niri = {
      default = [ "wlr" "gtk" ];
    };
  };
};
```

**Evidence**:
- NixOS options: xdg.portal.config (attribute set of attribute set)
- Reddit discussions from 2023-2024 about portal configuration changes
- xdg-desktop-portal 1.17+ reworked portal loading

**Updates Made**:
- Updated config syntax to use proper attribute set structure
- Added per-desktop configuration example
- Added reference to XDG Desktop Portal documentation
- Noted that niri-flake may auto-configure this

**Impact**: MEDIUM - Incorrect syntax could cause portal issues

**References**:
- NixOS options: xdg.portal.config, xdg.portal.configPackages
- https://www.reddit.com/r/NixOS/comments/184hbt6/changes_to_xdgportals/
- https://github.com/flatpak/xdg-desktop-portal/blob/main/doc/portals.conf.rst.in

---

### 5. PipeWire Audio Configuration ✅ VERIFIED & ENHANCED

**Findings**:

#### a) Modern Configuration Option
- `services.pipewire.audio.enable = true;` - Modern way to enable PipeWire as primary sound server
- Automatically configures ALSA and PulseAudio compatibility
- Available in recent NixOS versions

**Evidence**:
- NixOS option: services.pipewire.audio.enable (boolean)
- Description: "Whether to use PipeWire as the primary sound server"

#### b) Legacy Options - Still Valid
- Individual enables (alsa, pulse, jack) still work
- Maintained for backward compatibility
- Can be used alongside audio.enable

**Updates Made**:
- Added `services.pipewire.audio.enable = true;` as recommended option
- Noted it as "modern way" to configure PipeWire
- Kept legacy options with clarification
- Added reference to PipeWire wiki

**Impact**: LOW - Original configuration works, but modern option is cleaner

**References**:
- NixOS options: services.pipewire.*
- https://nixos.wiki/wiki/PipeWire

---

### 6. Greetd Display Manager ✅ VERIFIED

**Findings**:

#### a) Configuration Options - Current
- `services.greetd.enable` - Main enable option
- `services.greetd.settings` - TOML configuration
- `services.greetd.useTextGreeter` - For TUI greeters like tuigreet
- `services.greetd.restart` - Control restart behavior

**Evidence**:
- NixOS options search: services.greetd.*
- All options confirmed as current

#### b) Tuigreet Integration
- Available in nixpkgs as `pkgs.greetd.tuigreet`
- Configured via services.greetd.settings
- Works well with Wayland compositors

**Updates Made**:
- No changes needed - information was accurate
- Confirmed current configuration approach

**Impact**: NONE - Information was already correct

**References**:
- NixOS options: services.greetd.*
- https://github.com/apognu/tuigreet

---

### 7. AMD CPU Configuration ✅ VERIFIED

**Findings**:

#### a) AMD P-State Driver
- Kernel parameter: `amd_pstate=active` - Still current
- Supported on kernel 6.1+
- Recommended for Ryzen CPUs (2nd gen and newer)

**Evidence**:
- Reddit discussions from 2024-2025 confirming usage
- Kernel documentation confirms parameter

#### b) Other AMD Options
- `hardware.cpu.amd.updateMicrocode = true;` - Still valid
- `boot.kernelModules = [ "kvm-amd" ];` - Still valid
- CPU governor options - Still valid

**Updates Made**:
- No changes needed - information was accurate
- Confirmed kernel version requirement (6.1+)

**Impact**: NONE - Information was already correct

**References**:
- https://www.reddit.com/r/NixOS/comments/1emk6sr/nixos_is_awesome_and_a_little_guide_on_using/

---

## Summary of Changes

### IMPLEMENTATION_PLAN.md Updates:

1. **Added Document Information Section** (lines 1-35)
   - Last updated date
   - Target NixOS version
   - Version notes for breaking changes
   - Key resource links

2. **Graphics Configuration** (Section 3.5)
   - Renamed hardware.opengl → hardware.graphics
   - Added version compatibility note

3. **NVIDIA GSP Section** (New Section 3.6)
   - Added information about GPU System Processor
   - Recommendations for RTX cards

4. **NVIDIA Workarounds** (Section 3.7, formerly 3.6)
   - Updated warnings about forceFullCompositionPipeline
   - Clarified which workarounds are deprecated

5. **XDG Portal Configuration** (Section 4.4)
   - Updated config syntax to current format
   - Added per-desktop configuration
   - Added documentation reference

6. **PipeWire Configuration** (Section 5.10)
   - Added services.pipewire.audio.enable option
   - Noted as modern configuration method
   - Added wiki reference

7. **Graphics Options Reference** (Section 9.3)
   - Updated with rename note
   - Added extraPackages option

8. **Binary Cache** (Section 10.3)
   - Added note about automatic configuration
   - Added reference to niri-flake GitHub

### IMPLEMENTATION_CHECKLIST.md Updates:

1. **Added Header Information**
   - Last updated date
   - Target NixOS version
   - Important notes for 2025

2. **Graphics Support** (Phase 3.4)
   - Added rename note

3. **NVIDIA Optional Settings** (Phase 3.5)
   - Updated GSP recommendation
   - Added deprecation warning for forceFullCompositionPipeline

4. **XDG Portal** (Phase 4.3)
   - Added config syntax example

5. **PipeWire Audio** (Phase 5.1)
   - Added audio.enable option
   - Added clarifying notes for each option

---

## Verification Status

| Component | Status | Confidence | Notes |
|-----------|--------|------------|-------|
| hardware.graphics rename | ✅ Verified | High | Breaking change in 24.05+ |
| NVIDIA options | ✅ Verified | High | All options confirmed current |
| NVIDIA GSP | ✅ Verified | High | Valid option for RTX cards |
| niri-flake | ✅ Verified | High | Active repository, current structure |
| XDG portal config | ✅ Updated | High | Syntax modernized |
| PipeWire | ✅ Enhanced | High | Added modern option |
| Greetd | ✅ Verified | High | No changes needed |
| AMD P-State | ✅ Verified | High | Still current |

---

## Recommendations

1. **Use NixOS unstable** or 24.05+ for latest features and the hardware.graphics option
2. **Enable niri binary cache** for faster builds (automatic with NixOS module)
3. **Use programs.niri.settings** for declarative niri configuration
4. **Enable GSP** if using RTX 20-series or newer NVIDIA cards
5. **Avoid forceFullCompositionPipeline** on Wayland unless absolutely necessary
6. **Use services.pipewire.audio.enable** for cleaner PipeWire configuration

---

## Future Monitoring

Areas to watch for future updates:
- NVIDIA open-source driver maturity (hardware.nvidia.open)
- Niri compositor development and new features
- XDG portal specification changes
- PipeWire configuration evolution
- NixOS module system changes

---

**Research Completed**: October 20, 2025  
**Researcher**: Augment Agent  
**Sources**: NixOS official documentation, GitHub repositories, community forums, NixOS options database

