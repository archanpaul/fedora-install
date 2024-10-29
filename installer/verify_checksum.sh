# curl -O https://fedoraproject.org/fedora.gpg

gpgv --keyring ./fedora.gpg Fedora-Everything-41-1.4-x86_64-CHECKSUM
sha256sum -c Fedora-Everything-41-1.4-x86_64-CHECKSUM

#gpgv --keyring ./fedora.gpg Fedora-Workstation-41-1.4-x86_64-CHECKSUM
#sha256sum -c Fedora-Workstation-41-1.4-x86_64-CHECKSUM
