curl -O https://fedoraproject.org/fedora.gpg

gpgv --keyring ./fedora.gpg Fedora-Everything-40-1.14-x86_64-CHECKSUM
sha256sum -c Fedora-Everything-40-1.14-x86_64-CHECKSUM

gpgv --keyring ./fedora.gpg Fedora-Silverblue-40-1.14-x86_64-CHECKSUM
sha256sum -c Fedora-Silverblue-40-1.14-x86_64-CHECKSUM
