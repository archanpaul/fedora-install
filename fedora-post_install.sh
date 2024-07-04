CACHE=`pwd`/cache
HOSTNAME="arpo"

mkdir -p ${CACHE}

function update_hostname() {
    hostnamectl set-hostname --static ${HOSTNAME}
}

function dnf_conf_update() {
    sudo echo 'keepcache=True' | sudo tee -a /etc/dnf/dnf.conf
    sudo echo 'deltarpm=True' | sudo tee -a /etc/dnf/dnf.conf
    sudo echo 'fastestmirror=True' | sudo tee -a /etc/dnf/dnf.conf
    sudo echo 'max_parallel_downloads=20' | sudo tee -a /etc/dnf/dnf.conf
    sudo dnf -y install fedora-workstation-repositories
    sudo dnf -y install dnf-plugins-core
}

function fedora_upgrade() {
    sudo dnf -y upgrade --downloadonly
    sudo dnf -y upgrade
}

function rpmfusion_repo() {
    sudo dnf -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
}

function systools_package() {
    sudo dnf -y install grubby
    sudo dnf -y install ecryptfs-utils

    sudo dnf -y install cronie
    sudo systemctl enable crond.service

    sudo dnf -y install nvme-cli

    sudo dnf -y install mc vim
    sudo dnf -y install sysstat htop glances
    sudo dnf -y install nmap traceroute
    sudo dnf -y install wget aria2

    sudo dnf -y install mesa-vulkan-drivers vulkan-tools

    # sudo dnf -y install inxi
    # sudo inxi --admin --verbosity=7 --filter --no-host

    sudo dnf -y install unrar
}

function devtools_package() {
    sudo dnf -y install autoconf automake make cmake patch pkgconf libtool
    sudo dnf -y install strace byacc elfutils ltrace strace valgrind

    sudo dnf -y install binutils bison flex gcc gcc-c++ gdb
    sudo dnf -y install clang clang-tools-extra clang-devel
    sudo dnf -y install llvm llvm-devel

    sudo dnf -y install glibc-devel libstdc++-devel kernel-devel
    sudo dnf -y install protobuf protobuf-compiler protobuf-devel
    sudo dnf -y install boost-devel

    sudo dnf -y install git
}

function rpm_devtools_package() {
    sudo dnf -y install fedora-packager fedora-review
}

function jdk_package() {
    sudo dnf -y install java-latest-openjdk java-latest-openjdk-devel
}

function container_package() {
    # sudo dnf -y install @virtualization
    sudo dnf -y install podman podman-compose
    sudo dnf -y install podman-plugins

    sudo dnf -y install virt-manager
}

function docker_packages() {
    sudo dnf -y install fuse-overlayfs iptables
    sudo rpm --import https://download.docker.com/linux/fedora/gpg
    sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    sudo dnf -y remove docker \
        docker-client \
        docker-client-latest \
        docker-common \
        docker-latest \
        docker-latest-logrotate \
        docker-logrotate \
        docker-selinux \
        docker-engine-selinux \
        docker-engine
    sudo dnf -y install docker-ce docker-ce-cli docker-ce-rootless-extras containerd.io
    sudo dnf -y install docker-compose
    sudo usermod -a -G docker $(whoami)
    newgrp docker

    ## for dockerd-rootless-setuptool
    # sudo systemctl disable --now docker.service docker.socket
    # dockerd-rootless-setuptool.sh install

    ## update vim ~/.bashrc
    # echo 'export PATH=/usr/bin:\$PATH' | sudo tee -a ~/.bashrc
    # echo 'export DOCKER_HOST=unix:///run/user/1000/docker.sock' | sudo tee -a ~/.bashrc

    # systemctl --user start docker
    # sudo loginctl enable-linger $(whoami)
}

function kubernetes_packages() {
    sudo dnf -y install kubernetes
}

function graphics_packages() {
    sudo dnf -y install gimp inkscape
    sudo dnf -y install blender
}

function graphics_dev_packages() {
    sudo dnf -y install gtk4-devel
    sudo dnf -y install opencv opencv-contrib opencv-devel
}

function internet_package() {
    sudo dnf -y install chromium thunderbird transmission
    sudo dnf -y install yt-dlp

    sudo dnf -y install firefox
    sudo dnf -y install firefox-wayland
    sudo dnf -y install mozilla-noscript mozilla-ublock-origin

    ## Google Chrome
    sudo dnf config-manager --set-enabled google-chrome
    sudo dnf check-update
    sudo dnf -y install google-chrome-stable
    sudo dnf -y install chrome-remote-desktop

    sudo dnf -y install torbrowser-launcher

    ## Microsoft Edge
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo dnf config-manager --add-repo https://packages.microsoft.com/yumrepos/edge
    sudo dnf -y install microsoft-edge-stable
}

