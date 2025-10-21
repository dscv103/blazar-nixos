# NixOS Configuration Optimization Checklist

Track your progress implementing the audit recommendations.

---

## 🔴 Phase 1: Quick Wins (1-2 hours)

**Goal:** Immediate performance improvements with minimal effort

### Build Time Optimization

- [x] **1.1** Remove duplicate font packages
  - [x] Create `home/dscv/fonts.nix`
  - [x] Remove fonts from `ghostty.nix`
  - [x] Remove fonts from `vscode.nix`
  - [x] Add fonts.nix to flake.nix imports
  - [ ] Test: `sudo nixos-rebuild dry-build --flake .#blazar` (NEEDS USER TO RUN)

- [x] **1.2** Remove SDDM package duplication
  - [x] Remove `environment.systemPackages` section from `nixos/sddm.nix`
  - [ ] Test: `sudo nixos-rebuild dry-build --flake .#blazar` (NEEDS USER TO RUN)

### System Performance

- [x] **2.1** Disable X server, use XWayland
  - [x] Replace `services.xserver.enable = true` with `programs.xwayland.enable = true`
  - [x] Update comments in `nixos/desktop.nix`
  - [ ] Test: `sudo nixos-rebuild dry-build --flake .#blazar` (NEEDS USER TO RUN)
  - [ ] After reboot, verify: `systemctl status display-manager` (NEEDS USER TO RUN)

- [x] **2.2** Make Docker on-demand
  - [x] Change `enableOnBoot = true` to `false` in `profiles/system/development.nix`
  - [x] Add usage comment
  - [ ] Optional: Add shell aliases for docker-start/stop (SKIPPED - user can add if desired)
  - [ ] Test: `sudo nixos-rebuild dry-build --flake .#blazar` (NEEDS USER TO RUN)

### Code Quality

- [x] **5.1** Standardize comment styles
  - [x] Update `nixos/*.nix` files
  - [x] Update `home/dscv/*.nix` files
  - [x] Update `profiles/*.nix` files
  - [x] Use: `# ============================================================================`
  - [x] Test: Visual inspection

- [x] **4.2** Fix hardcoded hostname
  - [x] Add `hostName = "blazar"` to specialArgs in `flake.nix`
  - [x] Update `profiles/default.nix` to use hostName parameter
  - [x] Update `profiles/user-default.nix` to use hostName parameter
  - [x] Update `nixos/sddm.nix` to use hostName parameter
  - [ ] Test: `sudo nixos-rebuild dry-build --flake .#blazar` (NEEDS USER TO RUN)

- [x] **4.1** Add type validation to profiles
  - [x] Add options section to `profiles/default.nix`
  - [x] Define types for all profile options
  - [x] Update config section to use options
  - [ ] Test: `sudo nixos-rebuild dry-build --flake .#blazar` (NEEDS USER TO RUN)

### Phase 1 Completion

- [x] **All Phase 1 tasks completed**
- [ ] **Measure improvements:** (NEEDS USER TO RUN AFTER TESTING)
  - [ ] Build time: `time sudo nixos-rebuild dry-build --flake .#blazar`
  - [ ] Boot time: `systemd-analyze`
  - [ ] Memory: `free -h`
  - [ ] Services: `systemctl list-units --type=service --state=running | wc -l`
- [ ] **Document results in CHANGELOG.md** (NEEDS USER TO RUN)

---

## 🟡 Phase 2: Structural Improvements (3-4 hours)

**Goal:** Better organization and maintainability

### File Organization

- [ ] **3.1** Consolidate font configuration
  - [ ] Already done in Phase 1 ✓

- [ ] **3.2** Separate hardware-specific configs
  - [ ] Create `nixos/hardware/` directory
  - [ ] Move `nvidia.nix` to `nixos/hardware/`
  - [ ] Rename `hardware.nix` to `nixos/hardware/amd-ryzen.nix`
  - [ ] Create `nixos/hardware/default.nix` to import based on host
  - [ ] Update imports in `flake.nix`
  - [ ] Test: `sudo nixos-rebuild dry-build --flake .#blazar`

- [ ] **3.3** Create shared configuration module
  - [ ] Create `shared/` directory
  - [ ] Create `shared/theme.nix` with Dracula constants
  - [ ] Create `shared/fonts.nix` with font definitions
  - [ ] Create `shared/constants.nix` with shared values
  - [ ] Update modules to use shared configs
  - [ ] Test: `sudo nixos-rebuild dry-build --flake .#blazar`

