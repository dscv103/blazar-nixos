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
# ================================================================================

set -euo pipefail

# ================================================================================
# CONFIGURATION
# ================================================================================

REPO_URL="https://github.com/dscv103/blazar-nixos.git"
REPO_BRANCH="master"
CONFIG_DIR="/mnt/etc/nixos"
HOSTNAME="blazar"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

confirm() {
    local prompt="$1"
    local response
    read -p "$(echo -e ${YELLOW}[CONFIRM]${NC} $prompt [y/N]: )" response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# ================================================================================
# PREREQUISITE CHECKS
# ================================================================================

check_prerequisites() {
    log_info "Checking prerequisites..."
    
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
    log_info "Available disks:"
    lsblk -d -o NAME,SIZE,TYPE,MODEL | grep disk
    echo
    
    local disk
    read -p "$(echo -e ${YELLOW}[INPUT]${NC} Enter target disk (e.g., nvme0n1, sda): )" disk
    
    # Validate disk exists
    if [[ ! -b "/dev/$disk" ]]; then
        log_error "Disk /dev/$disk does not exist"
        exit 1
    fi
    
    # Show disk info
    log_info "Selected disk: /dev/$disk"
    lsblk "/dev/$disk"
    echo
    
    # Confirm disk selection
    log_warning "ALL DATA ON /dev/$disk WILL BE DESTROYED!"
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
    
    read -p "$(echo -e ${YELLOW}[INPUT]${NC} Enter hostname [${default_hostname}]: )" hostname
    hostname="${hostname:-$default_hostname}"
    
    log_info "Hostname set to: $hostname"
    echo "$hostname"
}

# ================================================================================
# DISK PARTITIONING
# ================================================================================

partition_disk() {
    local disk="$1"
    local hostname="$2"
    
    log_info "Partitioning disk /dev/$disk using disko..."
    
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
    echo "================================================================================"
    echo "                    NixOS Installation Script"
    echo "================================================================================"
    echo
    echo "This script will install NixOS from: $REPO_URL"
    echo "Branch: $REPO_BRANCH"
    echo
    
    # Check prerequisites
    check_prerequisites
    
    # Select disk
    DISK=$(select_disk)
    
    # Configure hostname
    HOSTNAME=$(configure_hostname)
    
    # Final confirmation
    echo
    log_warning "Installation Summary:"
    echo "  - Target disk: /dev/$DISK (WILL BE WIPED)"
    echo "  - Hostname: $HOSTNAME"
    echo "  - Repository: $REPO_URL"
    echo "  - Branch: $REPO_BRANCH"
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
    if confirm "Reboot now?"; then
        log_info "Rebooting..."
        reboot
    else
        log_info "Remember to reboot before using the new system"
    fi
}

# Run main function
main "$@"