function swift_packages() {
    sudo dnf -y install swift-lang
}

function go_packages() {
    sudo dnf -y install golang

    sudo rm -rf /opt/go-packages
    sudo mkdir /opt/go-packages

    sudo chown -R root:wheel /opt/go-packages
    sudo chmod -R u+rwX,go+rwX,o-w /opt/go-packages

        cat <<EOF | sudo tee /etc/profile.d/go-packages.sh
export GOPATH=/opt/go-packages
export PATH=\$PATH:\$GOPATH/bin
EOF
    source /etc/profile.d/go-packages.sh
}

function go_extra_packages() {
    source /etc/profile.d/go-packages.sh

    ## VSCode go plugin dependencies
    export GO111MODULE=on
    go install -v golang.org/x/tools/gopls@latest
    go install -v github.com/ramya-rao-a/go-outline@latest
    go install -v golang.org/x/lint/golint@latest
    go install -v golang.org/x/tools/cmd/goimports@latest
    go install -v honnef.co/go/tools/cmd/staticcheck@latest
    go install -v github.com/go-delve/delve/cmd/dlv@latest

    ## Dev
    # grpc protobuf
    go install -v google.golang.org/protobuf/cmd/protoc-gen-go@latest
    go install -v google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
    # entgo
    go install entgo.io/ent/cmd/ent@latest
    go install entgo.io/contrib/entproto/cmd/protoc-gen-entgrpc@latest
    go install ariga.io/atlas/cmd/atlas@latest

    ## Dev tools
    # go install -v github.com/cespare/reflex@latest
    go install -v github.com/cosmtrek/air@latest
    # gomobile
    go install -v golang.org/x/mobile/cmd/gobind@latest
    go install -v golang.org/x/mobile/cmd/gomobile@latest
}

function npm_packages() {
    sudo dnf -y install npm
}

function vscode_package() {
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
    dnf check-update
    sudo dnf -y install code
    sudo dnf -y install pandoc

    sudo echo "fs.inotify.max_user_watches=524288" | sudo tee -a /etc/sysctl.conf
    sudo sysctl -p
}

function vscode_package_user_conf() {
    ## vscode list/remove extensions
    # code --list-extensions | xargs -L 1 echo code --install-extension
    # code --list-extensions | xargs -L 1 code --uninstall-extension

    ## vscode extensions
    code --install-extension Dart-Code.dart-code
    code --install-extension Dart-Code.flutter
    code --install-extension GitHub.github-vscode-theme
    code --install-extension golang.go
    code --install-extension ms-python.autopep8
    code --install-extension ms-python.isort
    code --install-extension ms-python.python
    code --install-extension ms-python.vscode-pylance
    code --install-extension ms-toolsai.jupyter
    code --install-extension ms-toolsai.jupyter-keymap
    code --install-extension ms-toolsai.jupyter-renderers
    code --install-extension ms-toolsai.vscode-jupyter-cell-tags
    code --install-extension ms-toolsai.vscode-jupyter-slideshow
    code --install-extension ms-vscode-remote.remote-containers
    code --install-extension redhat.vscode-yaml

}

function android-studio_package(){
    ANDROID_STUDIO_RELEASE=2024.1.1.11

    sudo rm -rf /opt/android-studio
    sudo  mkdir -p /opt/android-studio

    wget -c https://redirector.gvt1.com/edgedl/android/studio/ide-zips/${ANDROID_STUDIO_RELEASE}/android-studio-${ANDROID_STUDIO_RELEASE}-linux.tar.gz -P ${CACHE}

    sudo tar zxfv ${CACHE}/android-studio-${ANDROID_STUDIO_RELEASE}-linux.tar.gz -C /opt/
    sudo chown -R root:wheel /opt/android-studio
    sudo chmod -R u+rwX,go+rwX,o-w /opt/android-studio

    cat <<EOF | sudo tee /opt/android-studio/android-studio.desktop
[Desktop Entry]
Type=Application
Name=Android Studio
Icon=/opt/android-studio/bin/studio.png
Exec=env _JAVA_OPTIONS=-Djava.io.tmpdir=/var/tmp /opt/android-studio/bin/studio.sh
Terminal=false
Categories=Development;IDE;
EOF

    sudo mkdir -p /opt/android-sdk
    sudo chown -R root:wheel /opt/android-sdk
    sudo chmod -R u+rwX,go+rwX,o-w /opt/android-sdk

    cat <<EOF | sudo tee /etc/profile.d/android-sdk.sh
export ANDROID_HOME=/opt/android-sdk/
export ANDROID_SDK_ROOT=\$ANDROID_HOME
export ANDROID_NDK_ROOT=\$ANDROID_HOME/ndk/21.1.6352462
export ANDROID_NDK_HOME=\$ANDROID_NDK_ROOT
export PATH=\$PATH:\$ANDROID_HOME/platform-tools/
EOF

    sudo cp /opt/android-studio/android-studio.desktop /usr/share/applications/android-studio.desktop
    source /etc/profile.d/android-sdk.sh

    sudo dnf -y copr enable zeno/scrcpy
    # rpmfusion_repo
    # sudo dnf -y --allowerasing install ffmpeg-free
    sudo dnf -y install scrcpy
    # remove android-tools to use SDK's tools
    sudo rpm -e android-tools --nodeps
}