- [ ] **3.4** Reorganize profile structure
  - [ ] Add `default.nix` to `profiles/system/`
  - [ ] Add `default.nix` to `profiles/user/`
  - [ ] Add `default.nix` to `profiles/features/`
  - [ ] Update main `profiles/default.nix` to import subdirectory defaults
  - [ ] Test: `sudo nixos-rebuild dry-build --flake .#blazar`

### Documentation

- [ ] **3.5** Consolidate documentation
  - [ ] Create `docs/` directory
  - [ ] Move and reorganize README files
  - [ ] Create `docs/README.md` as main entry point
  - [ ] Create `docs/getting-started.md`
  - [ ] Create `docs/profiles.md`
  - [ ] Create `docs/customization.md`
  - [ ] Create `docs/troubleshooting.md`
  - [ ] Create `docs/templates/` directory
  - [ ] Update root README.md to point to docs/

- [ ] **5.2** Add module documentation headers
  - [ ] Add comprehensive headers to all `nixos/*.nix` files
  - [ ] Add comprehensive headers to all `home/dscv/*.nix` files
  - [ ] Add comprehensive headers to all `profiles/*.nix` files
  - [ ] Include: Purpose, Dependencies, Used by, Configuration, Example

### Code Quality

- [ ] **5.3** Remove duplicate Nix tools
  - [ ] Remove Nix tools from `nixos/packages.nix`
  - [ ] Keep only in `flake-parts/devshells.nix`
  - [ ] Test: `sudo nixos-rebuild dry-build --flake .#blazar`

- [ ] **2.3** Remove redundant D-Bus enablement
  - [ ] Remove D-Bus enable from `profiles/system/development.nix`
  - [ ] Keep only in `nixos/desktop.nix`
  - [ ] Test: `sudo nixos-rebuild dry-build --flake .#blazar`

### Phase 2 Completion

- [ ] **All Phase 2 tasks completed**
- [ ] **Verify organization:**
  - [ ] Directory structure is logical
  - [ ] Documentation is easy to find
  - [ ] No duplicate code
- [ ] **Document changes in CHANGELOG.md**

---

## 🟢 Phase 3: Advanced Optimizations (4-5 hours)

**Goal:** Maximum performance and robustness

### Build Time Optimization

- [ ] **1.3** Implement conditional profile loading
  - [ ] Update `profiles/default.nix` to use `lib.optionals`
  - [ ] Only import enabled profiles
  - [ ] Test with profiles disabled
  - [ ] Measure evaluation time improvement
  - [ ] Test: `sudo nixos-rebuild dry-build --flake .#blazar`

- [ ] **1.4** Binary cache optimization
  - [ ] Add nix-community cache to `flake.nix`
  - [ ] Add CUDA cache (if using development profile)
  - [ ] Add trusted public keys
  - [ ] Test: `sudo nixos-rebuild dry-build --flake .#blazar`
  - [ ] Measure build time improvement

- [ ] **1.5** Lazy loading of development tools
  - [ ] Create `minimal` dev shell
  - [ ] Create `python` dev shell
  - [ ] Create `node` dev shell
  - [ ] Keep `default` as full-stack
  - [ ] Update DEVSHELL.md documentation
  - [ ] Test: `nix develop .#python`

### System Performance

- [ ] **2.4** Reduce boot timeout
  - [ ] Change timeout from 5 to 2 seconds in `nixos/boot.nix`
  - [ ] Test: Reboot and verify
  - [ ] Measure boot time improvement

- [ ] **2.5** Remove multimedia HW duplication
  - [ ] Remove `hardware.graphics` from `profiles/system/multimedia.nix`
  - [ ] Verify it's already in `nixos/nvidia.nix`
  - [ ] Test: `sudo nixos-rebuild dry-build --flake .#blazar`

- [ ] **2.6** Optimize garbage collection schedule
  - [ ] Consider changing from weekly to monthly
  - [ ] Increase retention from 30d to 60d
  - [ ] Test: `sudo nixos-rebuild dry-build --flake .#blazar`

### Configuration Robustness

- [ ] **4.3** Add critical assertions
  - [ ] Add assertions to `nixos/nvidia.nix`
  - [ ] Add assertions to `nixos/desktop.nix`
  - [ ] Add assertions to `profiles/default.nix`
  - [ ] Test: `sudo nixos-rebuild dry-build --flake .#blazar`
  - [ ] Test with invalid config to verify assertions work

- [ ] **4.4** Improve password security
  - [ ] Use hashedPassword instead of initialPassword
  - [ ] Add security warning comment
  - [ ] Document password change procedure
  - [ ] Test: `sudo nixos-rebuild dry-build --flake .#blazar`

