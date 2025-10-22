#!/usr/bin/env bash
# ================================================================================
# NixOS Installation Script
# ================================================================================
#
# PURPOSE:
#   Automated installation of NixOS configuration from GitHub repository
#   Designed to be run from a NixOS live ISO on bare metal
#
# USAGE:
#   curl -L https://raw.githubusercontent.com/dscv103/blazar-nixos/master/install.sh | bash
#   OR
#   wget -O - https://raw.githubusercontent.com/dscv103/blazar-nixos/master/install.sh | bash
#   OR (for dry-run testing):
#   bash install.sh --dry-run
#
# REQUIREMENTS:
#   - NixOS live ISO (23.11 or later)
#   - Internet connection
#   - Target disk (will be WIPED)
#
# WHAT IT DOES:
#   1. Checks prerequisites
#   2. Prompts for installation parameters
#   3. Partitions and formats disk using disko
#   4. Clones configuration from GitHub
#   5. Installs NixOS with flake configuration
#   6. Sets up user password
#
# OPTIONS:
#   --dry-run    Simulate installation without making any changes
#
# ================================================================================

set -euo pipefail

# ================================================================================
# CONFIGURATION
# ================================================================================

REPO_URL="https://github.com/dscv103/blazar-nixos.git"
REPO_BRANCH="master"
CONFIG_DIR="/mnt/etc/nixos"
HOSTNAME="blazar"
DRY_RUN=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
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

log_dry_run() {
    echo -e "${MAGENTA}[DRY-RUN]${NC} $1"
}

confirm() {
    local prompt="$1"
    local response

    # In dry-run mode, auto-confirm with 'y'
    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry_run "Auto-confirming: $prompt"
        return 0
    fi

    read -p "$(echo -e "${YELLOW}[CONFIRM]${NC} $prompt [y/N]: ")" response
    case "$response" in
        [yY][eE][sS]|[yY])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Execute command or simulate in dry-run mode
run_cmd() {
    local cmd="$1"
    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry_run "Would execute: $cmd"
    else
        eval "$cmd"
    fi
}

# ================================================================================
# PREREQUISITE CHECKS
# ================================================================================

check_prerequisites() {
    log_info "Checking prerequisites..."

    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry_run "Skipping root check (dry-run mode)"
        log_dry_run "Skipping NixOS check (dry-run mode)"
        log_dry_run "Skipping internet check (dry-run mode)"
        log_dry_run "Skipping git installation check (dry-run mode)"
        log_success "All prerequisites would be checked"
        return 0
    fi

    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root (use sudo)"
        exit 1
    fi

    # Check if running on NixOS
    if [[ ! -f /etc/NIXOS ]]; then
        log_error "This script must be run on NixOS (live ISO or existing installation)"
        exit 1
    fi

    # Check internet connection
    if ! ping -c 1 google.com &> /dev/null; then
        log_error "No internet connection detected"
        exit 1
    fi

    # Check if git is available
    if ! command -v git &> /dev/null; then
        log_info "Installing git..."
        nix-env -iA nixos.git
    fi

    log_success "All prerequisites met"
}

# ================================================================================
# DISK SELECTION
# ================================================================================

select_disk() {
    local disk

    log_info "Available disks:" >&2

    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry_run "Would show: lsblk -d -o NAME,SIZE,TYPE,MODEL | grep disk" >&2
        echo "  NAME        SIZE TYPE MODEL" >&2
        echo "  sda       500G disk Samsung_SSD_860" >&2
        echo "  nvme0n1     1T disk SAMSUNG MZVLB1T0" >&2
        echo >&2
        disk="nvme0n1"
        log_dry_run "Using simulated disk: $disk" >&2
    else
        lsblk -d -o NAME,SIZE,TYPE,MODEL | grep disk >&2
        echo >&2

        read -p "$(echo -e "${YELLOW}[INPUT]${NC} Enter target disk (e.g., nvme0n1, sda): ")" disk

        # Validate disk exists
        if [[ ! -b "/dev/$disk" ]]; then
            log_error "Disk /dev/$disk does not exist"
            exit 1
        fi

        # Show disk info
        log_info "Selected disk: /dev/$disk" >&2
        lsblk "/dev/$disk" >&2
        echo >&2
    fi

    # Confirm disk selection
    log_warning "ALL DATA ON /dev/$disk WILL BE DESTROYED!" >&2
    if ! confirm "Are you sure you want to use /dev/$disk?"; then
        log_error "Installation cancelled"
        exit 1
    fi

    echo "$disk"
}

