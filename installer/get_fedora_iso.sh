# Fedora Everything Netinstall
# ARIA2C_DOWNLOADER="aria2c -c -s 16 -x 16 -k 1M -j 1 "
WGET_DOWNLOADER="wget --show-progress -nc "
${WGET_DOWNLOADER} https://download.fedoraproject.org/pub/fedora/linux/releases/44/Everything/x86_64/iso/Fedora-Everything-44-1.7-x86_64-CHECKSUM
${WGET_DOWNLOADER} https://download.fedoraproject.org/pub/fedora/linux/releases/44/Everything/x86_64/iso/Fedora-Everything-netinst-x86_64-44-1.7.iso
${WGET_DOWNLOADER} https://dl.fedoraproject.org/pub/fedora/linux/releases/44/Workstation/x86_64/iso/Fedora-Workstation-44-1.7-x86_64-CHECKSUM
${WGET_DOWNLOADER} https://download.fedoraproject.org/pub/fedora/linux/releases/44/Workstation/x86_64/iso/Fedora-Workstation-Live-44-1.7.x86_64.iso
