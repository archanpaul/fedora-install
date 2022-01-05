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

    sudo dnf -y install mc vim
    sudo dnf -y install sysstat htop glances
    sudo dnf -y install nmap traceroute
    sudo dnf -y install wget aria2

    sudo dnf -y install mesa-vulkan-drivers vulkan-tools

    # sudo dnf -y install inxi
    # sudo inxi --admin --verbosity=7 --filter --no-host

    sudo dnf -y install dnf-plugins-core

    sudo dnf -y install unrar
}

function devtools_package() {
    sudo dnf -y install autoconf automake make cmake patch pkgconf libtool
    sudo dnf -y install strace byacc elfutils ltrace strace valgrind 

    sudo dnf -y install binutils bison flex gcc gcc-c++ gdb
    sudo dnf -y install clang clang-tools-extra

    sudo dnf -y install glibc-devel libstdc++-devel kernel-devel
    sudo dnf -y install protobuf protobuf-compiler protobuf-devel

    sudo dnf -y install git
}

function rpm_devtools_package() {
    sudo dnf -y install fedora-packager fedora-review
}

function jdk_package() {
    sudo dnf -y install java-latest-openjdk java-latest-openjdk-devel
}

function container_package() {
    sudo dnf -y install @virtualization
    sudo dnf -y install podman podman-compose
    sudo dnf -y install slirp4netns buildah skopeo runc
    sudo dnf -y install toolbox

    sudo dnf -y install libvirt-devel
    # sudo systemctl enable libvirtd
    # sudo systemctl restart libvirtd
    # sudo usermod -a -G libvirt $(whoami)
    # newgrp libvirt
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

    # Minikube
    wget -c https://storage.googleapis.com/minikube/releases/latest/minikube-latest.x86_64.rpm -P ${CACHE}
    sudo rpm -ivh ${CACHE}/minikube-latest.x86_64.rpm

    ## For usermode docker enable docker configuration
    # minikube start --driver=docker --container-runtime=containerd
    # minikube kubectl -- get pods -A
}

function server_package() {
    sudo dnf -y install nats-server
    #sudo dnf -y install golang-github-nats-io-streaming-server
}

function graphics_package() {
    sudo dnf -y install gimp inkscape
    sudo dnf -y install blender pitivi
}

function internet_package() {
    sudo dnf -y install chromium thunderbird transmission
    sudo dnf -y install youtube-dl
    sudo dnf -y install vgrive

    sudo dnf -y install firefox
    sudo dnf -y install firefox-wayland
    sudo dnf -y install mozilla-noscript mozilla-ublock-origin 

    sudo dnf config-manager --set-enabled google-chrome
    sudo dnf check-update
    sudo dnf -y install google-chrome-stable
    sudo dnf -y install chrome-remote-desktop

    sudo dnf -y install torbrowser-launcher

    ## Enable widevine in Google-Chrome
    # cp libwidevinecdm.so /usr/lib64/chromium-plugins/
    # cp libwidevinecdmadapter.so /usr/lib64/chromium-plugins/
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

    sudo chown -R root:wheel /opt/go-packages
    sudo chmod -R u+rwX,go+rwX,o-w /opt/go-packages
}

