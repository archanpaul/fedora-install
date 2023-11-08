# curl -O https://fedoraproject.org/fedora.gpg
gpgv --keyring ./fedora.gpg Fedora-Everything-39-1.5-x86_64-CHECKSUM
sha256sum -c Fedora-Everything-39-1.5-x86_64-CHECKSUM