- [ ] **4.5** Add LUKS fail-safe
  - [ ] Document recovery key procedure in `hosts/blazar/disko.nix`
  - [ ] Add commented key file configuration
  - [ ] Create recovery documentation
  - [ ] Test: Review only (don't test LUKS changes on live system)

- [ ] **4.6** Validate monitor configuration
  - [ ] Add home.activation check for Niri monitor config
  - [ ] Add helpful warning message
  - [ ] Test: `sudo nixos-rebuild dry-build --flake .#blazar`

### Maintainability

- [ ] **5.4** Extract magic numbers to constants
  - [ ] Create `shared/constants.nix`
  - [ ] Define swap size, boot partition size, etc.
  - [ ] Update all modules to use constants
  - [ ] Test: `sudo nixos-rebuild dry-build --flake .#blazar`

- [ ] **5.5** Create profile toggle script
  - [ ] Create `scripts/toggle-profile.sh`
  - [ ] Make executable
  - [ ] Test toggling profiles
  - [ ] Document in README

- [ ] **5.6** Add changelog
  - [ ] Create CHANGELOG.md
  - [ ] Document all changes from audit
  - [ ] Set up template for future changes

### Code Quality

- [ ] **6.1** Consistent function parameters
  - [ ] Review all modules
  - [ ] Use `_:` only when no parameters needed
  - [ ] Be explicit about used parameters
  - [ ] Test: `sudo nixos-rebuild dry-build --flake .#blazar`

- [ ] **6.2** Break long lines
  - [ ] Review all files for lines >100 characters
  - [ ] Break into multiple lines
  - [ ] Improve readability
  - [ ] Test: Visual inspection

- [ ] **6.3** Improve variable naming
  - [ ] Review all `let` bindings
  - [ ] Use descriptive names
  - [ ] Add comments where needed
  - [ ] Test: Visual inspection

- [ ] **6.4** Consistent list formatting
  - [ ] Use inline for 1-2 items
  - [ ] Use multi-line for 3+ items
  - [ ] Apply consistently across all files
  - [ ] Test: Visual inspection

- [ ] **6.5** Document complex expressions
  - [ ] Add explanatory comments to complex logic
  - [ ] Document SDDM theme override
  - [ ] Document profile loading logic
  - [ ] Test: Visual inspection

### Phase 3 Completion

- [ ] **All Phase 3 tasks completed**
- [ ] **Final measurements:**
  - [ ] Build time: `time sudo nixos-rebuild dry-build --flake .#blazar`
  - [ ] Boot time: `systemd-analyze`
  - [ ] Memory: `free -h`
  - [ ] Closure size: `nix path-info -Sh /run/current-system`
- [ ] **Compare with baseline measurements**
- [ ] **Document all improvements in CHANGELOG.md**

---

## Final Verification

- [ ] **All phases completed**
- [ ] **System is stable and working**
- [ ] **All tests pass:**
  - [ ] `nix flake check`
  - [ ] `sudo nixos-rebuild dry-build --flake .#blazar`
  - [ ] `statix check .`
  - [ ] `deadnix -f .`
- [ ] **Documentation is up to date:**
  - [ ] CHANGELOG.md reflects all changes
  - [ ] README.md is current
  - [ ] All guides are accurate
- [ ] **Measurements documented:**
  - [ ] Before/after build times
  - [ ] Before/after boot times
  - [ ] Before/after memory usage
  - [ ] Before/after closure sizes

---

## Success Metrics

### Target Improvements

- [ ] **Build time:** 30-40% faster evaluation
- [ ] **Boot time:** 8-15 seconds faster
- [ ] **Memory usage:** 300-500MB reduction
- [ ] **Code quality:** Consistent style throughout
- [ ] **Maintainability:** Easy to understand and modify
- [ ] **Robustness:** Type-safe with good error handling

### Actual Results

Record your actual improvements here:

```
Build Time:
  Before: _____ seconds
  After:  _____ seconds
  Improvement: _____%

Boot Time:
  Before: _____ seconds
  After:  _____ seconds
  Improvement: _____ seconds

Memory Usage:
  Before: _____ MB
  After:  _____ MB
  Improvement: _____ MB

Closure Size:
  Before: _____ MB
  After:  _____ MB
  Improvement: _____ MB
```

---

## Notes

Use this section to track issues, questions, or observations during implementation:

```
Date: ___________
Issue: 
Solution:

Date: ___________
Issue:
Solution:
```

---

**Good luck with the optimization! 🚀**

