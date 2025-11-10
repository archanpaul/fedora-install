#!/bin/bash
# Multi-ISO GRUB2 USB setup script (Fedora Specific)
# AUTHOR: Assistant
# WARNING: This script can format DATA. Use with caution.
#
# === Fedora Multi-Boot USB Setup Guide ===
#
# Prerequisites:
# - A Linux system (Fedora/RHEL preferred).
# - Root access (sudo).
# - Packages: parted, grub2-install, grub2-mkimage, mkfs.fat, mkfs.ext4, isoinfo
#   (Fedora: sudo dnf install parted grub2-tools-extra dosfstools e2fsprogs genisoimage)
#
# Usage:
# sudo ./fedora_usb_install_media.sh --usb-dev /dev/sdX [OPTIONS]
#
# Options:
#   --usb-dev /dev/sdX      REQUIRED: Specify USB device (e.g., /dev/sdb)
#                           WARNING: Selecting the wrong device will WIPE IT.
#   --partition             Wipes the entire USB drive and creates new partitions.
#                           (Recommended for first-time setup)
#   --iso filename.iso      Adds a single ISO. Can be used multiple times.
#   --iso-dir /path/to/dir  Adds all .iso files found in the specified folder.
#   --help                  Shows this help message.
#
# Examples:
# 1. Full Setup (Wipe & Install):
#    sudo ./fedora_usb_install_media.sh --usb-dev /dev/sdb --partition --iso-dir ~/Downloads/isos
#
# 2. Update ISOs (Keep existing partition data):
#    sudo ./fedora_usb_install_media.sh --usb-dev /dev/sdb --iso-dir ./ --iso ~/Downloads/Fedora-Workstation-Live-x86_64-38-1.6.iso
#
# Testing with QEMU (Optional):
# You can test the USB drive without rebooting using QEMU.
# Requirements: qemu-kvm, edk2-ovmf (Fedora) or ovmf (Ubuntu/Debian)
# Command:
# sudo qemu-system-x86_64 -enable-kvm -m 2G -bios /usr/share/edk2/ovmf/OVMF_CODE.fd -drive file=/dev/sdX,format=raw,media=disk
# (Note: Path to OVMF_CODE.fd may vary by distro. Try /usr/share/OVMF/OVMF_CODE.fd if the above fails.)
# =========================================


set -e

# === Global Variables ===
USB_DEV=""           # MUST be set by user for safety
ESP_PART=""
DATA_PART=""
ISO_DIR="./iso_files"
ISO_LIST=()          # Start empty
MNT_ESP="/mnt/usb-esp"
MNT_DATA="/mnt/usb-data"
DO_PARTITION=false

# === Safety Checks ===
if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run as root (sudo)."
   exit 1
fi

# Dependency check
for cmd in parted grub2-install mkfs.fat mkfs.ext4 isoinfo; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "Warning: Command '$cmd' not found. Some features might fail."
  fi
done

# === Cleanup Trap ===
cleanup() {
  if mountpoint -q "$MNT_DATA"; then umount "$MNT_DATA"; fi
  if mountpoint -q "$MNT_ESP"; then umount "$MNT_ESP"; fi
}
trap cleanup EXIT

# === Help ===
show_help() {
  sed -n '2,/^# =/p' "$0" | sed 's/^# //' | sed 's/^#//'
}