# ================================================================================
# HOSTNAME CONFIGURATION
# ================================================================================

configure_hostname() {
    local default_hostname="$HOSTNAME"
    local hostname

    if [[ "$DRY_RUN" == "true" ]]; then
        hostname="$default_hostname"
        log_dry_run "Using default hostname: $hostname" >&2
    else
        read -p "$(echo -e "${YELLOW}[INPUT]${NC} Enter hostname [${default_hostname}]: ")" hostname
        hostname="${hostname:-$default_hostname}"
    fi

    log_info "Hostname set to: $hostname" >&2
    echo "$hostname"
}

# ================================================================================
# DISK PARTITIONING
# ================================================================================

partition_disk() {
    local disk="$1"
    local hostname="$2"

    log_info "Partitioning disk /dev/$disk using disko..."

    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry_run "Would create temporary directory"
        log_dry_run "Would execute: git clone --depth 1 --branch $REPO_BRANCH $REPO_URL <temp_dir>"
        log_dry_run "Would check for disko config at: hosts/$hostname/disko.nix"
        log_dry_run "Would update disko config: sed -i 's|/dev/nvme0n1|/dev/$disk|g' <disko_config>"
        log_dry_run "Would execute: nix --experimental-features 'nix-command flakes' run github:nix-community/disko -- --mode disko <disko_config>"
        log_dry_run "Would clean up temporary directory"
        log_success "Disk would be partitioned successfully"
        return 0
    fi

    # Clone repository to temporary location to get disko config
    local temp_dir=$(mktemp -d)
    log_info "Cloning repository to get disko configuration..."
    git clone --depth 1 --branch "$REPO_BRANCH" "$REPO_URL" "$temp_dir"

    # Update disko config with selected disk
    local disko_config="$temp_dir/hosts/$hostname/disko.nix"

    if [[ ! -f "$disko_config" ]]; then
        log_error "Disko configuration not found at $disko_config"
        log_error "Available hosts:"
        ls -1 "$temp_dir/hosts/"
        exit 1
    fi

    # Replace disk device in disko config
    log_info "Updating disko configuration for /dev/$disk..."
    sed -i "s|/dev/nvme0n1|/dev/$disk|g" "$disko_config"

    # Run disko
    log_info "Running disko (this will WIPE /dev/$disk)..."
    nix --experimental-features "nix-command flakes" run github:nix-community/disko -- \
        --mode disko "$disko_config"

    log_success "Disk partitioned successfully"

    # Clean up temp directory
    rm -rf "$temp_dir"
}

# ================================================================================
# CLONE CONFIGURATION
# ================================================================================

clone_configuration() {
    log_info "Cloning NixOS configuration from GitHub..."

    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry_run "Would execute: mkdir -p $CONFIG_DIR"
        log_dry_run "Would execute: git clone --branch $REPO_BRANCH $REPO_URL $CONFIG_DIR"
        log_success "Configuration would be cloned to $CONFIG_DIR"
        return 0
    fi

    # Create config directory
    mkdir -p "$CONFIG_DIR"

    # Clone repository
    git clone --branch "$REPO_BRANCH" "$REPO_URL" "$CONFIG_DIR"

    log_success "Configuration cloned to $CONFIG_DIR"
}

# ================================================================================
# INSTALL NIXOS
# ================================================================================

