#!/bin/bash
# Make a USB bootable with EFI + GRUB2 on Fedora
# WARNING: This will erase /dev/sdb. Change DEVICE if needed.

DEVICE="/dev/sda"
EFI_PART="${DEVICE}1"
DATA_PART="${DEVICE}2"
MOUNTPOINT_EFI="/tmp/usb-esp"
MOUNTPOINT_DATA="/tmp/usb-data"
SRC_ISO_PATH="."
BOOT_ISO_PATH="/isos"
BOOT_ISO="Fedora-Workstation-Live-43-1.6.x86_64.iso"
FORMAT_DATA=${FORMAT_DATA:-no}

set -e

echo ">>> Creating mountpoints..."
mkdir -p ${MOUNTPOINT_EFI} ${MOUNTPOINT_DATA}

echo ">>> Partitioning $DEVICE..."
sudo parted --script $DEVICE \
    mklabel gpt \
    mkpart EFI fat32 1MiB 300MiB \
    mkpart primary ext4 512MiB 100% \
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
cat << 'EOF' | sudo tee $MOUNTPOINT_EFI/boot/grub2/grub.cfg
set timeout=5
set default=0

menuentry "Boot Fedora ISO" {
    set root=(hd0,gpt2)
    set isofile="${BOOT_ISO_PATH}/${BOOT_ISO}"
    loopback loop (hd0,gpt2)$isofile
    linuxefi (loop)/isolinux/vmlinuz iso-scan/filename=$isofile root=live:CDLABEL=Fedora-Live rd.live.image
    initrdefi (loop)/isolinux/initrd.img    
}
EOF

# echo ">>> Creating GRUB config..."
# sudo mkdir -p $MOUNTPOINT_EFI/boot/grub2
# cat << 'EOF' | sudo tee $MOUNTPOINT_EFI/boot/grub2/grub.cfg
# set timeout=5
# set default=0

# menuentry "Boot Fedora ISO" {
#     set isofile="${BOOT_ISO_PATH}/${BOOT_ISO}"
#     loopback loop (hd0,2)$isofile
#     linux (loop)/isolinux/vmlinuz iso-scan/filename=$isofile root=live:CDLABEL=Fedora-Live
#     initrd (loop)/isolinux/initrd.img
# }
# EOF

if [[ "$FORMAT_DATA" == "yes" ]]; then
    echo ">>> Formatting DATA partition..."
    sudo mkfs.ext4 $DATA_PART

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

echo ">>> Done! Copy your Fedora ISO to /isos on the USB (second partition)."
echo ">>> Reboot and select the USB in UEFI boot menu."
echo ">>> To test: sudo qemu-system-x86_64 -enable-kvm -m 2G -bios /usr/share/edk2/ovmf/OVMF_CODE.fd -drive file=/dev/sda,format=raw,media=disk"

