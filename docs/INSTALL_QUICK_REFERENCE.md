# Installation Quick Reference

Fast reference for installing NixOS from this configuration.

---

## One-Line Install

```bash
curl -L https://raw.githubusercontent.com/dscv103/blazar-nixos/master/install.sh | sudo bash
```

---

## Manual Install (5 Steps)

### 1. Boot NixOS Live ISO

- Download from [nixos.org/download](https://nixos.org/download)
- Create bootable USB
- Boot from USB

### 2. Connect to Internet

**Wired:** Usually automatic

**WiFi:**
```bash
sudo systemctl start wpa_supplicant
sudo wpa_cli
> add_network
> set_network 0 ssid "NetworkName"
> set_network 0 psk "Password"
> enable_network 0
> quit
```

### 3. Partition Disk

```bash
git clone https://github.com/dscv103/blazar-nixos.git /tmp/config
cd /tmp/config
sudo nano hosts/blazar/disko.nix  # Change /dev/nvme0n1 to your disk
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- \
    --mode disko hosts/blazar/disko.nix
```

### 4. Install

```bash
sudo mkdir -p /mnt/etc/nixos
sudo cp -r /tmp/config/* /mnt/etc/nixos/
sudo nixos-install --flake /mnt/etc/nixos#blazar --no-root-passwd
sudo nixos-enter --root /mnt -c 'passwd dscv'
```

### 5. Reboot

```bash
reboot
```

---

## Post-Install

### Login
- **User:** `dscv`
- **Password:** `changeme` (CHANGE THIS!)

### Change Password

```bash
passwd
mkpasswd -m sha-512  # Generate hash
sudo nano /etc/nixos/nixos/users.nix  # Add hashedPassword
sudo nixos-rebuild switch --flake /etc/nixos#blazar
```

---

## Common Disk Names

- **NVMe:** `/dev/nvme0n1`
- **SATA/SSD:** `/dev/sda`
- **Virtual:** `/dev/vda`

Check with: `lsblk`

---

## Troubleshooting

### No Internet
```bash
ping google.com
nmcli device wifi connect "Network" password "Password"
```

### Check Disk
```bash
lsblk
```

### View Logs
```bash
journalctl -xe
```

### Boot Issues
- Press any key during boot to pause
- Select previous generation
- Disable Secure Boot in BIOS

---

## Hardware Notes

**Current Config (Blazar):**
- AMD Ryzen 7 5800X
- NVIDIA RTX 3080
- NVMe SSD

**For Different Hardware:**
- Edit `nixos/hardware/*.nix`
- Update `hosts/blazar/disko.nix` for different disk

---

## Links

- **Full Guide:** [docs/INSTALLATION.md](INSTALLATION.md)
- **Repository:** [github.com/dscv103/blazar-nixos](https://github.com/dscv103/blazar-nixos)
- **NixOS Manual:** [nixos.org/manual](https://nixos.org/manual/nixos/stable/)

