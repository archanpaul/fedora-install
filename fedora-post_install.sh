CACHE=`pwd`/cache
HOSTNAME="arpo"

mkdir -p ${CACHE}

function update_hostname() {
    hostnamectl set-hostname --static ${HOSTNAME}
}

function dnf_conf_update() {
    cat <<EOF | sudo tee -a /etc/dnf/dnf.conf
keepcache=True
deltarpm=True
fastestmirror=True
max_parallel_downloads=20
EOF

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

function systool_packages() {
    sudo dnf -y install grubby
    sudo dnf -y install ecryptfs-utils

    sudo dnf -y install cronie
    sudo systemctl enable crond.service

    sudo dnf -y install nvme-cli

    sudo dnf -y install mc neovim
    sudo dnf -y install sysstat htop glances

    sudo dnf -y install mesa-vulkan-drivers vulkan-tools

    # sudo dnf -y install inxi
    # sudo inxi --admin --verbosity=7 --filter --no-host

    sudo dnf -y install unrar
}

function devtool_packages() {
    sudo dnf -y install autoconf automake make cmake patch pkgconf libtool
    sudo dnf -y install strace byacc elfutils ltrace strace valgrind

    sudo dnf -y install binutils bison flex gcc gcc-c++ gdb
    sudo dnf -y install clang clang-tools-extra clang-devel
    sudo dnf -y install llvm llvm-devel
    sudo dnf -y install gdisk

    sudo dnf -y install glibc-devel libstdc++-devel kernel-devel
    sudo dnf -y install protobuf protobuf-compiler protobuf-devel
    sudo dnf -y install boost-devel

    sudo dnf -y install git
}

function rpm_devtool_packages() {
    sudo dnf -y install fedora-packager fedora-review
}

function jdk_packages() {
    sudo dnf -y install java-latest-openjdk java-latest-openjdk-devel
}

function container_packages() {
    # sudo dnf -y install @virtualization

    sudo dnf -y install podman podman-compose podman-remote
    sudo dnf -y install podman-docker

    sudo dnf -y install virt-manager
}

function container_user_conf() {
    ## Fix podman-selinux permission issue for custom container storage folder.
    ## ref: https://access.redhat.com/solutions/7021610
    GRAPHROOT_PATH=`podman info | grep graphRoot | grep graphRoot: | awk '{print $2}'`
    if [ -n "${GRAPHROOT_PATH}" ]; then
    	sudo semanage fcontext -a -e /var/lib/containers ${GRAPHROOT_PATH}
	sudo restorecon -R -v ${GRAPHROOT_PATH}
    fi
}

function docker_packages() {
    sudo dnf -y install fuse-overlayfs iptables
    sudo rpm --import https://download.docker.com/linux/fedora/gpg
    sudo dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
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
    sudo dnf -y install opencv opencv-devel
}

function network_packages() {
    sudo dnf -y install iputils net-tools
    sudo dnf -y install nmap traceroute whois
    sudo dnf -y install wget aria2

    sudo dnf -y install openssh-server
    cat <<EOF | sudo tee /etc/ssh/sshd_config.d/60-login-opts.conf
#ChallengeResponseAuthentication no
#PasswordAuthentication no
#UsePAM no
#PermitRootLogin no
#PermitRootLogin prohibit-password
EOF
    # sudo systemctl restart sshd

    sudo dnf -y install yt-dlp
    # yt-dlp -f 'bestvideo[height<=1080]+bestaudio/best[height<=1080]' YT_PL_LINK

    # Tailscale VPN
    sudo dnf config-manager -y addrepo --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo
    sudo dnf -y install tailscale
    # sudo systemctl enable --now tailscaled
    # sudo tailscale up
}

function browser_packages() {
    sudo dnf -y install chromium thunderbird transmission

    sudo dnf -y install firefox
    sudo dnf -y install mozilla-noscript mozilla-ublock-origin

    ## Google Chrome
    sudo dnf config-manager setopt google-chrome.enabled=1
    sudo dnf check-update
    sudo dnf -y install google-chrome-stable
    sudo dnf -y install chrome-remote-desktop

    sudo dnf -y install torbrowser-launcher

    ## Microsoft Edge
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo dnf config-manager addrepo --from-repofile=https://packages.microsoft.com/yumrepos/edge/config.repo
    sudo dnf -y install microsoft-edge-stable
}

function ai_packages() {
    sudo dnf -y install ollama
    sudo npm install -g @google/gemini-cli
}

function ollama_user_conf() {
    ollama serve &
    ollama pull llama3.2:3b
    ollama pull codellama:7b
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

    # VSCode go plugin dependencies
    export GO111MODULE=on
    go install -v golang.org/x/tools/gopls@latest
    go install -v golang.org/x/lint/golint@latest
    go install -v golang.org/x/tools/cmd/goimports@latest
    go install -v github.com/go-delve/delve/cmd/dlv@latest

    # grpc protobuf
    go install -v google.golang.org/protobuf/cmd/protoc-gen-go@latest
    go install -v google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

    # gomobile
    go install -v golang.org/x/mobile/cmd/gobind@latest
    go install -v golang.org/x/mobile/cmd/gomobile@latest
}

function npm_packages() {
    sudo dnf -y install npm yarn
}

function vscode_package() {
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
    dnf check-update
    sudo dnf -y install code

    sudo echo "fs.inotify.max_user_watches=524288" | sudo tee -a /etc/sysctl.conf
    sudo sysctl -p
}

function git_user_conf() {
    # git config --global core.editor "code --wait"
    git config --global core.editor "nvim"

    # git config --global user.name "USER_NAME"
    # git config --global user.email "USER_EMAIL"
}

function vscode_package_user_conf() {
    ## vscode list/remove extensions
    # code --list-extensions | xargs -L 1 echo code --install-extension
    # code --list-extensions | xargs -L 1 code --uninstall-extension

    ## vscode extensions
    # code --install-extension continue.continue
    code --install-extension dart-code.dart-code
    code --install-extension dart-code.flutter
    code --install-extension github.github-vscode-theme
    code --install-extension golang.go
    code --install-extension google.geminicodeassist
    code --install-extension mhutchie.git-graph
    code --install-extension ms-azuretools.vscode-containers
    code --install-extension ms-python.black-formatter
    code --install-extension ms-python.debugpy
    code --install-extension ms-python.isort
    code --install-extension ms-python.python
    code --install-extension ms-python.vscode-pylance
    code --install-extension ms-toolsai.datawrangler
    code --install-extension ms-toolsai.jupyter
    code --install-extension ms-toolsai.jupyter-keymap
    code --install-extension ms-toolsai.jupyter-renderers
    code --install-extension ms-toolsai.vscode-jupyter-cell-tags
    code --install-extension ms-toolsai.vscode-jupyter-slideshow
    code --install-extension ms-vscode-remote.remote-containers
    # code --install-extension ms-vscode.cpptools
    # code --install-extension ms-vscode.live-server
    # code --install-extension ms-vscode.makefile-tools
    code --install-extension ms-vscode.remote-explorer
    # code --install-extension redhat.vscode-yaml
}

function android-studio_package(){
    ANDROID_STUDIO_RELEASE=2025.1.1.14

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
Exec=env _JAVA_OPTIONS=-Djava.io.tmpdir=/var/tmp /opt/android-studio/bin/studio
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

function flutter-sdk_package() {
    #sudo dnf -y install libstdc++.i686

    FLUTTER_VERSION="3.32.6-stable"

    wget -c https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}.tar.xz -P ${CACHE}
    sudo rm -rf /opt/flutter-sdk
    sudo mkdir -p /opt/flutter-sdk

    sudo tar -xf ${CACHE}/flutter_linux_${FLUTTER_VERSION}.tar.xz -C /opt/flutter-sdk/
    # sudo git clone -b main https://github.com/flutter/flutter.git /opt/flutter-sdk/ --depth=1

    sudo mkdir /opt/flutter-sdk/pub_cache
    sudo chown -R root:wheel /opt/flutter-sdk
    sudo chmod -R u+rwX,go+rwX,o-w /opt/flutter-sdk

    cat <<EOF | sudo tee /etc/profile.d/flutter-sdk.sh
export FLUTTER_ROOT=/opt/flutter-sdk/flutter
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
    git config --global --add safe.directory /opt/flutter-sdk/flutter

    flutter upgrade --force

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
    sudo dnf -y install python3-virtualenv conda
    sudo dnf -y install python3-pylint python3-autopep8
    sudo dnf -y install python3-numpy python3-scipy python3-pandas
    sudo dnf -y install python3-matplotlib
    sudo dnf -y install python3-opencv
    sudo dnf -y install python3-sqlalchemy
    sudo dnf -y install python3-scikit-learn
    sudo dnf -y install python3-ipykernel python3-ipywidgets python3-notebook
    sudo dnf -y install python3-torch python3-torchdata python3-torchvision python3-torchaudio python3-torchtext
}

function python_virtualenv_packages() {
    PYTHON_VERSION=3.13
    VENV=pyvenv_313
    VENV_FOLDER=/opt/python_venv/${VENV}

    ## virtualenvs
    sudo rm -rf ${VENV_FOLDER}
    sudo mkdir -p ${VENV_FOLDER}
    sudo chown -R root:wheel ${VENV_FOLDER}
    sudo chmod -R u+rwX,go+rwX,o-w ${VENV_FOLDER}

    /usr/bin/python${PYTHON_VERSION} -m venv --system-site-packages --symlinks ${VENV_FOLDER}

    set -e
    source ${VENV_FOLDER}/bin/activate && \
    pip install --upgrade pip && \
    pip install black && \
    pip install "transformers[torch]" && \
    deactivate
}

function python_user_conf() {
    VENV=pyvenv_313
    VENV_FOLDER=/opt/python_venv/${VENV}

    mkdir -p ~/.virtualenvs
    ln -sfn ${VENV_FOLDER} ~/.virtualenvs/${VENV}
    ln -sfn ~/.virtualenvs/${VENV} ~/.venv
}

function gnome_packages() {
    sudo dnf -y install gnome-tweaks
    sudo dnf -y install foliate
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

    sudo dnf -y install NetworkManager-ssh-gnome NetworkManager-openconnect-gnome
    sudo dnf -y install NetworkManager-pptp-gnome NetworkManager-vpnc-gnome NetworkManager-openvpn-gnome

    sudo dnf -y install gnome-shell-theme-yaru gnome-shell-theme-flat-remix

    # sudo dnf -y install calibre
}

function markdown_packages() {
    sudo dnf -y install flatpak
    # flatpak install app/md.obsidian.Obsidian/x86_64/stable
    # sudo flatpak override md.obsidian.Obsidian --filesystem=host

    sudo dnf -y install pandoc pandoc-pdf texlive-mdwtools
    # Convert epub to html
    # pandoc FILENAME.epub --webtex -f epub -t html --embed-resources --standalone -o FILENAME.html
    # Remove all href from generated html
    # sed -i 's|<a[^>]\+>|<a>|g' FILENAME.html
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
    sudo dnf -y install google-go-mono-fonts
    sudo dnf -y install google-go-smallcaps-fonts
    sudo dnf -y install google-tinos-fonts
    sudo dnf -y install mozilla-fira-sans-fonts
    sudo dnf -y install mozilla-fira-mono-fonts
    sudo dnf -y install fira-code-fonts
    sudo dnf -y install jetbrains-mono-fonts-all
    sudo dnf -y install ht-alegreya-fonts
    sudo dnf -y install ht-alegreya-sans-fonts
    sudo dnf -y install liberation-fonts
    sudo dnf -y install vernnobile-nunito-fonts
    sudo dnf -y install vernnobile-oswald-fonts
    sudo dnf -y install vernnobile-muli-fonts
    sudo dnf -y install typetogether-literata-fonts
    sudo dnf -y install gfs-baskerville
    sudo dnf -y install sorkintype-merriweather-fonts

}

function libreoffice_packages() {
    sudo dnf -y install libreoffice-writer
    sudo dnf -y install libreoffice-calc
    sudo dnf -y install libreoffice-impress
    sudo dnf -y install libreoffice-draw
    sudo dnf -y install libreoffice-math
}

function codec_packages() {
    sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1
    sudo dnf -y install openh264
    sudo dnf -y install gstreamer1-plugin-openh264 mozilla-openh264 gstreamer1-libav
}

function database_packages() {
   sudo dnf -y install postgresql postgresql-server
   sudo dnf -y install mariadb mariadb-server
}

function amd_packages() {
    sudo dnf -y install rocminfo rocm-clinfo
    sudo dnf -y install miopen
    sudo dnf -y install rocm-cmake rocm-device-libs rocm-compilersupport-macros
    sudo dnf -y install rocm-comgr rocm-comgr-devel
    sudo dnf -y install rocm-core rocm-core-devel
    sudo dnf -y install rocm-hip rocm-hip-devel
    sudo dnf -y install rocm-opencl rocm-opencl-devel
    sudo dnf -y install rocm-runtime rocm-runtime-devel
    sudo dnf -y install rocm-smi rocm-smi-devel
    sudo dnf -y install hipblas hipfft hipsolver hipsparse
    sudo dnf -y install rocalution rocblas rocfft rocrand rocsolver rocsparse roctracer
    sudo dnf -y install rocprim-devel

    sudo dnf -y install radeontop
    sudo dnf -y install sevctl snphost
}

function intel_packages() {
    # ref: https://www.intel.com/content/www/us/en/developer/tools/oneapi/base-toolkit-download.html?packages=cpp-essentials&cpp-essentials-os=linux&cpp-essentials-lin=yum-dnf

        cat <<EOF | sudo tee /etc/yum.repos.d/intel_one_api.repo
[oneAPI]
name=Intel® oneAPI repository
baseurl=https://yum.repos.intel.com/oneapi
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://yum.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
EOF

    sudo dnf -y install intel-oneapi-base-toolkit
    sudo dnf -y install intel-deep-learning-essentials
    sudo dnf -y install install intel-cpp-essentials
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
   sudo dnf -y install rclone
}

function httpd_service() {
        sudo mkdir -p /home/public
        sudo chmod 775 /home/public
        sudo ln -s /home/public /var/www/html/public
        sudo chcon -R --reference=/var/www/html /home/public
        sudo systemctl disable httpd
        # sudo systemctl restart httpd
}

function thinkpad_packages() {
    sudo dnf -y install tlp tlp-rdw
    # edit /etc/tlp.conf along with powertop
    sudo systemctl enable tlp.service --now

    # thinkbook power-management
    # sudo tlp-stat -b
    ## Thinkpad battery charge threhold start 75% end 80%
    # sudo tlp setcharge 75 80
    ## set thinkbook battery charge threshold to 80% persistent
    # sudo tlp setcharge 80 1

    # Auto decrypt luks using TPM2
    sudo dnf -y install systemd-udev dracut
    # sudo systemd-cryptenroll --wipe-slot tpm2 --tpm2-device auto --tpm2-pcrs "1+3+5+7+11+12+14+15" /dev/nvme1n1p3
    # sudo dracut -f
}

function security_packages() {
    sudo dnf -y install firewalld

    sudo dnf -y install aide
    #sudo aide --init
    #sudo aide --update
    #sudo mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
    #sudo aide --check

    ## /etc/crontab
    ## 05 4 * * * root /usr/sbin/aide --check
}

function firewall_services() {
    sudo systemctl enable firewalld
    sudo systemctl restart firewalld
}

function firewall_user_services() {
    sudo firewall-cmd --set-default-zone=public
    sudo firewall-cmd --get-active-zones

    sudo firewall-cmd --add-service=http --zone=public
    sudo firewall-cmd --add-service=https --zone=public
    sudo firewall-cmd --add-port=8080/tcp --zone=public
    sudo firewall-cmd --add-interface=tailscale0 --zone=public

    sudo firewall-cmd --list-all --zone=public

    sudo firewall-cmd --runtime-to-permanent

    sudo firewall-cmd --reload
    sudo systemctl enable firewalld
    sudo systemctl restart firewalld
}

function misc_services() {
    # disabled (un-necessary for personal workstation?)
    sudo systemctl disable --now sysstat
}

function laptop_mode() {
    sudo dnf -y install powertop
    ##
    # sudo systemctl edit powertop.service
    ## Add following to drop-in section
    # [Service]
    # ExecStartPost=/bin/bash -c 'echo on > /sys/bus/usb/devices/3-2/power/control'
    ##
    # sudo systemctl daemon-reload
    # sudo systemctl --now enable powertop
}

function install_all_modules() {
    echo "install_all_modules"

    # update_hostname
    # dnf_conf_update
    fedora_upgrade
    # rpmfusion_repo

    # systool_packages
    # devtool_packages
    # rpm_devtool_packages
    # jdk_packages
    # container_packages
    # kubernetes_packages
    # graphics_packages
    # graphics_dev_packages
    # network_packages
    # browser_packages
    # python_packages
    # gnome_packages
    # vscode_package
    # go_packages
    # npm_packages
    # ai_packages
    # font_packages
    # codec_packages
    # libreoffice_packages
    # database_packages
    # cloud_tools_packages
    # security_packages
    # markdown_packages

    # laptop_mode
    # thinkpad_packages

    # intel_packages
    # amd_packages

    # httpd_service
    # firewall_services
    # firewall_user_services
    # misc_services

    # android-studio_package
    # flutter-sdk_package

    # go_extra_packages
    # python_virtualenv_packages
}

function install_all_user_modules() {
    echo "install_all_user_modules"

    # git_user_conf
    # vscode_package_user_conf
    # flutter-sdk_user_conf
    # python_user_conf
    # container_user_conf
    # ollama_user_conf
}

install_all_modules 2>&1 | tee fedora_install.log
install_all_user_modules 2>&1 | tee -a fedora_install.log

grep err fedora_install.log
