#!/bin/bash
# Make a USB bootable with EFI + GRUB2 on Fedora
# WARNING: This will erase /dev/sdb. Change DEVICE if needed.

# Default values
DEVICE="/dev/sda" # DANGEROUS DEFAULT, CHANGE THIS!
EFI_PART="${DEVICE}1"
DATA_PART="${DEVICE}2"
MOUNTPOINT_EFI="/tmp/usb-esp"
MOUNTPOINT_DATA="/tmp/usb-data"
BOOT_ISO_PATH="/isos"
BOOT_ISO="Fedora-Workstation-Live-43-1.6.x86_64.iso"
SRC_ISO_PATH="."
FORMAT_DATA=${FORMAT_DATA:-no}

# Parse command-line arguments
while getopts "d:i:s:f:" opt; do
    case $opt in
        d) DEVICE="$OPTARG" ;;
        i) BOOT_ISO="$OPTARG" ;;
        s) SRC_ISO_PATH="$OPTARG" ;;
        f) FORMAT_DATA="$OPTARG" ;;
        \?) echo "Invalid option -$OPTARG" >&2; exit 1 ;;
    esac
done

set -e

read -p "WARNING: This script will erase all data on $DEVICE. Are you absolutely sure you want to continue? (yes/no): " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
    echo "Aborting."
    exit 1
fi

echo ">>> Creating mountpoints..."
mkdir -p ${MOUNTPOINT_EFI} ${MOUNTPOINT_DATA}

echo ">>> Partitioning $DEVICE..."
sudo parted --script $DEVICE \
    mklabel gpt \
    mkpart EFI fat32 1MiB 300MiB \
    mkpart primary ext4 300MiB 100% \
    set 1 boot on

echo ">>> Formatting EFI partition..."
sudo mkfs.fat -F32 $EFI_PART

echo ">>> Mounting EFI partition..."
sudo mkdir -p $MOUNTPOINT_EFI
sudo mount $EFI_PART $MOUNTPOINT_EFI

echo ">>> Installing GRUB2 (UEFI x86_64)..."
sudo grub2-install \
    --target=x86_64-efi \
    --efi-directory=$MOUNTPOINT_EFI \
    --boot-directory=$MOUNTPOINT_EFI/boot \
    --removable --force

echo ">>> Creating GRUB config..."
sudo mkdir -p $MOUNTPOINT_EFI/boot/grub2

cat << EOF | sudo tee $MOUNTPOINT_EFI/boot/grub2/grub.cfg
set timeout=5
set default=0

menuentry "Boot Fedora ISO" {
    # This line IS expanded by the shell to set the correct ISO path
    set isofile="${BOOT_ISO_PATH}/${BOOT_ISO}"

    # Search for the partition labeled "FEDORA_DATA" and set it as \$root
    search --no-floppy --set=root --label FEDORA_DATA

    # We escape \$root and \$isofile so GRUB uses them, not the shell
    loopback loop (\$root)\$isofile

    linuxefi (loop)/boot/x86_64/loader/linux iso-scan/filename=\$isofile root=live:CDLABEL=Fedora-Live rd.live.image
    initrdefi (loop)/boot/x86_64/loader/initrd
}
EOF

if [[ "$FORMAT_DATA" == "yes" ]]; then
    echo ">>> Formatting DATA partition..."
    # Add the label FEDORA_DATA for the GRUB 'search' command
    sudo mkfs.ext4 -L FEDORA_DATA $DATA_PART

    echo ">>> Mounting DATA partition..."
    sudo mkdir -p $MOUNTPOINT_DATA
    sudo mount $DATA_PART $MOUNTPOINT_DATA

    echo ">>> Copying boot iso..."
    sudo mkdir -p ${MOUNTPOINT_DATA}/${BOOT_ISO_PATH}
    sudo cp -a ${SRC_ISO_PATH}/${BOOT_ISO} ${MOUNTPOINT_DATA}/${BOOT_ISO_PATH}/
else
    echo ">>> Skipping DATA partition formatting (set FORMAT_DATA=yes to enable)."
fi

echo ">>> Removing mountpoints..."
sudo sync
sudo umount -fq ${MOUNTPOINT_EFI}
if [[ "$FORMAT_DATA" == "yes" ]]; then
    sudo umount -fq ${MOUNTPOINT_DATA}
fi
rm -rf ${MOUNTPOINT_EFI} ${MOUNTPOINT_DATA}

echo ">>> Done! Your USB drive should be ready."
echo ">>> To test: sudo qemu-system-x86_64 -enable-kvm -m 2G -bios /usr/share/edk2/ovmf/OVVF_CODE.fd -drive file=${DEVICE},format=raw,media=disk"
