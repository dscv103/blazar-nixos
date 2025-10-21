# NixOS Installation Guide

Complete guide for installing this NixOS configuration on bare metal from a live ISO.

---

## Quick Start

### One-Line Installation

From a NixOS live ISO with internet connection:

```bash
curl -L https://raw.githubusercontent.com/dscv103/blazar-nixos/master/install.sh | sudo bash
```

Or using wget:

```bash
wget -O - https://raw.githubusercontent.com/dscv103/blazar-nixos/master/install.sh | sudo bash
```

---

## Prerequisites

### 1. NixOS Live ISO

Download the latest NixOS ISO from [nixos.org/download](https://nixos.org/download):
- **Recommended:** NixOS 24.11 (or later)
- **Minimal ISO** is sufficient (smaller download)
- **Graphical ISO** if you prefer a GUI

### 2. Create Bootable USB

**On Linux:**
```bash
sudo dd if=nixos-minimal-24.11.iso of=/dev/sdX bs=4M status=progress
```

**On macOS:**
```bash
sudo dd if=nixos-minimal-24.11.iso of=/dev/diskX bs=4m
```

**On Windows:**
- Use [Rufus](https://rufus.ie/) or [Etcher](https://www.balena.io/etcher/)

### 3. Boot from USB

1. Insert USB drive
2. Restart computer
3. Enter BIOS/UEFI (usually F2, F12, Del, or Esc)
4. Select USB drive as boot device
5. Boot into NixOS live environment

---

## Installation Methods

### Method 1: Automated Installation (Recommended)

The automated script handles everything:

```bash
# Boot into NixOS live ISO
# Connect to internet (see "Network Setup" below)
# Run the installation script
curl -L https://raw.githubusercontent.com/dscv103/blazar-nixos/master/install.sh | sudo bash
```

**What the script does:**
1. ✅ Checks prerequisites
2. ✅ Prompts for disk selection
3. ✅ Prompts for hostname
4. ✅ Partitions disk using disko
5. ✅ Clones configuration from GitHub
6. ✅ Installs NixOS
7. ✅ Sets up user password

**Interactive prompts:**
- Target disk (e.g., `nvme0n1`, `sda`)
- Hostname (default: `blazar`)
- Confirmation before wiping disk
- Optional: Set custom password

---

### Method 2: Manual Installation

For more control over the installation process:

#### Step 1: Network Setup

**Wired (Ethernet):**
```bash
# Usually works automatically
ping google.com
```

**WiFi:**
```bash
# Start wpa_supplicant
sudo systemctl start wpa_supplicant

# Connect to WiFi
sudo wpa_cli
> add_network
> set_network 0 ssid "YourNetworkName"
> set_network 0 psk "YourPassword"
> enable_network 0
> quit

# Verify connection
ping google.com
```

#### Step 2: Partition Disk

```bash
# Clone repository
git clone https://github.com/dscv103/blazar-nixos.git /tmp/nixos-config
cd /tmp/nixos-config

# Edit disko config for your disk
# Replace /dev/nvme0n1 with your disk (e.g., /dev/sda)
sudo nano hosts/blazar/disko.nix

# Run disko to partition and format
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- \
    --mode disko hosts/blazar/disko.nix
```

#### Step 3: Install NixOS

```bash
# Copy configuration to /mnt
sudo mkdir -p /mnt/etc/nixos
sudo cp -r /tmp/nixos-config/* /mnt/etc/nixos/

# Install NixOS
sudo nixos-install --flake /mnt/etc/nixos#blazar --no-root-passwd

# Set user password
sudo nixos-enter --root /mnt -c 'passwd dscv'

# Reboot
reboot
```

---

## Network Setup (Live ISO)

### Wired Connection

Usually works automatically. Verify with:
```bash
ping google.com
```

### WiFi Connection

**Using wpa_supplicant:**
```bash
sudo systemctl start wpa_supplicant
sudo wpa_cli
> add_network
> set_network 0 ssid "YourNetworkName"
> set_network 0 psk "YourPassword"
> enable_network 0
> quit
```

**Using nmcli (if available):**
```bash
nmcli device wifi list
nmcli device wifi connect "YourNetworkName" password "YourPassword"
```

---

## Disk Configuration

### Supported Configurations

The default disko configuration (`hosts/blazar/disko.nix`) creates:

- **EFI System Partition:** 2GB (FAT32)
- **Swap:** 16GB
- **Root (/):** Remaining space (BTRFS with compression)

### Customizing Disk Layout

Edit `hosts/blazar/disko.nix` before installation:

```nix
{
  disko.devices = {
    disk = {
      main = {
        device = "/dev/nvme0n1";  # Change this to your disk
        # ... rest of configuration
      };
    };
  };
}
```

**Common disk names:**
- NVMe: `/dev/nvme0n1`, `/dev/nvme1n1`
- SATA/SSD: `/dev/sda`, `/dev/sdb`
- Virtual: `/dev/vda`, `/dev/vdb`

---

## Post-Installation

### First Boot

1. **Remove USB drive**
2. **Reboot**
3. **Select NixOS** from bootloader (2-second timeout)
4. **Login:**
   - Username: `dscv`
   - Password: `changeme` (or custom if set during installation)

### Immediate Tasks

#### 1. Change Password

```bash
# Change user password
passwd

# Generate hashed password for config
mkpasswd -m sha-512
```

#### 2. Update Configuration

```bash
# Edit user configuration
sudo nano /etc/nixos/nixos/users.nix

# Replace initialPassword with hashedPassword:
# hashedPassword = "$6$rounds=656000$...your-hash-here...";

# Rebuild system
sudo nixos-rebuild switch --flake /etc/nixos#blazar
```

#### 3. Verify System

```bash
# Check system info
neofetch

# Check services
systemctl status display-manager
systemctl --user status niri-flake

# Check hardware acceleration
nvidia-smi
vainfo
```

---

## Troubleshooting

### Installation Fails

**Check internet connection:**
```bash
ping google.com
```

**Check disk exists:**
```bash
lsblk
```

**Check logs:**
```bash
journalctl -xe
```

### Boot Issues

**System won't boot:**
1. Select previous generation from bootloader
2. Check BIOS/UEFI settings (Secure Boot should be disabled)
3. Verify EFI partition is mounted

**Bootloader timeout too short:**
- Press any key during boot to pause countdown
- Edit `nixos/boot.nix` and increase timeout

### Display Issues

**No display after boot:**
1. Check NVIDIA driver loaded: `lsmod | grep nvidia`
2. Check kernel parameters: `cat /proc/cmdline`
3. Try safe mode from bootloader

**SDDM doesn't start:**
```bash
systemctl status display-manager
journalctl -u display-manager
```

### Network Issues

**No internet after installation:**
```bash
# Check NetworkManager
systemctl status NetworkManager

# Connect to WiFi
nmcli device wifi list
nmcli device wifi connect "YourNetwork" password "YourPassword"
```

---

## Hardware-Specific Notes

### Current Configuration (Blazar)

- **CPU:** AMD Ryzen 7 5800X
- **GPU:** NVIDIA RTX 3080
- **Disk:** NVMe SSD
- **RAM:** 32GB+

### Adapting for Different Hardware

#### Different GPU

**AMD GPU:**
```nix
# In nixos/hardware/default.nix
# Replace nvidia.nix with amd.nix
imports = [
  ./amd.nix  # Instead of ./nvidia.nix
];
```

**Intel GPU:**
```nix
# In nixos/hardware/default.nix
imports = [
  ./intel.nix  # Instead of ./nvidia.nix
];
```

#### Different CPU

**Intel CPU:**
- Update `nixos/hardware/cpu.nix`
- Change `hardware.cpu.amd.updateMicrocode` to `hardware.cpu.intel.updateMicrocode`

#### Different Disk

- Update `hosts/blazar/disko.nix`
- Change device path (e.g., `/dev/sda` instead of `/dev/nvme0n1`)

---

## Advanced Options

### Custom Hostname

During installation, you'll be prompted for a hostname. To use a different hostname:

1. Create new host directory: `hosts/yourhostname/`
2. Copy files from `hosts/blazar/`
3. Update `flake.nix` to include new host
4. Run installation with new hostname

### Dual Boot

The disko configuration will wipe the entire disk. For dual boot:

1. Manually partition disk before installation
2. Modify disko config to use existing partitions
3. Install bootloader to separate EFI partition

### Encrypted Root

To enable disk encryption, modify `hosts/blazar/disko.nix`:

```nix
# Add LUKS encryption
content = {
  type = "luks";
  name = "cryptroot";
  settings.allowDiscards = true;
  passwordFile = "/tmp/secret.key";
  content = {
    type = "btrfs";
    # ... rest of config
  };
};
```

---

## Support

### Getting Help

- **Issues:** [GitHub Issues](https://github.com/dscv103/blazar-nixos/issues)
- **NixOS Manual:** [nixos.org/manual](https://nixos.org/manual/nixos/stable/)
- **NixOS Discourse:** [discourse.nixos.org](https://discourse.nixos.org/)
- **NixOS Wiki:** [nixos.wiki](https://nixos.wiki/)

### Reporting Bugs

When reporting installation issues, include:
- Hardware specifications
- Installation method used
- Error messages
- Output of `nixos-version`
- Relevant logs from `journalctl`

---

## License

This configuration is provided as-is. Use at your own risk.