# === Parse Arguments ===
while [[ $# -gt 0 ]]; do
  case $1 in
    --partition) DO_PARTITION=true; shift ;;
    --iso) ISO_LIST+=("$ISO_DIR/$2"); shift 2 ;;
    --iso-path) ISO_LIST+=("$2"); shift 2 ;;
    --iso-dir)
      if [ -d "$2" ]; then
         for f in "$2"/*.iso; do [ -e "$f" ] && ISO_LIST+=("$f"); done
      else
         echo "Error: Directory $2 not found."
         exit 1
      fi
      shift 2 ;;
    --usb-dev)
      USB_DEV="$2"
      if [[ "$USB_DEV" == "/dev/sda" ]]; then
         echo "WARNING: /dev/sda is often your main system drive."
         echo "Are you ABSOLUTELY sure? (type 'yes' to continue)"
         read -r confirm
         if [[ "$confirm" != "yes" ]]; then exit 1; fi
      fi
      ESP_PART="${USB_DEV}1"
      DATA_PART="${USB_DEV}2"
      shift 2 ;;
    --help) show_help; exit 0 ;;
    *) echo "Unknown option: $1"; show_help; exit 1 ;;
  esac
done

# === Validation ===
if [ -z "$USB_DEV" ]; then
  echo "Error: You must specify a USB device with --usb-dev."
  show_help
  exit 1
fi

if [ ${#ISO_LIST[@]} -eq 0 ]; then
  echo "Error: No ISOs specified. Use --iso, --iso-path, or --iso-dir."
  exit 1
fi

# === Execution Start ===
echo "=== Fedora Multi-Boot USB Setup ==="
echo "Target Device: $USB_DEV"
echo "ISOs to install: ${#ISO_LIST[@]}"

if $DO_PARTITION; then
  echo -e "\nWARNING: ALL DATA ON $USB_DEV WILL BE DESTROYED."
  echo "Press Enter to continue or Ctrl+C to abort..."
  read -r

  echo ">>> Wiping and creating GPT on $USB_DEV..."
  parted -s "$USB_DEV" mklabel gpt
  parted -s "$USB_DEV" mkpart ESP fat32 1MiB 513MiB
  parted -s "$USB_DEV" set 1 esp on
  parted -s "$USB_DEV" mkpart primary ext4 513MiB 100%

  echo ">>> Waiting for block devices..."
  udevadm settle
  sleep 3

  echo ">>> Formatting partitions..."
  mkfs.fat -F32 -n "EFI-BOOT" "$ESP_PART"
  mkfs.ext4 -F -L "DATA" "$DATA_PART"
else
  echo ">>> Skipping partitioning (using existing)..."
fi

# === Mount ===
echo ">>> Mounting partitions..."
mkdir -p "$MNT_ESP" "$MNT_DATA"
mount "$ESP_PART" "$MNT_ESP"
mount "$DATA_PART" "$MNT_DATA"

# === GRUB Installation (Standard Method) ===
echo ">>> Installing GRUB2 (Standard UEFI)..."

# using --removable creates EFI/BOOT/BOOTX64.EFI automatically
# using --boot-directory sets where the modules and grub.cfg go
grub2-install \
  --target=x86_64-efi \
  --efi-directory="$MNT_ESP" \
  --boot-directory="$MNT_ESP/boot" \
  --removable \
  --recheck \
  --force

echo " -> GRUB installed to $MNT_ESP/EFI/BOOT/BOOTX64.EFI"

# === ISO Copying & Info Extraction ===
echo ">>> Copying ISOs and extracting labels..."
mkdir -p "$MNT_DATA/isos"

MENU_ENTRIES=()
LOOP_COUNT=0

for iso_path in "${ISO_LIST[@]}"; do
  iso_name="$(basename "$iso_path")"
  target_iso="$MNT_DATA/isos/$iso_name"
  LOOP_DEV="loop${LOOP_COUNT}"
  ((LOOP_COUNT++))

  if [ ! -f "$target_iso" ] || [ $(stat -c%s "$iso_path") -ne $(stat -c%s "$target_iso") ]; then
      echo " -> Copying $iso_name..."
      cp "$iso_path" "$target_iso"
  else
      echo " -> Skipping $iso_name (already exists)"
  fi

  LABEL=""
  if command -v isoinfo &>/dev/null; then
      LABEL=$(isoinfo -d -i "$iso_path" | grep "Volume id:" | sed 's/Volume id: //')
  fi

  # We DO use a leading slash for paths inside the ISO now, standard practice.
  ENTRY="menuentry \"$iso_name\" {\n    set isofile=\"/isos/$iso_name\"\n    search --no-floppy --file --set=root \$isofile\n    loopback $LOOP_DEV \$isofile"

  if [[ "$iso_name" == *"Workstation"* || "$iso_name" == *"Live"* ]]; then
      # Fedora Workstation / Live
      BOOT_OPTS="root=live:CDLABEL=$LABEL rd.live.image iso-scan/filename=\$isofile quiet"
      if [ -z "$LABEL" ]; then BOOT_OPTS="rd.live.image iso-scan/filename=\$isofile"; fi
      ENTRY="$ENTRY\n    linuxefi ($LOOP_DEV)/images/pxeboot/vmlinuz $BOOT_OPTS\n    initrdefi ($LOOP_DEV)/images/pxeboot/initrd.img\n}"

  elif [[ "$iso_name" == *"Everything"* || "$iso_name" == *"netinst"* || "$iso_name" == *"Server"* ]]; then
       # Fedora Netinstall / Everything
       BOOT_OPTS="inst.stage2=hd:LABEL=$LABEL iso-scan/filename=\$isofile quiet"
       if [ -z "$LABEL" ]; then BOOT_OPTS="inst.repo=cdrom iso-scan/filename=\$isofile"; fi
       ENTRY="$ENTRY\n    linuxefi ($LOOP_DEV)/images/pxeboot/vmlinuz $BOOT_OPTS\n    initrdefi ($LOOP_DEV)/images/pxeboot/initrd.img\n}"
  else
       # Unknown
       ENTRY="$ENTRY\n    # UNSUPPORTED ISO TYPE\n}"
  fi

  MENU_ENTRIES+=("$ENTRY")
done
sync

# === Create grub.cfg (Dual Locations) ===
echo ">>> Generating grub.cfg..."

# We will create the config content once and write it to TWO locations
# to ensure GRUB finds it regardless of where it looks by default.

CFG_CONTENT=$(cat <<EOF
set timeout=30
set default=0

insmod all_video
insmod gfxterm
insmod loopback
insmod iso9660
insmod search_fs_uuid
insmod search_label

terminal_output gfxterm

menuentry "  --- Fedora Multi-Boot USB ---  " { true }

$(for entry in "${MENU_ENTRIES[@]}"; do echo -e "$entry\n"; done)

menuentry "---" { true }
menuentry "Reboot" { reboot }
menuentry "Shutdown" { halt }
EOF
)

# Location 1: Standard --boot-directory location
mkdir -p "$MNT_ESP/boot/grub"
echo "$CFG_CONTENT" > "$MNT_ESP/boot/grub/grub.cfg"

# Location 2: Fallback alongside BOOTX64.EFI
mkdir -p "$MNT_ESP/EFI/BOOT"
echo "$CFG_CONTENT" > "$MNT_ESP/EFI/BOOT/grub.cfg"

echo ">>> Success! USB is ready."
