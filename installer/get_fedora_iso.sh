# Fedora Everything Netinstall
ARIA2C_DOWNLOADER="aria2c -c -s 16 -x 16 -k 1M -j 1 "
${ARIA2C_DOWNLOADER} https://repo.jing.rocks/fedora-buffet/fedora/linux/releases/41/Everything/x86_64/iso/Fedora-Everything-41-1.4-x86_64-CHECKSUM
${ARIA2C_DOWNLOADER} https://repo.jing.rocks/fedora-buffet/fedora/linux/releases/41/Everything/x86_64/iso/Fedora-Everything-netinst-x86_64-41-1.4.iso

# Fedora Workstation Live
${ARIA2C_DOWNLOADER} https://download.fedoraproject.org/pub/fedora/linux/releases/41/Workstation/x86_64/iso/Fedora-Workstation-41-1.4-x86_64-CHECKSUM
${ARIA2C_DOWNLOADER} https://download.fedoraproject.org/pub/fedora/linux/releases/41/Workstation/x86_64/iso/Fedora-Workstation-Live-x86_64-41-1.4.iso
