curl -O https://fedoraproject.org/fedora.gpg
gpgv --keyring ./fedora.gpg Fedora-Everything-43-1.6-x86_64-CHECKSUM
sha256sum --ignore-missing -c Fedora-Everything-43-1.6-x86_64-CHECKSUM
