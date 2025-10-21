# Phase 4: Testing & Validation Plan

**Goal:** Comprehensive testing and validation of all Phase 1-3 optimizations

**Status:** 🔄 IN PROGRESS

---

## Overview

This phase validates that all optimizations work correctly and the system is stable.

### Testing Categories

1. **Build & Evaluation Tests** - Verify configuration builds correctly
2. **Code Quality Tests** - Ensure code meets quality standards
3. **System Tests** - Validate system functionality
4. **Performance Tests** - Measure improvements
5. **Integration Tests** - Verify all components work together

---

## 1. Build & Evaluation Tests

### 1.1 Dry Build Test
**Purpose:** Verify configuration evaluates and builds without errors

```bash
sudo nixos-rebuild dry-build --flake .#blazar
```

**Expected Result:**
- ✅ No evaluation errors
- ✅ All derivations resolve
- ✅ No missing dependencies

**Status:** [x] Complete

**Result:** ✅ PASSED
- 294 derivations to build
- 608 paths from cache
- No errors

---

### 1.2 Flake Check
**Purpose:** Validate flake structure and outputs

```bash
nix flake check
```

**Expected Result:**
- ✅ All outputs are valid
- ✅ No schema errors
- ✅ All checks pass

**Status:** [x] Complete

**Result:** ✅ PASSED
- All flake outputs valid
- NixOS configuration checked
- Dev shells checked

---

## 2. Code Quality Tests

### 2.1 Statix Linter
**Purpose:** Check for Nix code quality issues

```bash
statix check .
```

**Expected Result:**
- ✅ Zero warnings
- ✅ Zero errors

**Status:** [x] Complete

**Result:** ✅ PASSED
- Zero warnings
- Zero errors
- Perfect code quality

---

### 2.2 Deadnix Check
**Purpose:** Find unused Nix code

```bash
deadnix -f .
```

**Expected Result:**
- ✅ No unused code (or minimal, documented exceptions)

**Status:** [x] Complete

**Result:** ✅ PASSED
- No unused code found
- Clean codebase

---

### 2.3 Nix Format Check
**Purpose:** Verify code formatting

```bash
nix fmt .
```

**Expected Result:**
- ✅ All files already formatted
- ✅ "0 / N have been reformatted"

**Status:** [x] Complete

**Result:** ✅ PASSED
- 0 / 47 files reformatted
- All files properly formatted

---

## 3. System Tests (Requires Deployment)

### 3.1 Deploy Configuration
**Purpose:** Apply all Phase 1-3 changes to the system

```bash
sudo nixos-rebuild switch --flake .#blazar
```

**Expected Result:**
- ✅ Build succeeds
- ✅ Activation succeeds
- ✅ No service failures

**Status:** [ ] Not Started | [ ] In Progress | [ ] Complete

---

### 3.2 Boot Test
**Purpose:** Verify system boots correctly with new configuration

**Steps:**
1. Reboot the system: `sudo reboot`
2. Verify boot timeout is 2 seconds (watch bootloader)
3. System boots to login screen

**Expected Result:**
- ✅ Bootloader timeout is 2 seconds (Phase 3.2)
- ✅ System boots successfully
- ✅ Login screen appears (SDDM with Niri session)

**Status:** [ ] Not Started | [ ] In Progress | [ ] Complete

---

### 3.3 Boot Performance
**Purpose:** Measure boot time improvements

```bash
systemd-analyze
systemd-analyze blame | head -20
```

**Expected Result:**
- ✅ Boot time is reasonable (< 30 seconds to userspace)
- ✅ No services taking excessive time
- ✅ Bootloader timeout reduced to 2 seconds

**Status:** [ ] Not Started | [ ] In Progress | [ ] Complete

---

### 3.4 Service Status Check
**Purpose:** Verify all critical services are running

```bash
# Display manager
systemctl status display-manager

# Docker (should NOT be running - Phase 1, Task 2.2)
systemctl status docker

# Niri compositor (user service)
systemctl --user status niri-flake

# Other critical services
systemctl status NetworkManager
systemctl status pipewire
```

**Expected Result:**
- ✅ display-manager is active (SDDM)
- ✅ docker is inactive (enableOnBoot = false)
- ✅ niri-flake is active (after login)
- ✅ NetworkManager is active
- ✅ pipewire is active

**Status:** [ ] Not Started | [ ] In Progress | [ ] Complete

---

### 3.5 Hardware Acceleration Test
**Purpose:** Verify NVIDIA GPU and hardware acceleration work

```bash
# Check NVIDIA driver
nvidia-smi

# Check VA-API
vainfo

# Check Vulkan
vulkaninfo | grep -i "device name"

# Verify kernel parameters
cat /proc/cmdline | grep nvidia-drm.modeset
```

