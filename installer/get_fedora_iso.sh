# Fedora Everything Netinstall
ARIA2C_DOWNLOADER="aria2c -c -s 16 -x 16 -k 1M -j 1 "
${ARIA2C_DOWNLOADER} https://download.fedoraproject.org/pub/fedora/linux/releases/42/Everything/x86_64/iso/Fedora-Everything-42-1.1-x86_64-CHECKSUM
${ARIA2C_DOWNLOADER} https://download.fedoraproject.org/pub/fedora/linux/releases/42/Everything/x86_64/iso/Fedora-Everything-netinst-x86_64-42-1.1.iso

# Fedora Workstation Live
${ARIA2C_DOWNLOADER} https://download.fedoraproject.org/pub/fedora/linux/releases/42/Workstation/x86_64/iso/Fedora-Workstation-42-1.1-x86_64-CHECKSUM
${ARIA2C_DOWNLOADER} https://download.fedoraproject.org/pub/fedora/linux/releases/42/Workstation/x86_64/iso/Fedora-Workstation-Live-42-1.1.x86_64.iso
