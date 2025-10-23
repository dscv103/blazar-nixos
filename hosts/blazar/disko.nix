# Disko configuration for blazar
# NVMe SSD with bcachefs, full LUKS encryption, optimized for performance and longevity
#
# Layout:
# - EFI partition: 2GB (vfat, unencrypted)
# - Swap partition: 16GB (encrypted with LUKS)
# - Root partition: Remaining space (bcachefs with LUKS encryption)
#
# Features:
# - Full disk encryption with LUKS2
# - bcachefs filesystem with compression and SSD optimizations
# - Periodic TRIM (fstrim.timer) instead of continuous discard for better SSD longevity
# - Optimized mount options for NVMe SSDs
# - Single password prompt for both swap and root

_:
{
  disko.devices = {
    disk = {
      nvme0n1 = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            # ================================================================
            # EFI System Partition (ESP) - 2GB
            # ================================================================
            # Unencrypted boot partition for UEFI firmware
            ESP = {
              priority = 1;
              size = "2G";
              type = "EF00"; # EFI System Partition
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                  "umask=0077" # Secure permissions
                  "dmask=0077"
                  "fmask=0177"
                  "noatime" # Don't update access times (reduces writes)
                ];
              };
            };

            # ================================================================
            # Encrypted Swap Partition - 16GB
            # ================================================================
            # LUKS-encrypted swap for hibernation support and security
            swap = {
              priority = 2;
              size = "16G";
              content = {
                type = "luks";
                name = "cryptswap";
                settings = {
                  # LUKS2 with Argon2id (more secure than LUKS1)
                  # keyFile will be prompted during boot
                  allowDiscards = true; # Enable TRIM for SSD
                  bypassWorkqueues = true; # Better performance on modern CPUs
                };
                # Swap content
                content = {
                  type = "swap";
                  randomEncryption = false; # Use persistent encryption for hibernation
                  resumeDevice = true; # Enable hibernation support
                };
              };
            };

            # ================================================================
            # Encrypted Root Partition - Remaining space
            # ================================================================
            # LUKS-encrypted bcachefs root filesystem
            root = {
              priority = 3;
              size = "100%";
              content = {
                type = "luks";
                name = "cryptroot";
                settings = {
                  # LUKS2 with Argon2id for better security
                  allowDiscards = true; # Enable TRIM for SSD longevity
                  bypassWorkqueues = true; # Better performance on modern CPUs

                  # Optional: Use a key file for automatic unlocking
                  # Uncomment and create /tmp/secret.key if you want to use a key file
                  # keyFile = "/tmp/secret.key";
                };

                # Additional key files for recovery
                # additionalKeyFiles = [ "/tmp/recovery.key" ];

                # bcachefs filesystem
                content = {
                  type = "filesystem";
                  format = "bcachefs";

                  # bcachefs format options optimized for NVMe SSD
                  extraArgs = [
                    # Compression - LZ4 is fast and provides good compression
                    "--compression=lz4"
                    "--background_compression=lz4"

                    # Checksumming for data integrity
                    "--data_checksum=xxhash"
                    "--metadata_checksum=xxhash"

                    # SSD optimizations
                    "--discard" # Enable TRIM support

                    # Performance optimizations
                    "--foreground_target=ssd"
                    "--background_target=ssd"
                    "--promote_target=ssd"

                    # Metadata options for better performance
                    "--metadata_replicas=1" # Single device, no need for replication
                    "--data_replicas=1"

                    # Filesystem label
                    "--fs_label=nixos"
                  ];

                  mountpoint = "/";

                  # Mount options optimized for NVMe SSD and bcachefs
                  mountOptions = [
                    "defaults"
                    "noatime" # Don't update access times (reduces writes)
                    "nodiratime" # Don't update directory access times

                    # Note: We use periodic TRIM (fstrim.timer) instead of continuous
                    # discard mount option for better SSD longevity and performance.
                    # The fstrim.timer is enabled by default in NixOS.

                    # bcachefs-specific options
                    "verbose" # Verbose logging for debugging
                    "fsck" # Run fsck on mount
                  ];
                };
              };
            };
          };
        };
      };
    };
  };

  # ====================================================================
  # Additional NixOS Configuration for SSD Optimization
  # ====================================================================
  # These settings should be added to your configuration.nix

  # Enable periodic TRIM (weekly by default)
  # This is better for SSD longevity than continuous discard
  services.fstrim = {
    enable = true;
    interval = "weekly"; # Run TRIM weekly
  };

  # Boot configuration: kernel, initrd, and filesystem support
  boot = {
    # Kernel sysctl settings for SSD performance and longevity
    kernel.sysctl = {
      # Reduce swappiness (prefer RAM over swap)
      "vm.swappiness" = 10;

      # Increase the percentage of system memory that can be filled with dirty pages
      # before forcing them to be written to disk
      "vm.dirty_ratio" = 10;
      "vm.dirty_background_ratio" = 5;

      # Reduce the time before dirty pages are written to disk
      # This helps prevent large write bursts that can impact SSD lifespan
      "vm.dirty_expire_centisecs" = 3000; # 30 seconds
      "vm.dirty_writeback_centisecs" = 1500; # 15 seconds
    };

    # Enable LUKS in initrd for early boot decryption
    initrd.luks.devices = {
      cryptroot = {
        device = "/dev/disk/by-partlabel/disk-nvme0n1-root";
        preLVM = true;
        allowDiscards = true; # Enable TRIM for encrypted partition
        bypassWorkqueues = true;
      };

      cryptswap = {
        device = "/dev/disk/by-partlabel/disk-nvme0n1-swap";
        preLVM = true;
        allowDiscards = true;
        bypassWorkqueues = true;
      };
    };

    # Enable bcachefs support in kernel
    supportedFilesystems = [ "bcachefs" ];

    # NVMe-specific kernel parameters
    kernelParams = [
      # Enable NVMe power management
      "nvme_core.default_ps_max_latency_us=0"

      # Disable write cache if you have a UPS or want maximum data safety
      # Comment out if you want better performance
      # "libata.force=noncq"
    ];
  };

  # Optimize I/O scheduler for NVMe (none/noop is best for NVMe)
  services.udev.extraRules = ''
    # Set I/O scheduler to none for NVMe devices (best for NVMe SSDs)
    ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/scheduler}="none"
    
    # Set I/O scheduler to mq-deadline for SATA SSDs
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
  '';

  # Enable zram for better memory management (optional but recommended)
  # This reduces swap usage and extends SSD life
  zramSwap = {
    enable = true;
    algorithm = "zstd"; # Fast compression
    memoryPercent = 50; # Use 50% of RAM for zram
  };
}