function go_tools_libs_packages() {
    source /etc/profile.d/go-packages.sh

    ## VSCode go plugin dependency
    export GO111MODULE=on

    go get -v github.com/uudashr/gopkgs/v2/cmd/gopkgs
    go get -v github.com/ramya-rao-a/go-outline
    go get -v github.com/cweill/gotests/...
    go get -v github.com/fatih/gomodifytags
    go get -v github.com/josharian/impl
    go get -v github.com/haya14busa/goplay/cmd/goplay
    go get -v github.com/go-delve/delve/cmd/dlv
    go get -v github.com/stamblerre/gocode
    go get -v golang.org/x/lint/golint
    go get -v golang.org/x/tools/gopls
    go get -v honnef.co/go/tools/cmd/staticcheck

    ## Dev tools
    go get -u -v github.com/cespare/reflex
    go get -u -v golang.org/x/...
    go get -u -v golang.org/x/tools/...
    go get -u -v golang.org/x/tools/cmd/...
    go get -u -v golang.org/x/tools/gopls
    #go get -u -v golang.org/x/tools/go/analysis/...
    ## goMobile
    go get -u -v golang.org/x/mobile/cmd/gobind
    go get -u -v golang.org/x/mobile/cmd/gomobile
    ## HTTP
    go get -u -v github.com/gin-gonic/gin
    go get -u -v github.com/gin-gonic/contrib/...
    go get -u -v github.com/dgrijalva/jwt-go
    #go get -v -v github.com/go-chi/chi
    #go get -v -v github.com/go-chi/cors
    ## Log
    go get -v -v go.uber.org/zap
    ## goNum
    go get -u -v -t gonum.org/v1/gonum/...
    ## DB
    go get -u -v github.com/dgraph-io/dgo/v2
    go get -u -v go.mongodb.org/mongo-driver
    go get -u -v go.mongodb.org/mongo-driver/bson 
    go get -u -v go.mongodb.org/mongo-driver/mongo/options
    go get -u -v go.mongodb.org/mongo-driver/mongo/readpref
    ## protobuf
    go get -u -v github.com/golang/protobuf/proto
    go get -u -v github.com/golang/protobuf/protoc-gen-go
    ## gRPC
    go get -u -v google.golang.org/grpc
    ## Messaging
    #go get -u -v github.com/nats-io/nats.go
    #go get -u -v github.com/nats-io/nats-server
    #go get -u -v github.com/nats-io/nats-streaming-server
    #go get github.com/liftbridge-io/go-liftbridge
    #go get -u -v github.com/ThreeDotsLabs/watermill
    # Go CDK
    #go get -u -v gocloud.dev
    # UUID
    go get -u -v github.com/google/uuid
    # Embedded DB
    go get -u -v go.etcd.io/bbolt/...
    go get -u -v github.com/dgraph-io/badger/...
    # Firebase
    go get -u -v firebase.google.com/go
    go get -u -v firebase.google.com/go/auth

    ## Update
    #go get -u -v all
}

function npm_packages() {
    sudo dnf -y install npm
}

function vscode_package() {
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
    dnf check-update
    sudo dnf -y install code
    #code --list-extensions | xargs -L 1 echo code --install-extension
    
    #sudo echo 'fs.inotify.max_user_watches=524288' | sudo tee -a /etc/sysctl.conf
    #sudo sysctl -p

    sudo dnf -y install pandoc

    ## vscode list extensions
    # code --list-extensions | xargs -L 1 echo code --install-extension

    ## vscode install extensions
    # code --install-extension Dart-Code.dart-code
    # code --install-extension Dart-Code.flutter
    # code --install-extension GitHub.github-vscode-theme
    # code --install-extension golang.go
    # code --install-extension mhutchie.git-graph
    # code --install-extension ms-azuretools.vscode-docker
    # code --install-extension ms-python.python
    # code --install-extension ms-python.vscode-pylance
    # code --install-extension ms-toolsai.jupyter
    # code --install-extension ms-toolsai.jupyter-keymap
    # code --install-extension ms-vscode.cpptools
    # code --install-extension ms-vsliveshare.vsliveshare
    # code --install-extension redhat.java
    # code --install-extension VisualStudioExptTeam.vscodeintellicode
    # code --install-extension vscjava.vscode-java-debug

    ## Settings
#{
#    "window.titleBarStyle": "custom",
#    "workbench.startupEditor": "newUntitledFile",
#    "telemetry.enableCrashReporter": false,
#    "editor.minimap.maxColumn": 40,
#    "files.autoSave": "afterDelay",
#    "files.autoSaveDelay": 10000,
#    "editor.fontFamily": "'Fira Code Medium','Roboto Mono Medium','Droid Sans Mono', 'Monaco', 'monospace', monospace, 'Droid Sans Fallback'",
#    "editor.fontSize": 16,
#    "editor.fontLigatures": true,
#    "editor.wordWrap": "on",
#    "editor.formatOnPaste": true,
#    "editor.formatOnSave": true,
#    "editor.formatOnType": true,
#    "editor.suggest.showStatusBar": true,
#    "editor.suggest.insertMode": "insert",
#    "terminal.integrated.copyOnSelection": true,
#    "terminal.integrated.cursorBlinking": true,
#    "[Log]": {
#        "editor.wordWrap": "on"
#    },
#    "go.autocompleteUnimportedPackages": true,
#    "go.coverOnSingleTestFile": true,
#    "go.gotoSymbol.includeImports": true,
#    //"go.buildFlags": [
#    //    "-v"
#    //],
#    "go.testFlags": [
#        "-count=1",
#        "-v"
#    ],
#    "go.vetFlags": [
#        "-composites=false"
#    ],
#    "go.formatTool": "goimports",
#    "go.useLanguageServer": true,
#    "go.testTimeout": "5m",
#    "dart.lineLength": 150,
#    "[dart]": {
#        "editor.rulers": [
#            120
#        ],
#        "editor.selectionHighlight": false,
#        "editor.suggest.snippetsPreventQuickSuggestions": false,
#        "editor.suggestSelection": "first",
#        "editor.tabCompletion": "onlySnippets",
#        "editor.wordBasedSuggestions": false,
#    },
#    "dart.devToolsBrowser": "default",
#    "dart.checkForSdkUpdates": false,
#    "workbench.sideBar.location": "left",
#    "go.toolsManagement.autoUpdate": true,
#    "dart.debugExternalLibraries": false,
#    "dart.debugSdkLibraries": false,
#    "dart.openDevTools": "flutter",
#    "workbench.editorAssociations": {
#        "*.ipynb": "jupyter.notebook.ipynb"
#    },
#    "json.maxItemsComputed": 200000,
#    "python.terminal.executeInFileDir": true,
#    "python.languageServer": "Pylance",
#    "diffEditor.ignoreTrimWhitespace": false,
#    "C_Cpp.formatting": "Disabled",
#    "terminal.integrated.cursorWidth": 2,
#    "telemetry.enableTelemetry": false,
#    "workbench.colorTheme": "GitHub Dark Dimmed",
#    "markdown.preview.fontSize": 18,
#    "redhat.telemetry.enabled": false,
#    "editor.suggestSelection": "first",
#    "vsintellicode.modify.editor.suggestSelection": "automaticallyOverrodeDefaultValue"
#}

    sudo echo "fs.inotify.max_user_watches=524288" | sudo tee -a /etc/sysctl.conf
    sudo sysctl -p
}