install_nixos() {
    local hostname="$1"

    log_info "Installing NixOS with flake configuration..."

    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry_run "Would execute: nixos-install --flake $CONFIG_DIR#$hostname --no-root-passwd"
        log_success "NixOS would be installed successfully"
        return 0
    fi

    # Install NixOS
    nixos-install --flake "$CONFIG_DIR#$hostname" --no-root-passwd

    log_success "NixOS installed successfully"
}

# ================================================================================
# POST-INSTALLATION
# ================================================================================

setup_user_password() {
    log_info "Setting up user password..."

    log_warning "The configuration uses 'initialPassword' which is insecure"
    log_warning "You should change the password after first login with: passwd"

    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry_run "Would prompt to set custom password"
        log_dry_run "Would execute: nixos-enter --root /mnt -c 'passwd dscv'"
        log_info "Default password is 'changeme' - CHANGE THIS AFTER FIRST LOGIN!"
        return 0
    fi

    if confirm "Do you want to set a custom password now?"; then
        nixos-enter --root /mnt -c 'passwd dscv'
    else
        log_info "Default password is 'changeme' - CHANGE THIS AFTER FIRST LOGIN!"
    fi
}

post_install_info() {
    log_success "Installation complete!"
    echo
    log_info "Next steps:"
    echo "  1. Reboot into your new system: reboot"
    echo "  2. Login with username: dscv"
    echo "  3. Change your password: passwd"
    echo "  4. Generate a hashed password: mkpasswd -m sha-512"
    echo "  5. Update nixos/users.nix with hashedPassword"
    echo "  6. Rebuild: sudo nixos-rebuild switch --flake /etc/nixos#$HOSTNAME"
    echo
    log_warning "IMPORTANT: Change the default password immediately!"
}

# ================================================================================
# MAIN INSTALLATION FLOW
# ================================================================================

main() {
    # Parse command line arguments
    for arg in "$@"; do
        case $arg in
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --help|-h)
                echo "Usage: $0 [--dry-run] [--help]"
                echo ""
                echo "Options:"
                echo "  --dry-run    Simulate installation without making any changes"
                echo "  --help       Show this help message"
                exit 0
                ;;
            *)
                log_error "Unknown option: $arg"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done

    echo "================================================================================"
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "                NixOS Installation Script (DRY-RUN MODE)"
    else
        echo "                    NixOS Installation Script"
    fi
    echo "================================================================================"
    echo
    echo "This script will install NixOS from: $REPO_URL"
    echo "Branch: $REPO_BRANCH"
    echo

    if [[ "$DRY_RUN" == "true" ]]; then
        log_warning "DRY-RUN MODE: No actual changes will be made to your system"
        echo
    fi

    # Check prerequisites
    check_prerequisites
    echo

    # Select disk
    DISK=$(select_disk)
    echo

    # Configure hostname
    HOSTNAME=$(configure_hostname)

    # Final confirmation
    echo
    log_warning "Installation Summary:"
    echo "  - Target disk: /dev/$DISK (WILL BE WIPED)"
    echo "  - Hostname: $HOSTNAME"
    echo "  - Repository: $REPO_URL"
    echo "  - Branch: $REPO_BRANCH"
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "  - Mode: DRY-RUN (simulation only)"
    fi
    echo

    if ! confirm "Proceed with installation?"; then
        log_error "Installation cancelled"
        exit 1
    fi

    # Partition disk
    partition_disk "$DISK" "$HOSTNAME"

    # Clone configuration
    clone_configuration

    # Install NixOS
    install_nixos "$HOSTNAME"

    # Setup user password
    setup_user_password

    # Show post-installation info
    post_install_info

    # Ask to reboot
    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry_run "Would prompt to reboot"
        log_info "Dry-run complete! No changes were made to your system."
    else
        if confirm "Reboot now?"; then
            log_info "Rebooting..."
            reboot
        else
            log_info "Remember to reboot before using the new system"
        fi
    fi
}

# Run main function
main "$@"

