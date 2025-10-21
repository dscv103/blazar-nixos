# Disko Setup Guide for Blazar

This guide explains how to use the disko configuration to set up your NVMe SSD with bcachefs, LUKS encryption, and optimized settings for performance and longevity.

## Overview

The disko configuration (`hosts/blazar/disko.nix`) provides:

- **EFI Partition**: 2GB (vfat, unencrypted) for UEFI boot
- **Encrypted Swap**: 16GB (LUKS2-encrypted) with hibernation support
- **Encrypted Root**: Remaining space (LUKS2 + bcachefs) with compression and SSD optimizations
- **Full Disk Encryption**: LUKS2 with Argon2id key derivation
- **SSD Optimizations**: Periodic TRIM, optimized mount options, and bcachefs SSD settings

## Disk Layout

```
/dev/nvme0n1
├── /dev/nvme0n1p1  (2GB)    → /boot (vfat, unencrypted)
├── /dev/nvme0n1p2  (16GB)   → swap (LUKS2 encrypted)
└── /dev/nvme0n1p3  (rest)   → / (LUKS2 + bcachefs)
```

## Prerequisites

1. **Boot from NixOS installer** (or use nixos-anywhere for remote installation)
2. **Backup your data** - This will DESTROY all data on /dev/nvme0n1
3. **Verify your disk name** - Make sure it's `/dev/nvme0n1` (check with `lsblk`)

## Installation Methods

### Method 1: Using disko-install (Recommended)

The `disko-install` tool combines disko partitioning with nixos-install in one step:

```bash
# 1. Boot from NixOS installer

# 2. Clone your configuration (or use nixos-anywhere)
git clone https://github.com/dscv103/blazar-nixos.git /tmp/config
cd /tmp/config

# 3. Run disko-install
sudo nix run 'github:nix-community/disko/latest#disko-install' -- \
  --flake '.#blazar' \
  --disk nvme0n1 /dev/nvme0n1

# 4. You'll be prompted for LUKS password twice (swap and root)

# 5. Reboot
reboot
```

### Method 2: Manual disko + nixos-install

If you prefer more control, you can run disko and nixos-install separately:

```bash
# 1. Boot from NixOS installer

# 2. Clone your configuration
git clone https://github.com/dscv103/blazar-nixos.git /tmp/config
cd /tmp/config

# 3. Run disko to partition, format, and mount
sudo nix run 'github:nix-community/disko/latest' -- \
  --mode destroy,format,mount \
  ./hosts/blazar/disko.nix

# 4. You'll be prompted for LUKS password twice (swap and root)
#    Use the SAME password for both to enable single password prompt on boot

# 5. Install NixOS
sudo nixos-install --flake '.#blazar'

# 6. Set root password when prompted

# 7. Reboot
reboot
```

### Method 3: Using nixos-anywhere (Remote Installation)

For remote installation over SSH:

```bash
# From your local machine:
nix run github:numtide/nixos-anywhere -- \
  --flake '.#blazar' \
  --disk-encryption-keys /tmp/secret.key <(echo -n "your-password-here") \
  root@target-ip
```

## LUKS Password Setup

### Single Password Prompt (Recommended)

To enable a single password prompt for both swap and root:

1. **Use the SAME password** when prompted during installation
2. The initrd will unlock both partitions with one password

### Using a Key File (Optional)

If you want to use a key file instead of typing a password:

1. Create a key file:
   ```bash
   echo -n "your-strong-password" > /tmp/secret.key
   chmod 600 /tmp/secret.key
   ```

2. Uncomment the `keyFile` lines in `hosts/blazar/disko.nix`:
   ```nix
   settings = {
     keyFile = "/tmp/secret.key";  # Uncomment this
     allowDiscards = true;
     bypassWorkqueues = true;
   };
   ```

3. Run disko with the key file present

### Adding Recovery Keys

To add additional recovery keys after installation:

```bash
# Add a recovery key to root partition
sudo cryptsetup luksAddKey /dev/nvme0n1p3

# Add a recovery key to swap partition
sudo cryptsetup luksAddKey /dev/nvme0n1p2
```

## Bcachefs Features

The configuration enables these bcachefs features:

### Compression
- **LZ4 compression** for both foreground and background operations
- Fast compression with good space savings
- Transparent to applications

### Checksumming
- **xxhash checksums** for data and metadata
- Detects and prevents data corruption
- Minimal performance impact

### SSD Optimizations
- **TRIM support** enabled at format time
- **Periodic TRIM** via fstrim.timer (weekly)
- **SSD-optimized targets** for foreground, background, and promote operations
- **512MB journal** for better performance

