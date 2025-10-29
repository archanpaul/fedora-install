# Fedora Everything Netinstall
ARIA2C_DOWNLOADER="aria2c -c -s 16 -x 16 -k 1M -j 1 "
${ARIA2C_DOWNLOADER} https://download.fedoraproject.org/pub/fedora/linux/releases/43/Everything/x86_64/iso/Fedora-Everything-43-1.6-x86_64-CHECKSUM
${ARIA2C_DOWNLOADER} https://download.fedoraproject.org/pub/fedora/linux/releases/43/Everything/x86_64/iso/Fedora-Everything-netinst-x86_64-43-1.6.iso