function android-studio_package() {
    ANDROID_STUDIO_RELEASE=2020.3.1.26

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
export ANDROID_NDK_ROOT=\$ANDROID_HOME/ndk
export ANDROID_NDK_HOME=\$ANDROID_NDK_ROOT
export PATH=\$PATH:\$ANDROID_HOME/platform-tools/
EOF

    sudo cp /opt/android-studio/android-studio.desktop /usr/share/applications/android-studio.desktop
    source /etc/profile.d/android-sdk.sh

    sudo dnf -y copr enable zeno/scrcpy
    # rpmfusion_repo
    sudo dnf -y install ffmpeg scrcpy
    # remove android-tools to use SDK's tools
    sudo rpm -e android-tools --nodeps
}

function dart-sdk_package() {
    DART_VERSION="2.14.4"
    
    sudo rm -rf ${CACHE}/dartsdk-linux-x64-release.zip
    wget -c https://storage.googleapis.com/dart-archive/channels/stable/release/${DART_VERSION}/sdk/dartsdk-linux-x64-release.zip -P ${CACHE}
    sudo rm -rf /opt/dart-sdk

    sudo unzip ${CACHE}/dartsdk-linux-x64-release.zip -d /opt/
    sudo mkdir /opt/dart-sdk/pub_cache
    sudo chown -R root:wheel /opt/dart-sdk
    sudo chmod -R u+rwX,go+rwX,o-w /opt/dart-sdk

    cat <<EOF | sudo tee /etc/profile.d/dart-sdk.sh
#export PUB_CACHE=/opt/dart-sdk/pub_cache
export PATH=\$PATH:/opt/dart-sdk/bin
EOF
    source /etc/profile.d/dart-sdk.sh
    pub global activate protoc_plugin
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

    #flutter doctor
    #flutter doctor --android-licenses
    #flutter config --no-analytics
    #flutter precache
    #flutter config --enable-linux-desktop
    #flutter config --enable-windows-desktop
    #flutter config --enable-windows-uwp-desktop
    #flutter config --enable-macos-desktop
    #pub global activate protoc_plugin
}

function python_packages() {
    sudo dnf -y install python3-virtualenv virtualenvwrapper
    sudo dnf -y install python3-pylint python3-autopep8
    sudo dnf -y install python3-numpy python3-scipy python3-pandas
    sudo dnf -y install python3-matplotlib
    sudo dnf -y install python3-ipykernel

    sudo dnf -y install certbot

    # conda
    sudo dnf -y install conda
    ## conda create --name py39conda python=3.9
    ## conda activate py39conda
    ## conda install anaconda
    ## conda install scikit-learn-intelex
    ## conda install tensorflow
    ## conda install -c conda-forge opencv
}