function dart-sdk_package() {
    DART_VERSION="3.4.4"

    sudo rm -rf ${CACHE}/dartsdk-linux-x64-release.zip
    wget -c https://storage.googleapis.com/dart-archive/channels/stable/release/${DART_VERSION}/sdk/dartsdk-linux-x64-release.zip -P ${CACHE}
    sudo rm -rf /opt/dart-sdk

    sudo unzip ${CACHE}/dartsdk-linux-x64-release.zip -d /opt/
    sudo mkdir /opt/dart-sdk/pub_cache
    sudo chown -R root:wheel /opt/dart-sdk
    sudo chmod -R u+rwX,go+rwX,o-w /opt/dart-sdk

    cat <<EOF | sudo tee /etc/profile.d/dart-sdk.sh
#export PUB_CACHE=/opt/dart-sdk/pub_cache
#export PATH=\$PATH:/opt/dart-sdk/bin
EOF
    source /etc/profile.d/dart-sdk.sh
    #dart pub global activate protoc_plugin
}

function flutter-sdk_package() {
    #sudo dnf -y install libstdc++.i686

    sudo rm -rf /opt/flutter-sdk
    sudo mkdir -p /opt/flutter-sdk

    sudo git clone -b stable --single-branch https://github.com/flutter/flutter.git /opt/flutter-sdk --depth=1
    # sudo git clone -b master https://github.com/flutter/flutter.git /opt/flutter-sdk

    sudo mkdir /opt/flutter-sdk/pub_cache
    sudo chown -R root:wheel /opt/flutter-sdk
    sudo chmod -R u+rwX,go+rwX,o-w /opt/flutter-sdk

    cat <<EOF | sudo tee /etc/profile.d/flutter-sdk.sh
export FLUTTER_ROOT=/opt/flutter-sdk/
export PUB_CACHE=\$FLUTTER_ROOT/pub_cache
export ENABLE_FLUTTER_DESKTOP=true
export PATH=\$PATH:\$FLUTTER_ROOT/bin:\$PUB_CACHE/bin
EOF
    source /etc/profile.d/flutter-sdk.sh

    ## Linux app development dependencies.
    sudo dnf -y install ninja-build
    sudo dnf -y install gtk3-devel
}

function flutter-sdk_user_conf() {
    git config --global --add safe.directory /opt/flutter-sdk
    flutter doctor
    flutter doctor --android-licenses
    flutter config --no-analytics
    flutter precache
    flutter config --enable-linux-desktop
    flutter config --enable-windows-desktop
    flutter config --enable-macos-desktop
    dart --disable-analytics
    dart pub global activate protoc_plugin
}

function python_packages() {
    sudo dnf -y install python3-virtualenv
    sudo dnf -y install python3-pylint python3-autopep8
    sudo dnf -y install python3-numpy python3-scipy python3-pandas
    sudo dnf -y install python3-matplotlib
    sudo dnf -y install python3-ipykernel python3-notebook
    sudo dnf -y install python3-virtualenv
    sudo dnf -y install python3-opencv
    
    sudo dnf -y install python3.11
}

function python_user_conf() {
    ## virtualenv
    mkdir ~/.virtualenvs
    virtualenv -p /usr/bin/python3.12 --copies ~/.virtualenvs/venv_py312
    source ~/.virtualenvs/venv_py312/bin/activate
    pip install --upgrade pip
    pip3 install ipykernel autopep8 pylint black
    pip3 install numpy scipy matplotlib pandas
    pip3 install opencv-python
    pip3 install keras tensorflow
    pip3 install mediapipe
    pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
}

function gnome_packages() {
    sudo dnf -y install gnome-tweaks
    sudo dnf -y install foliate
    sudo dnf -y install shotwell
    sudo dnf -y install gnome-boxes
    sudo dnf -y install gnome-sound-recorder
    sudo dnf -y install evince xournalpp
    sudo dnf -y install gnome-firmware
    sudo dnf -y install dconf-editor

    sudo dnf -y install gnome-extensions-app
    sudo dnf -y install gnome-shell-extension-dash-to-dock
    sudo dnf -y install gnome-shell-extension-gsconnect
    sudo dnf -y install gnome-shell-extension-screenshot-window-sizer
    sudo dnf -y install gnome-shell-extension-dash-to-panel.noarch

    sudo dnf -y install gtk-v4l
    # sudo dnf -y install vlc
    # sudo dnf -y install celluloid

    sudo dnf -y install --allowerasing obs-studio
    sudo dnf -y install --allowerasing x264 obs-studio-plugin-x264
}

