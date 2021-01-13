CACHE=`pwd`/cache
HOSTNAME="arpo"

mkdir -p ${CACHE}

function fedora_upgrade() {
    #sudo echo 'keepcache=1' | sudo tee -a /etc/dnf/dnf.conf
    #sudo echo 'fastestmirror=True' | sudo tee -a /etc/dnf/dnf.conf
    #dnf install fedora-workstation-repositories
    sudo dnf -y upgrade --downloadonly
    sudo dnf -y upgrade
}

function update_hostname() {
    hostnamectl set-hostname --static ${HOSTNAME}
}

function rpmfusion_repo() {
    sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
}

function systools_package() {
    sudo dnf -y install grubby

    sudo dnf -y install mc vim
    sudo dnf -y install sysstat htop glances
    sudo dnf -y install nmap traceroute

    sudo dnf -y install mesa-vulkan-drivers vulkan-tools

    # sudo dnf -y install inxi
    # sudo inxi --admin --verbosity=7 --filter --no-host
}

function devtools_package() {
    sudo dnf -y install autoconf automake make cmake patch pkgconf libtool
    sudo dnf -y install strace byacc elfutils ltrace strace valgrind 

    sudo dnf -y install binutils bison flex gcc gcc-c++ gdb
    sudo dnf -y install clang

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
    sudo dnf -y install libvirt-devel
    ## sudo systemctl enable libvirtd
    ## sudo systemctl restart libvirtd
    ## sudo gpasswd -a $USER libvirt

    _kubernetes_packages
    #_vagrant_packages

    # switch cgroup v1 to use docker via moby-engine
    ## sudo grubby --update-kernel=ALL --args="systemd.unified_cgroup_hierarchy=0"
    ## # sudo grubby --update-kernel=ALL --remove-args="systemd.unified_cgroup_hierarchy=0"
    ## sudo systemctl enable -now docker
    ## sudo chmod 666 /var/run/docker.sock
}

function _kubernetes_packages() {
    sudo dnf -y install kubernetes
    sudo dnf -y install podman 
    #sudo dnf -y install slirp4netns buildah skopeo runc
    #sudo dnf -y install podman-compose
}

function _vagrant_packages() {
    sudo dnf install libvirt vagrant vagrant-libvirt vagrant-sshfs

    ## custom
    VAGRANT_VERSION=2.2.7
    sudo rpm -ivh https://releases.hashicorp.com/vagrant/${VAGRANT_VERSION}/vagrant_${VAGRANT_VERSION}_x86_64.rpm
    sudo dnf -y install libvirt-devel ruby-devel
    # vagrant plugin install vagrant-libvirt
}

function server_package() {
    sudo dnf -y install nats-server
    #sudo dnf -y install golang-github-nats-io-streaming-server
}

function graphics_package() {
    sudo dnf -y install gimp inkscape blender
}