### Mount Options
- `noatime` - Don't update access times (reduces writes)
- `nodiratime` - Don't update directory access times
- `verbose` - Verbose logging for debugging
- `fsck` - Run filesystem check on mount

## SSD Longevity Optimizations

The configuration includes several optimizations for NVMe SSD longevity:

### 1. Periodic TRIM (fstrim.timer)
- Runs weekly by default
- Better for SSD lifespan than continuous discard
- Enabled automatically in NixOS

### 2. Reduced Swappiness
- `vm.swappiness = 10` - Prefer RAM over swap
- Reduces SSD wear from swap usage

### 3. Write Optimization
- `vm.dirty_ratio = 10` - Limit dirty pages in memory
- `vm.dirty_background_ratio = 5` - Start background writes earlier
- `vm.dirty_expire_centisecs = 3000` - Write dirty pages after 30 seconds
- `vm.dirty_writeback_centisecs = 1500` - Check for dirty pages every 15 seconds

### 4. I/O Scheduler
- **none** scheduler for NVMe (best for NVMe SSDs)
- Automatically set via udev rules

### 5. zram Swap
- Compressed swap in RAM
- Reduces physical swap usage
- 50% of RAM allocated to zram
- Uses zstd compression

## Verifying the Setup

After installation and reboot, verify your setup:

```bash
# Check disk layout
lsblk

# Check LUKS devices
sudo cryptsetup status cryptroot
sudo cryptsetup status cryptswap

# Check bcachefs filesystem
bcachefs show-super /dev/mapper/cryptroot

# Check mount options
mount | grep bcachefs

# Check TRIM support
sudo fstrim -v /

# Check zram
zramctl

# Check I/O scheduler
cat /sys/block/nvme0n1/queue/scheduler
```

## Troubleshooting

### Wrong Disk Name

If your NVMe drive is not `/dev/nvme0n1`, edit `hosts/blazar/disko.nix`:

```nix
disk = {
  nvme0n1 = {
    type = "disk";
    device = "/dev/nvme0n2";  # Change this to your disk
```

### LUKS Password Prompt Issues

If you're prompted for the password twice on boot:

1. Make sure you used the SAME password for both swap and root during installation
2. Check that both LUKS devices are configured in `boot.initrd.luks.devices`

### Bcachefs Not Mounting

If bcachefs fails to mount:

1. Check kernel support: `zgrep BCACHEFS /proc/config.gz`
2. Check dmesg for errors: `dmesg | grep bcachefs`
3. Try manual mount: `sudo mount -t bcachefs /dev/mapper/cryptroot /mnt`

### Performance Issues

If you experience performance issues:

1. Check I/O scheduler: `cat /sys/block/nvme0n1/queue/scheduler`
2. Monitor with: `iostat -x 1`
3. Check bcachefs stats: `bcachefs fs usage /`

## Customization

### Change Partition Sizes

Edit `hosts/blazar/disko.nix`:

```nix
ESP = {
  size = "4G";  # Increase EFI partition to 4GB
  ...
};

swap = {
  size = "32G";  # Increase swap to 32GB
  ...
};
```

### Disable Compression

Edit `hosts/blazar/disko.nix`:

```nix
extraArgs = [
  # "--compression=lz4"  # Comment out compression
  # "--background_compression=lz4"
  ...
];
```

### Change TRIM Schedule

Edit `hosts/blazar/disko.nix`:

```nix
services.fstrim = {
  enable = true;
  interval = "daily";  # Change to daily
};
```

## Security Considerations

1. **LUKS Password**: Use a strong password (20+ characters recommended)
2. **Recovery Keys**: Store recovery keys in a secure location (not on the encrypted drive)
3. **Backup**: Regularly backup your LUKS headers: `sudo cryptsetup luksHeaderBackup /dev/nvme0n1p3 --header-backup-file /path/to/backup`
4. **Secure Boot**: Consider enabling Secure Boot for additional security

## Performance Benchmarks

After installation, you can benchmark your setup:

```bash
# Disk performance
sudo hdparm -Tt /dev/nvme0n1

# Filesystem performance
sudo bonnie++ -d /tmp -u root

# bcachefs-specific stats
bcachefs fs usage /
```

## References

- [Disko Documentation](https://github.com/nix-community/disko)
- [Bcachefs Documentation](https://bcachefs.org/)
- [NixOS Manual - Full Disk Encryption](https://nixos.wiki/wiki/Full_Disk_Encryption)
- [Arch Wiki - Solid State Drives](https://wiki.archlinux.org/title/Solid_state_drive)

## Support

If you encounter issues:

1. Check the disko GitHub issues: https://github.com/nix-community/disko/issues
2. Ask in the NixOS Discourse: https://discourse.nixos.org/
3. Join the disko Matrix channel: https://matrix.to/#/#disko:nixos.org

