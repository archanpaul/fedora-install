# curl -O https://fedoraproject.org/fedora.gpg

gpgv --keyring ./fedora.gpg Fedora-Everything-42-1.1-x86_64-CHECKSUM
sha256sum -c Fedora-Everything-42-1.1-x86_64-CHECKSUM

#gpgv --keyring ./fedora.gpg Fedora-Workstation-42-1.1-x86_64-CHECKSUM
#sha256sum -c Fedora-Workstation-42-1.1-x86_64-CHECKSUM