function internet_package() {
    sudo dnf -y install chromium thunderbird transmission
    sudo dnf -y install youtube-dl
    sudo dnf -y install vgrive

    sudo dnf config-manager --set-enabled google-chrome
    sudo dnf check-update
    sudo dnf -y install google-chrome-stable

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
    go get -v github.com/ramya-rao-a/go-outline
    go get -v github.com/stamblerre/gocode
    go get -v github.com/uudashr/gopkgs/cmd/gopkgs
    go get -v github.com/ramya-rao-a/go-outline
    go get -v github.com/rogpeppe/godef
    go get -v github.com/sqs/goreturns
    go get -v golang.org/x/lint/golint
    go get -v golang.org/x/tools/gopls

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
    ## goNum
    go get -u -v -t gonum.org/v1/gonum/...
    ## DB
    export GO111MODULE=on
    go get -u -v github.com/dgraph-io/dgo/v2
    go get -u -v go.mongodb.org/mongo-driver
    go get -u -v go.mongodb.org/mongo-driver/bson 
    go get -u -v go.mongodb.org/mongo-driver/mongo/options
    go get -u -v go.mongodb.org/mongo-driver/mongo/readpref
    ## protobuf
    go get -u -v github.com/golang/protobuf/protoc-gen-go
    ## gRPC
    go get -u -v google.golang.org/grpc
    # Go Protobuf
    go get -u -v github.com/golang/protobuf/proto
    go get -u -v github.com/golang/protobuf/protoc-gen-go
    # NATS
    go get -u -v github.com/nats-io/nats.go
    ##go get -u -v github.com/nats-io/nats-server
    ##go get -u -v github.com/nats-io/nats-streaming-server
    #go get github.com/liftbridge-io/go-liftbridge
    # Go CDK
    go get -u -v gocloud.dev
    # UUID
    go get -u -v github.com/google/uuid
    go get -u -v github.com/nats-io/nuid
    # Embedded DB
    go get -u -v go.etcd.io/bbolt/...
    go get -u -v github.com/dgraph-io/badger/...
    # Firebase
    go get -u -v firebase.google.com/go


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

    ## vscode list extensions
    # code --list-extensions | xargs -L 1 echo code --install-extension

    ## vscode install extensions
# code --install-extension Dart-Code.dart-code
# code --install-extension Dart-Code.flutter
# code --install-extension GitHub.github-vscode-theme
# code --install-extension GitHub.vscode-pull-request-github
# code --install-extension golang.go
# code --install-extension mhutchie.git-graph
# code --install-extension ms-vscode-remote.remote-ssh
# code --install-extension ms-vscode-remote.remote-ssh-edit
# code --install-extension ms-vscode.cpptools
# code --install-extension PKief.material-icon-theme
# code --install-extension redhat.java
# code --install-extension redhat.vscode-yaml
# code --install-extension VisualStudioExptTeam.vscodeintellicode

    ## Settings
# {
#     "window.titleBarStyle": "custom",
#     "workbench.startupEditor": "newUntitledFile",
#     "telemetry.enableCrashReporter": false,
#     "telemetry.enableTelemetry": false,
#     "files.autoSave": "afterDelay",
#     "files.autoSaveDelay": 10000,
#     "workbench.colorTheme": "GitHub Light",
#     "editor.fontFamily": "'Monaco', 'Fira Code Medium', 'Roboto Mono Medium', 'Monospace'",
#     "editor.lineHeight": 24,
#     "editor.fontSize": 16,
#     "editor.fontLigatures": true,
#     "editor.fontWeight": 900,
#     "editor.wordWrap": "on",
#     "editor.minimap.maxColumn": 40,
#     "editor.formatOnPaste": true,
#     "editor.formatOnSave": true,
#     "editor.formatOnType": true,
#     // "editor.formatOnSaveMode": "modifications",
#     "editor.rulers": [
#         80
#     ],
#     "terminal.integrated.copyOnSelection": true,
#     "terminal.integrated.fontSize": 14,
#     "terminal.integrated.cursorBlinking": true,
#     "[Log]": {
#         "editor.wordWrap": "on" // "off", "bounded", "wordWrapColumn"
#     },
#     "debug.openDebug": "openOnDebugBreak",
#     "go.autocompleteUnimportedPackages": true,
#     "go.coverOnSingleTestFile": true,
#     "go.gotoSymbol.includeImports": true,
#     "go.buildFlags": [
#         "-v"
#     ],
#     "go.testFlags": [
#         "-count=1",
#         "-v"
#     ],
#     "go.vetFlags": [
#         "-composites=false"
#     ],
#     "go.formatTool": "goimports",
#     "go.useLanguageServer": true,
#     "go.testTimeout": "180s",
#     "[dart]": {
#         "editor.selectionHighlight": false,
#         "editor.suggest.snippetsPreventQuickSuggestions": false,
#         "editor.suggestSelection": "first",
#         "editor.tabCompletion": "onlySnippets",
#         "editor.wordBasedSuggestions": false,
#     },
#     "editor.suggestSelection": "first",
#     "vsintellicode.modify.editor.suggestSelection": "automaticallyOverrodeDefaultValue",
#     "workbench.iconTheme": "vs-seti",
#     "dart.devToolsBrowser": "default",
#     "terminal.integrated.fontFamily": "monospace"
# }

    sudo echo "fs.inotify.max_user_watches=524288" | sudo tee -a /etc/sysctl.conf
    sudo sysctl -p
}

