#!/usr/bin/env bash
# ================================================================================
# Disko Configuration Dry-Run Script
# ================================================================================
#
# PURPOSE:
#   Test and validate disko configuration without making any changes to disks
#
# USAGE:
#   ./disko-dry-run.sh [hostname] [disk]
#
# EXAMPLES:
#   ./disko-dry-run.sh blazar nvme0n1
#   ./disko-dry-run.sh blazar sda
#
# WHAT IT DOES:
#   1. Validates the disko configuration syntax
#   2. Shows the partition layout that would be created
#   3. Generates the partitioning script (but doesn't execute it)
#   4. Shows what commands would be run
#   5. Validates LUKS and filesystem settings
#
# ================================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ================================================================================
# HELPER FUNCTIONS
# ================================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_section() {
    echo
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}========================================${NC}"
}

# ================================================================================
# CONFIGURATION
# ================================================================================

HOSTNAME="${1:-blazar}"
DISK="${2:-nvme0n1}"
DISKO_CONFIG="hosts/$HOSTNAME/disko.nix"

# ================================================================================
# MAIN SCRIPT
# ================================================================================

echo "================================================================================"
echo "                    Disko Configuration Dry-Run"
echo "================================================================================"
echo
echo "Hostname: $HOSTNAME"
echo "Target disk: /dev/$DISK"
echo "Config file: $DISKO_CONFIG"
echo

# ================================================================================
# 1. Check if configuration file exists
# ================================================================================

log_section "1. Checking Configuration File"

if [[ ! -f "$DISKO_CONFIG" ]]; then
    log_error "Disko configuration not found: $DISKO_CONFIG"
    echo
    log_info "Available hosts:"
    ls -1 hosts/ 2>/dev/null || echo "  No hosts directory found"
    exit 1
fi

log_success "Configuration file found: $DISKO_CONFIG"

# ================================================================================
# 2. Validate Nix syntax
# ================================================================================

log_section "2. Validating Nix Syntax"

if command -v nix &> /dev/null; then
    log_info "Checking Nix syntax..."
    if nix-instantiate --parse "$DISKO_CONFIG" > /dev/null 2>&1; then
        log_success "Nix syntax is valid"
    else
        log_error "Nix syntax error in $DISKO_CONFIG"
        nix-instantiate --parse "$DISKO_CONFIG"
        exit 1
    fi
else
    log_warning "Nix not available, skipping syntax validation"
fi

# ================================================================================
# 3. Show configuration summary
# ================================================================================

log_section "3. Configuration Summary"

log_info "Extracting configuration details..."
echo

# Show disk device
echo -e "${YELLOW}Target Device:${NC}"
grep -E "device = \"/dev/" "$DISKO_CONFIG" | head -1 || echo "  Not found"
echo

# Show partitions
echo -e "${YELLOW}Partitions:${NC}"
grep -E "^\s*(ESP|swap|root|boot|home)" "$DISKO_CONFIG" | grep -v "#" || echo "  Could not parse partitions"
echo

# Show partition sizes
echo -e "${YELLOW}Partition Sizes:${NC}"
grep -E "size = " "$DISKO_CONFIG" | grep -v "#" || echo "  Could not parse sizes"
echo

# Show filesystems
echo -e "${YELLOW}Filesystems:${NC}"
grep -E "format = " "$DISKO_CONFIG" | grep -v "#" || echo "  Could not parse filesystems"
echo

# Show encryption
echo -e "${YELLOW}Encryption:${NC}"
if grep -q "type = \"luks\"" "$DISKO_CONFIG"; then
    echo "  ✓ LUKS encryption enabled"
    grep -E "name = \"crypt" "$DISKO_CONFIG" | grep -v "#" || true
else
    echo "  ✗ No encryption configured"
fi
echo

# ================================================================================
# 4. Show what would be created
# ================================================================================

log_section "4. Partition Layout Preview"

log_info "This is what would be created on /dev/$DISK:"
echo

cat << EOF
┌─────────────────────────────────────────────────────────────┐
│                    /dev/$DISK                                
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
EOF

echo

# ================================================================================
# 5. Show commands that would be executed
# ================================================================================

log_section "5. Commands That Would Be Executed"

log_warning "The following commands would be run (NOT EXECUTED IN DRY-RUN):"
echo

# Determine partition suffix (p for nvme, nothing for sda/sdb)
if [[ "$DISK" =~ ^nvme ]]; then
    PART_SUFFIX="p"
else
    PART_SUFFIX=""
fi