function gnome_packages() {
    sudo dnf -y install gnome-tweaks
    sudo dnf -y install gnome-books
    sudo dnf -y install gtk-murrine-engine gtk2-engines
    sudo dnf -y install foliate
    sudo dnf -y install fondo
    sudo dnf -y install shotwell
    sudo dnf -y install gnome-boxes
    sudo dnf -y install gnome-sound-recorder easytag
    sudo dnf -y install pitivi snappy
    sudo dnf -y install evince xournalpp

    sudo dnf -y install gnome-extensions-app
    sudo dnf -y install gnome-shell-extension-dash-to-dock
    sudo dnf -y install gnome-shell-extension-gsconnect
    sudo dnf -y install gnome-shell-extension-screenshot-window-sizer
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

function gcloud_package() {
    sudo rm -rf /opt/google-cloud-sdk
    sudo mkdir -p /opt/google-cloud-sdk

    GOOGLE_CLOUD_SDK_RELEASE="318.0.0"
    
    wget -c https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GOOGLE_CLOUD_SDK_RELEASE}-linux-x86_64.tar.gz -P ${CACHE}
    sudo tar zxfv ${CACHE}/google-cloud-sdk-${GOOGLE_CLOUD_SDK_RELEASE}-linux-x86_64.tar.gz -C /opt/

    sudo chown -R root:wheel /opt/google-cloud-sdk
    sudo chmod -R u+rwX,go+rwX,o-w /opt/google-cloud-sdk

    cat <<EOF | sudo tee /etc/profile.d/google-cloud-sdk.sh
export PATH=\$PATH:/opt/google-cloud-sdk/bin
EOF

    source /etc/profile.d/google-cloud-sdk.sh
}

function mongodb_package() {
    MONGODB_VERSION="5.0"
    MONGODB_COMPASS_VERSION="1.28.4"

    cat <<EOF | sudo tee /etc/yum.repos.d/mongodb.repo
[mongodb-org-${MONGODB_VERSION}]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/amazon/2/mongodb-org/${MONGODB_VERSION}/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-${MONGODB_VERSION}.asc
EOF
    sudo dnf -y install mongodb-org
    
    ## for changing dbPath
    sudo cp /etc/mongod.conf /etc/mongod.conf.orig
    ## update dbPath at /etc/mongo.conf
    # mkdir -p /home/databases/mongo/
    # chown -R mongod:mongod /home/databases/mongo/
    # chcon -Rv --type=mongod_var_lib_t /home/databases/mongo
    # sudo systemctl enable mongod.service
    # sudo systemctl start mongod.service

    wget -c https://downloads.mongodb.com/compass/mongodb-compass-${MONGODB_COMPASS_VERSION}.x86_64.rpm -P ${CACHE}
    sudo yum install ${CACHE}/mongodb-compass-${MONGODB_COMPASS_VERSION}.x86_64.rpm
}

function embedded_dev() {
    ## arm-none-eabi toolchain
    sudo dnf -y install arm-none-eabi-binutils-cs arm-none-eabi-gcc-cs arm-none-eabi-gcc-cs-c++
    sudo dnf -y install arm-none-eabi-newlib

    ## Renode
    # RENODE_VERSION="1.12.0"
    # RENODE_SUBVERSION="1"
    # wget -c https://github.com/renode/renode/releases/download/v${RENODE_VERSION}/renode-${RENODE_VERSION}-${RENODE_SUBVERSION}.f23.x86_64.rpm -P ${CACHE}
    # sudo rpm -ivh ${CACHE}/renode-${RENODE_VERSION}-${RENODE_SUBVERSION}.f23.x86_64.rpm
    # sudo dnf -y install PackageKit-gtk3-module
}