**Expected Result:**
- ✅ nvidia-smi shows GPU information
- ✅ VA-API shows NVIDIA driver
- ✅ Vulkan detects NVIDIA GPU
- ✅ nvidia-drm.modeset=1 is present

**Status:** [ ] Not Started | [ ] In Progress | [ ] Complete

---

### 3.6 Desktop Environment Test
**Purpose:** Verify Niri compositor and desktop integration

**Steps:**
1. Log in to Niri session
2. Open terminal (Ghostty)
3. Test XWayland apps (if any)
4. Test Wayland-native apps

**Expected Result:**
- ✅ Niri starts successfully
- ✅ Ghostty terminal works
- ✅ XWayland apps work (if applicable)
- ✅ Wayland apps work
- ✅ No X server running (Phase 1, Task 2.1)

**Status:** [ ] Not Started | [ ] In Progress | [ ] Complete

---

### 3.7 User Environment Test
**Purpose:** Verify home-manager configuration

```bash
# Check home-manager generation
home-manager generations

# Verify user packages are available
which ghostty
which zed
which firefox

# Check user services
systemctl --user status
```

**Expected Result:**
- ✅ Latest home-manager generation is active
- ✅ All user packages are available
- ✅ User services are running

**Status:** [ ] Not Started | [ ] In Progress | [ ] Complete

---

### 3.8 Development Tools Test
**Purpose:** Verify development environment

```bash
# Enter dev shell
nix develop

# Check tools are available
which cargo
which python3
which node

# Docker manual start (Phase 1, Task 2.2)
sudo systemctl start docker
docker ps
sudo systemctl stop docker
```

**Expected Result:**
- ✅ Dev shell activates successfully
- ✅ All development tools available
- ✅ Docker starts manually (not on boot)
- ✅ Docker stops cleanly

**Status:** [ ] Not Started | [ ] In Progress | [ ] Complete

---

## 4. Performance Tests

### 4.1 Build Time Measurement
**Purpose:** Measure configuration build time

```bash
time sudo nixos-rebuild dry-build --flake .#blazar
```

**Expected Result:**
- ✅ Build completes in reasonable time
- ✅ Cache hits from nix-community (Phase 3.1)

**Status:** [ ] Not Started | [ ] In Progress | [ ] Complete

**Baseline:** (to be measured)
**Current:** (to be measured)
**Improvement:** (to be calculated)

---

### 4.2 System Resource Usage
**Purpose:** Measure system resource consumption

```bash
# Memory usage
free -h

# Disk usage
df -h

# Closure size
nix path-info -Sh /run/current-system
```

**Expected Result:**
- ✅ Memory usage is reasonable
- ✅ Disk usage is acceptable
- ✅ Closure size is documented

**Status:** [ ] Not Started | [ ] In Progress | [ ] Complete

---

## 5. Integration Tests

### 5.1 Profile System Test
**Purpose:** Verify profile loading works correctly

**Steps:**
1. Check current profiles in `hosts/blazar/profiles.nix`
2. Verify all enabled profiles load
3. Check for any conflicts

**Expected Result:**
- ✅ All profiles load without errors
- ✅ No duplicate configurations
- ✅ Assertions pass (Phase 3.4)

**Status:** [ ] Not Started | [ ] In Progress | [ ] Complete

---

### 5.2 Font Configuration Test
**Purpose:** Verify centralized font configuration (Phase 1, Task 1.1)

```bash
# Check available fonts
fc-list | grep -i "maple\|nerd"

# Verify Ghostty uses correct font
# (Check Ghostty terminal - should use Maple Mono)
```

**Expected Result:**
- ✅ Maple Mono Nerd Font is available
- ✅ Ghostty uses Maple Mono
- ✅ No duplicate font packages

**Status:** [ ] Not Started | [ ] In Progress | [ ] Complete

---

## Test Summary

### Completion Status

- [x] Build & Evaluation Tests (2/2) ✅
- [x] Code Quality Tests (3/3) ✅
- [ ] System Tests (0/8)
- [ ] Performance Tests (0/2)
- [ ] Integration Tests (0/2)

**Total:** 5/17 tests complete (29%)

---

## Notes

- Tests 3.1-3.8 require deploying the configuration with `nixos-rebuild switch`
- Tests 1.1-2.3 can be run without deployment
- Performance baselines should be recorded before Phase 4 deployment
- All test results should be documented in this file

---

## Next Steps

1. Run pre-deployment tests (1.1-2.3)
2. Deploy configuration (3.1)
3. Reboot and run system tests (3.2-3.8)
4. Run performance tests (4.1-4.2)
5. Run integration tests (5.1-5.2)
6. Document all results
7. Create Phase 4 summary document

