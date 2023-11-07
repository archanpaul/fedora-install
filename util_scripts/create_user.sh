## Users
USER_NAME=arp
useradd -m $USER_NAME
passwd $USER_NAME
gpasswd -a $USER_NAME wheel
gpasswd -a $USER_NAME root
gpasswd -a $USER_NAME http
gpasswd -a $USER_NAME games
gpasswd -a $USER_NAME network
gpasswd -a $USER_NAME video
gpasswd -a $USER_NAME audio
gpasswd -a $USER_NAME optical
gpasswd -a $USER_NAME floppy
gpasswd -a $USER_NAME storage
gpasswd -a $USER_NAME scanner
gpasswd -a $USER_NAME power
gpasswd -a $USER_NAME users
gpasswd -a $USER_NAME kvm
gpasswd -a $USER_NAME adbusers
gpasswd -a $USER_NAME docker

echo "update sudo using: visudo"
