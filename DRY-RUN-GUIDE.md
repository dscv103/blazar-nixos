# Dry-Run Testing Guide

This repository includes comprehensive dry-run capabilities to safely test the installation and disk partitioning without making any actual changes to your system.

## 📋 Table of Contents

- [Installation Script Dry-Run](#installation-script-dry-run)
- [Disko Configuration Dry-Run](#disko-configuration-dry-run)
- [What Gets Tested](#what-gets-tested)
- [Safety Features](#safety-features)

---

## 🚀 Installation Script Dry-Run

### Usage

```bash
# Run the full installation in dry-run mode
bash install.sh --dry-run

# Show help
bash install.sh --help
```

### What It Does

The `install.sh --dry-run` simulates the entire NixOS installation process:

✅ **Prerequisites Checks** (simulated)
- Root user check
- NixOS environment check
- Internet connectivity check
- Git availability check

✅ **User Interactions** (auto-confirmed)
- Disk selection (uses simulated disk: nvme0n1)
- Hostname configuration (uses default: blazar)
- All confirmation prompts

✅ **Disk Operations** (simulated)
- Disk partitioning with disko
- LUKS encryption setup
- Filesystem creation

✅ **Installation Steps** (simulated)
- Configuration cloning from GitHub
- NixOS installation with flake
- User password setup
- Reboot prompt

### Example Output

```
================================================================================
                NixOS Installation Script (DRY-RUN MODE)
================================================================================

[WARNING] DRY-RUN MODE: No actual changes will be made to your system

[INFO] Checking prerequisites...
[DRY-RUN] Skipping root check (dry-run mode)
[DRY-RUN] Skipping NixOS check (dry-run mode)
...
[INFO] Dry-run complete! No changes were made to your system.
```

---

## 💾 Disko Configuration Dry-Run

### Usage

```bash
# Test with default settings (blazar host, nvme0n1 disk)
./disko-dry-run.sh

# Test with specific hostname and disk
./disko-dry-run.sh blazar sda
./disko-dry-run.sh blazar nvme0n1
```

### What It Does

The `disko-dry-run.sh` script validates and visualizes your disk partitioning configuration:

✅ **Configuration Validation**
- Checks if disko.nix exists
- Validates Nix syntax
- Evaluates disko configuration

✅ **Configuration Analysis**
- Extracts partition layout
- Shows partition sizes
- Lists filesystems
- Identifies encryption settings

✅ **Visual Preview**
- ASCII diagram of partition layout
- Detailed partition specifications
- Security and optimization features

✅ **Command Preview**
- Shows exact commands that would be executed
- Includes sgdisk, cryptsetup, mkfs commands
- Displays mount operations

✅ **Compatibility Check**
- Handles both NVMe (nvme0n1p1) and SATA (sda1) naming
- Validates bcachefs options
- Checks LUKS2 settings

### Example Output

```
================================================================================
                    Disko Configuration Dry-Run
================================================================================

Hostname: blazar
Target disk: /dev/nvme0n1
Config file: hosts/blazar/disko.nix

========================================
4. Partition Layout Preview
========================================

┌─────────────────────────────────────────────────────────────┐
│                    /dev/nvme0n1                              │
├─────────────────────────────────────────────────────────────┤
│ Partition 1: EFI System Partition (ESP)                    │
│   - Size: 2GB                                               │
│   - Type: EF00 (EFI)                                        │
│   - Format: vfat                                            │
│   - Mount: /boot                                            │
│   - Encrypted: No                                           │
├─────────────────────────────────────────────────────────────┤
│ Partition 2: Swap                                           │
│   - Size: 16GB                                              │
│   - Type: Linux swap                                        │
│   - Format: swap                                            │
│   - Encrypted: Yes (LUKS2 - cryptswap)                      │
│   - Hibernation: Enabled                                    │
├─────────────────────────────────────────────────────────────┤
│ Partition 3: Root                                           │
│   - Size: Remaining space (100%)                            │
│   - Type: Linux filesystem                                  │
│   - Format: bcachefs                                        │
│   - Mount: /                                                │
│   - Encrypted: Yes (LUKS2 - cryptroot)                      │
│   - Compression: LZ4                                        │
│   - Checksum: xxhash                                        │
│   - TRIM: Enabled                                           │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔍 What Gets Tested

### Installation Script (`install.sh --dry-run`)

| Component | Tested | Executed |
|-----------|--------|----------|
| Syntax validation | ✅ | ❌ |
| Prerequisites checks | ✅ | ❌ |
| Disk selection | ✅ | ❌ |
| Hostname configuration | ✅ | ❌ |
| Disko partitioning | ✅ | ❌ |
| Git clone operations | ✅ | ❌ |
| NixOS installation | ✅ | ❌ |
| Password setup | ✅ | ❌ |
| Reboot | ✅ | ❌ |

### Disko Script (`disko-dry-run.sh`)

| Component | Tested | Executed |
|-----------|--------|----------|
| Configuration file exists | ✅ | ✅ |
| Nix syntax validation | ✅ | ✅ |
| Configuration parsing | ✅ | ✅ |
| Partition layout | ✅ | ❌ |
| Encryption settings | ✅ | ❌ |
| Filesystem options | ✅ | ❌ |
| Mount operations | ✅ | ❌ |
| Disko evaluation | ✅ | ✅ |

---

## 🛡️ Safety Features

### No Destructive Operations

Both dry-run scripts are designed to be **100% safe**:

- ❌ No disk writes
- ❌ No partition modifications
- ❌ No file system creation
- ❌ No package installation
- ❌ No system configuration changes

### Can Be Run Anywhere

- ✅ Run on your development machine
- ✅ Run on macOS, Linux, or WSL
- ✅ No root privileges required (for dry-run)
- ✅ No NixOS environment required (for dry-run)

### Clear Visual Indicators

All dry-run operations are clearly marked:

- `[DRY-RUN]` prefix in magenta color
- "DRY-RUN MODE" in script headers
- "Would execute:" for simulated commands
- Final confirmation message

---

## 📝 Use Cases

### Before Installation

1. **Validate Configuration**
   ```bash
   ./disko-dry-run.sh blazar nvme0n1
   ```
   Ensure your disko configuration is valid before booting the live ISO.

2. **Preview Partition Layout**
   ```bash
   ./disko-dry-run.sh blazar sda
   ```
   See exactly what will be created on your disk.

3. **Test Installation Flow**
   ```bash
   bash install.sh --dry-run
   ```
   Walk through the entire installation process safely.

### During Development

1. **Test Configuration Changes**
   - Modify `hosts/blazar/disko.nix`
   - Run `./disko-dry-run.sh` to validate
   - Iterate until satisfied

2. **Verify Different Disk Types**
   ```bash
   ./disko-dry-run.sh blazar nvme0n1  # NVMe
   ./disko-dry-run.sh blazar sda      # SATA
   ./disko-dry-run.sh blazar nvme1n1  # Second NVMe
   ```

3. **Documentation**
   - Generate partition layout diagrams
   - Document exact commands that will run
   - Share with team members

---

## 🎯 Next Steps

After successful dry-run testing:

1. **Boot NixOS Live ISO**
   - Download NixOS unstable ISO (for bcachefs support)
   - Boot on target hardware

2. **Run Actual Installation**
   ```bash
   # Without dry-run flag
   sudo bash install.sh
   ```

3. **Or Manual Disko**
   ```bash
   sudo nix --experimental-features "nix-command flakes" run \
     github:nix-community/disko -- --mode disko hosts/blazar/disko.nix
   ```

---

## 🐛 Troubleshooting

### Syntax Errors

If you see syntax errors during dry-run:
```bash
bash -n install.sh          # Check install script
nix-instantiate --parse hosts/blazar/disko.nix  # Check disko config
```

### Configuration Not Found

```bash
ls -la hosts/               # List available hosts
./disko-dry-run.sh <hostname> <disk>
```

### Nix Not Available

The dry-run scripts work even without Nix installed, but some validation steps will be skipped:
- Syntax validation: Skipped
- Disko evaluation: Skipped
- Configuration parsing: Still works (uses grep/sed)

---

## 📚 Additional Resources

- [Disko Documentation](https://github.com/nix-community/disko)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [bcachefs Documentation](https://bcachefs.org/)
- [LUKS Encryption Guide](https://wiki.archlinux.org/title/Dm-crypt)

---

**Remember:** Always test with `--dry-run` before running destructive operations! 🚀