function tizen_sdk() {
    TIZEN_VERSION="3.7"
    sudo dnf -y install expect libgnome qemu-user webkit2gtk3 libpng12 SDL compat-readline6
    # ln -s /usr/lib64/libbz2.so.1 /usr/lib64/libbz2.so.1.0

    wget -c http://download.tizen.org/sdk/Installer/tizen-studio_${TIZEN_VERSION}/web-cli_Tizen_Studio_${TIZEN_VERSION}_ubuntu-64.bin
    export TIZEN_HOME=~/workspace/cache/tizen.cache/tizen/
    export PATH=$PATH:$TIZEN_HOME/tools:$TIZEN_HOME/tools/ide/bin:$TIZEN_HOME/tizen/ide

    # Fix kvm permission denied issue
    sudo setfacl -m u:$USER:rwx /dev/kvm


    ## diff
# 62c62
# <       INSTALLATION_CHECK="procps-ng gettext dbus-libs libcurl expect gtk2 grep zip make libgnome qemu-user webkitgtk libpng12"
# ---
# >       INSTALLATION_CHECK="procps-ng gettext dbus-libs libcurl expect gtk2 grep zip make libgnome qemu-user webkit2gtk3 libpng12"
# 126,132c126,132
# < OUT_FILE_md5sum=`cat "$OUT_PATH/checksum" | awk '{ print $1 }'`
# < if [ "${OUT_FILE_md5sum}" != "${ORI_FILE_md5sum}" ]; then
# <       echo "$CE The download file appears to be corrupted. "
# <       echo " Please do not attempt to install this archive file. $CN"
# <       rm -rf ${OUT_PATH}
# <       exit 1
# < fi
# ---
# > #OUT_FILE_md5sum=`cat "$OUT_PATH/checksum" | awk '{ print $1 }'`
# > #if [ "${OUT_FILE_md5sum}" != "${ORI_FILE_md5sum}" ]; then
# > #     echo "$CE The download file appears to be corrupted. "
# > #     echo " Please do not attempt to install this archive file. $CN"
# > #     rm -rf ${OUT_PATH}
# > #     exit 1
# > #fi
# 135,139c135,139
# < if [[ ! -d "${HOME}/.package-manager/jdk" ]]; then
# <       echo "setting up jdk at ${HOME}/.package-manager/jdk"
# <       mkdir -p "${HOME}/.package-manager/jdk"
# <       "${OUT_PATH}/unzip" -qq -a "${OUT_PATH}/tizen-sdk.zip" "jdk/*" -d "${HOME}/.package-manager"
# < fi
# ---
# > #if [[ ! -d "${HOME}/.package-manager/jdk" ]]; then
# > #     echo "setting up jdk at ${HOME}/.package-manager/jdk"
# > #     mkdir -p "${HOME}/.package-manager/jdk"
# > #     "${OUT_PATH}/unzip" -qq -a "${OUT_PATH}/tizen-sdk.zip" "jdk/*" -d "${HOME}/.package-manager"
# > #fi
 
	export TIZEN_HOME=${HOME}/workspace/cache/tizen.cache/tizen-studio
	export PATH=$PATH:$TIZEN_HOME/ide:$TIZEN_HOME/tools:$TIZEN_HOME/package-manager

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
    sudo dnf -y install firewalld

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

function matlab_dep() {
    sudo dnf -y install libxcrypt-compat libnsl
}

function chroot_os() {
    sudo dnf -y install schroot debootstrap
    
    CHROOT_FOLDER=/home/chroot_env/
    
    sudo mkdir -p ${CHROOT_FOLDER}
    sudo chmod 755 ${CHROOT_FOLDER}  
    sudo chown -R root:wheel ${CHROOT_FOLDER}

    # Ubuntu
    UBUNTU_DISTRO=focal
    UBUNTU_DISTRO_FOLDER=${CHROOT_FOLDER}/ubuntu_${UBUNTU_DISTRO}
    sudo mkdir -p ${UBUNTU_DISTRO_FOLDER}
    sudo chmod 755 ${UBUNTU_DISTRO_FOLDER}
    cat <<EOF | sudo tee /etc/schroot/chroot.d/${UBUNTU_DISTRO}.conf
[${UBUNTU_DISTRO}]
description=Ubuntu ${UBUNTU_DISTRO}
directory=${UBUNTU_DISTRO_FOLDER}
type=directory
users=arp
groups=wheel
root-groups=wheel
EOF

    sudo debootstrap --arch=amd64 focal ${UBUNTU_DISTRO_FOLDER}
    # schroot -c focal -u root
}

# update_hostname
# dnf_conf_update
# fedora_upgrade
# rpmfusion_repo

# systools_package
# devtools_package
# rpm_devtools_package
# jdk_package
# server_package
# container_package
## kubernetes_packages
## docker_packages
# graphics_package
# internet_package
# python_packages
# gnome_packages
# vscode_package
# android-studio_package
# dart-sdk_package
# flutter-sdk_package
# swift_packages
# go_packages
## go_tools_libs_packages
# npm_packages
# font_packages
# codec_packages
## gcloud_package
# libreoffice_packages
# embedded_dev
## mongodb_package
# httpd_service
# security_service