function font_packages() {
    sudo dnf -y install google-roboto-fonts
    sudo dnf -y install google-roboto-mono-fonts
    sudo dnf -y install google-roboto-slab-fonts
    sudo dnf -y install google-roboto-condensed-fonts
    sudo dnf -y install google-arimo-fonts
    sudo dnf -y install google-cousine-fonts
    sudo dnf -y install google-carlito-fonts
    sudo dnf -y install google-arimo-fonts
    sudo dnf -y install google-go-fonts
    sudo dnf -y install google-go-mono--fonts
    sudo dnf -y install google-go-smallcaps-fonts
    sudo dnf -y install google-tinos-fonts
    sudo dnf -y install mozilla-fira-sans-fonts
    sudo dnf -y install mozilla-fira-mono-fonts
    sudo dnf -y install fira-code-fonts
    sudo dnf -y install jetbrains-mono-fonts-all
    sudo dnf -y install ht-alegreya-fonts
    sudo dnf -y install ht-alegreya-sans-fonts
}

function libreoffice_packages() {
    sudo dnf -y install libreoffice-writer
    sudo dnf -y install libreoffice-calc
    sudo dnf -y install libreoffice-impress
    sudo dnf -y install libreoffice-draw
    sudo dnf -y install libreoffice-math
}

function codec_packages() {
    sudo dnf config-manager --set-enabled fedora-cisco-openh264
    sudo dnf -y install openh264
    sudo dnf -y install gstreamer1-plugin-openh264 mozilla-openh264 gstreamer1-libav
}

function cloud_tools_packages() {
    #gcloud_package() {
    cat <<EOF | sudo tee /etc/yum.repos.d/google-cloud-sdk.repo
[google-cloud-sdk]
name=Google Cloud SDK
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el8-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

   sudo dnf -y install libxcrypt-compat.x86_64
   sudo dnf -y install google-cloud-sdk
}

function database_packages() {
   sudo dnf -y install postgresql postgresql-server
   sudo dnf -y install mariadb mariadb-server
}

function embedded_dev() {
    sudo dnf -y install arm-none-eabi-binutils-cs arm-none-eabi-gcc-cs arm-none-eabi-gcc-cs-c++
    sudo dnf -y install arm-none-eabi-newlib
}

function httpd_service() {
        sudo mkdir -p /home/public
        sudo chmod 775 /home/public
        sudo ln -s /home/public /var/www/html/public
        sudo chcon -R --reference=/var/www/html /home/public
        sudo systemctl enable httpd
        sudo systemctl restart httpd
}

function security_service() {
    sudo dnf -y install firewalld ufw

    sudo firewall-cmd --add-port=80/tcp --permanent
    sudo firewall-cmd --add-port=8080/tcp --permanent
    sudo firewall-cmd --reload

    sudo systemctl enable firewalld
    sudo systemctl restart firewalld

    sudo dnf -y install aide
    #sudo aide --init
    #sudo aide --update
    #sudo mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
    #sudo aide --check

    ## /etc/crontab
    ## 05 4 * * * root /usr/sbin/aide --check
}

function misc_services() {
    # disabled (un-necessary for personal workstation?)
    sudo systemctl disable --now sysstat

    # thinkbook power-management
    sudo dnf -y install tlp tlp-rdw
    # tlp-stat -b
    # sudo tlp setcharge 80 1
    # sudo tlp-stat -b
}

function install_all_modules() {
	# update_hostname
	# dnf_conf_update
	 fedora_upgrade
	# rpmfusion_repo

	# systools_package
	# devtools_package
	# rpm_devtools_package
	# jdk_package
	# container_package
	# kubernetes_packages
	# graphics_packages
        # graphics_dev_packages
	# internet_package
	# python_packages
	# gnome_packages
	# vscode_package
	# swift_packages
	# go_packages
	# npm_packages
	# font_packages
	# codec_packages
	# libreoffice_packages
	# embedded_dev
	# database_packages

	# httpd_service
	# security_service
	# misc_services

	# android-studio_package
	# dart-sdk_package
	# flutter-sdk_package
}

function user_conf_all_modules(){
	vscode_package_user_conf
	flutter-sdk_user_conf
	# go_extra_packages
        # python_user_conf
} 

install_all_modules 2>&1 | tee fedora_install.log
# user_conf_all_modules