function android-studio_package() {
    ANDROID_STUDIO_RELEASE=4.1.1.0
    ANDROID_STUDIO_VERSION=201.6953283

    sudo rm -rf /opt/android-studio
    sudo  mkdir -p /opt/android-studio

    wget -c https://dl.google.com/dl/android/studio/ide-zips/${ANDROID_STUDIO_RELEASE}/android-studio-ide-${ANDROID_STUDIO_VERSION}-linux.tar.gz -P ${CACHE}

    sudo tar zxfv ${CACHE}/android-studio-ide-${ANDROID_STUDIO_VERSION}-linux.tar.gz -C /opt/
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
export PATH=\$PATH:\$ANDROID_HOME/platform-tools/
EOF

    # sudo ln -sf /opt/android-studio/android-studio.desktop /usr/share/applications/android-studio.desktop
    sudo cp /opt/android-studio/android-studio.desktop /usr/share/applications/android-studio.desktop
    source /etc/profile.d/android-sdk.sh

    sudo dnf copr enable zeno/scrcpy
    # rpmfusion_repo
    sudo dnf install ffmpeg scrcpy
    # remove android-tools to use SDK's tools
    sudo rpm -e android-tools --nodeps
}

function dart-sdk_package() {
    DART_VERSION="2.10.4"
    
    sudo rm -rf ${CACHE}/dartsdk-linux-x64-release.zip
    wget https://storage.googleapis.com/dart-archive/channels/stable/release/${DART_VERSION}/sdk/dartsdk-linux-x64-release.zip -P ${CACHE}
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

    #sudo git clone -b stable --single-branch https://github.com/flutter/flutter.git /opt/flutter-sdk --depth=1
    sudo git clone -b master https://github.com/flutter/flutter.git /opt/flutter-sdk 
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

    #flutter doctor
    #flutter doctor --android-licenses
    #flutter config --no-analytics
    #flutter precache
    #pub global activate protoc_plugin
}

function python_packages() {
    sudo dnf -y install python3-virtualenv
    sudo dnf -y install python3-pylint python3-autopep8
    sudo dnf -y install python3-numpy
    sudo dnf -y install python3-matplotlib
}

function gnome_packages() {
    sudo dnf -y install gnome-tweaks
    sudo dnf -y install gnome-books
    sudo dnf -y install gtk-murrine-engine gtk2-engines
    sudo dnf -y install foliate
    sudo dnf -y install fondo
    sudo dnf -y install shotwell
    sudo dnf -y install gnome-sound-recorder easytag
    sudo dnf -y install pitivi snappy

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
    sudo dnf -y install gstreamer1-plugin-openh264 mozilla-openh264
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
	  MONGODB_VERSION="4.4"
	  MONGODB_COMPASS_VERSION="1.23.0"


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

## update_hostname
## rpmfusion_repo

## fedora_upgrade

## systools_package
## devtools_package
## rpm_devtools_package
## jdk_package
## server_package
## container_package
## graphics_package
## internet_package
## python_packages
## gnome_packages
## vscode_package
## android-studio_package
## dart-sdk_package
## flutter-sdk_package
## swift_packages
## go_packages
# go_tools_libs_packages
## npm_packages
font_packages
## codec_packages
## gcloud_package
## libreoffice_packages
## mongodb_package
## httpd_service
## security_service
