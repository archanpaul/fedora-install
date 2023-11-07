curl -O https://fedoraproject.org/fedora.gpg
gpgv --keyring ./fedora.gpg Fedora-Workstation-38-1.6-x86_64-CHECKSUM
sha256sum -c Fedora-Workstation-38-1.6-x86_64-CHECKSUM