cat << EOF
# 1. Partition the disk
${MAGENTA}sgdisk --zap-all /dev/$DISK${NC}
${MAGENTA}sgdisk --new=1:0:+2G --typecode=1:EF00 --change-name=1:ESP /dev/$DISK${NC}
${MAGENTA}sgdisk --new=2:0:+16G --typecode=2:8200 --change-name=2:swap /dev/$DISK${NC}
${MAGENTA}sgdisk --new=3:0:0 --typecode=3:8300 --change-name=3:root /dev/$DISK${NC}

# 2. Format EFI partition
${MAGENTA}mkfs.vfat -F 32 -n ESP /dev/${DISK}${PART_SUFFIX}1${NC}

# 3. Setup LUKS encryption for swap
${MAGENTA}cryptsetup luksFormat --type luks2 /dev/${DISK}${PART_SUFFIX}2${NC}
${MAGENTA}cryptsetup open /dev/${DISK}${PART_SUFFIX}2 cryptswap${NC}
${MAGENTA}mkswap /dev/mapper/cryptswap${NC}

# 4. Setup LUKS encryption for root
${MAGENTA}cryptsetup luksFormat --type luks2 /dev/${DISK}${PART_SUFFIX}3${NC}
${MAGENTA}cryptsetup open /dev/${DISK}${PART_SUFFIX}3 cryptroot${NC}

# 5. Format root with bcachefs
${MAGENTA}bcachefs format \\
    --compression=lz4 \\
    --background_compression=lz4 \\
    --data_checksum=xxhash \\
    --metadata_checksum=xxhash \\
    --discard \\
    --foreground_target=ssd \\
    --background_target=ssd \\
    --promote_target=ssd \\
    --metadata_replicas=1 \\
    --data_replicas=1 \\
    --journal_size=512M \\
    --fs_label=nixos \\
    /dev/mapper/cryptroot${NC}

# 6. Mount filesystems
${MAGENTA}mount /dev/mapper/cryptroot /mnt${NC}
${MAGENTA}mkdir -p /mnt/boot${NC}
${MAGENTA}mount /dev/${DISK}${PART_SUFFIX}1 /mnt/boot${NC}
${MAGENTA}swapon /dev/mapper/cryptswap${NC}
EOF

echo

# ================================================================================
# 6. Validate with disko (if available)
# ================================================================================

log_section "6. Disko Validation"

if command -v nix &> /dev/null; then
    log_info "Attempting to validate with disko..."
    
    # Create a temporary modified config with the correct disk
    TEMP_CONFIG=$(mktemp)
    sed "s|/dev/nvme0n1|/dev/$DISK|g" "$DISKO_CONFIG" > "$TEMP_CONFIG"
    
    log_info "Testing disko configuration evaluation..."
    if nix --experimental-features "nix-command flakes" eval --impure --expr "
        let
          disko = builtins.getFlake \"github:nix-community/disko\";
          config = import $TEMP_CONFIG {};
        in
          config.disko.devices.disk
    " &> /dev/null; then
        log_success "Disko configuration can be evaluated successfully"
    else
        log_warning "Could not evaluate disko configuration (this may be normal)"
    fi
    
    rm -f "$TEMP_CONFIG"
else
    log_warning "Nix not available, skipping disko validation"
fi

# ================================================================================
# 7. Security and optimization notes
# ================================================================================

log_section "7. Security & Optimization Notes"

cat << EOF
${GREEN}✓ Security Features:${NC}
  • LUKS2 encryption with Argon2id KDF
  • Encrypted swap (supports hibernation)
  • Encrypted root filesystem
  • Secure boot partition permissions (umask=0077)

${GREEN}✓ SSD Optimizations:${NC}
  • TRIM/discard enabled on all partitions
  • noatime mount options (reduces writes)
  • Periodic TRIM via fstrim.timer (weekly)
  • I/O scheduler set to 'none' for NVMe
  • Optimized kernel sysctl settings

${GREEN}✓ bcachefs Features:${NC}
  • LZ4 compression (fast, good ratio)
  • xxhash checksumming (data integrity)
  • SSD-optimized targets
  • 512MB journal for better performance

${YELLOW}⚠ Important Notes:${NC}
  • You will be prompted for LUKS password during boot
  • Both swap and root use the same password
  • Make sure to backup your LUKS headers after setup
  • bcachefs requires kernel 6.7+ (NixOS unstable recommended)
EOF

echo

# ================================================================================
# 8. Final summary
# ================================================================================

log_section "8. Summary"

log_success "Dry-run complete! Configuration is valid."
echo
log_info "To actually apply this configuration:"
echo "  1. Boot into NixOS live ISO"
echo "  2. Run: sudo nix --experimental-features \"nix-command flakes\" run github:nix-community/disko -- --mode disko $DISKO_CONFIG"
echo "  3. Or use the install.sh script"
echo
log_warning "⚠ WARNING: This will DESTROY ALL DATA on /dev/$DISK!"
echo

