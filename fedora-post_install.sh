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

function systools_package() {
	sudo dnf -y install mc vim
	sudo dnf -y install sysstat htop glances
	sudo dnf -y install nmap traceroute

	sudo dnf -y install mesa-vulkan-drivers vulkan-tools
}

function devtools_package() {
	sudo dnf -y install autoconf automake make patch pkgconf libtool
	sudo dnf -y install strace byacc elfutils ltrace strace valgrind 

	sudo dnf -y install binutils bison flex gcc gcc-c++ gdb
	sudo dnf -y install clang

	sudo dnf -y install glibc-devel libstdc++-devel kernel-devel
	sudo dnf -y install protobuf protobuf-compiler protobuf-devel

	sudo dnf -y install git

  	sudo dnf -y install java-openjdk-devel
}

function server_package() {
	sudo dnf -y install docker kubernetes
	##sudo dnf -y install mongodb
	##sudo dnf -y install couchdb
}

function graphics_package() {
	sudo dnf -y install gimp inkscape blender
}

function internet_package() {
	sudo dnf -y install chromium thunderbird transmission
	sudo dnf -y install youtube-dl

	#dnf config-manager --set-enabled google-chrome
	dnf install google-chrome-stable

	## Enable widevine in Google-Chrome
	# cp libwidevinecdm.so /usr/lib64/chromium-plugins/
	# cp libwidevinecdmadapter.so /usr/lib64/chromium-plugins/
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

	## VSCode go plugin dependency
	#go get -u -v github.com/mdempsky/gocode
	go clean -i -n github.com/mdempsky/gocode...
	go get -u -v github.com/stamblerre/gocode
	go get -u -v github.com/uudashr/gopkgs/cmd/gopkgs
	go get -u -v github.com/mdempsky/gocode
	go get -u -v github.com/ramya-rao-a/go-outline
	go get -u -v github.com/uudashr/gopkgs/cmd/gopkgs
	go get -u -v github.com/ramya-rao-a/go-outline
	go get -u -v github.com/acroca/go-symbols
	go get -u -v golang.org/x/tools/cmd/guru
	go get -u -v golang.org/x/tools/cmd/gorename
	go get -u -v github.com/go-delve/delve/cmd/dlv 
	go get -u -v github.com/stamblerre/gocode
	go get -u -v github.com/rogpeppe/godef
	go get -u -v github.com/sqs/goreturns
	go get -u -v golang.org/x/lint/golint
	go get -u -v github.com/stamblerre/gocode
	go get -u -v github.com/stamblerre/gocode

	## Dev tools
	go get -u -v github.com/cespare/reflex
	go get -u -v golang.org/x/...
	go get -u -v golang.org/x/tools/...
	go get -u -v golang.org/x/tools/cmd/...
	#go get -u -v golang.org/x/tools/cmd/gorename
	#go get -u -v golang.org/x/tools/cmd/goimports
	#go get -u -v golang.org/x/tools/gopls
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
	go get go.mongodb.org/mongo-driver/mongo
	go get go.mongodb.org/mongo-driver/mongo/options
	go get github.com/lib/pq
	## protobuf
	go get -u github.com/golang/protobuf/protoc-gen-go
	## gRPC
	go get -u google.golang.org/grpc
	# Go Protobuf
	go get -u github.com/golang/protobuf/proto
	go get -u github.com/golang/protobuf/protoc-gen-go
	# Go CDK
	go get gocloud.dev

	## Update
	#go get -u -v all

	sudo chown -R root:wheel /opt/go-packages
	sudo chmod -R u+rwX,go+rwX,o-w /opt/go-packages
}

function vscode_package() {
	sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
	sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
	dnf check-update
	sudo dnf -y install code
	#code --list-extensions | xargs -L 1 echo code --install-extension
	
	#sudo echo 'fs.inotify.max_user_watches=524288' | sudo tee -a /etc/sysctl.conf
	#sudo sysctl -p

	#code --list-extensions | xargs -L 1 echo code --install-extension
	##code --install-extension azemoh.one-monokai
	##code --install-extension Dart-Code.dart-code
	##code --install-extension Dart-Code.flutter
	##code --install-extension ms-azuretools.vscode-docker
	##code --install-extension ms-python.python
	##code --install-extension ms-vscode.cpptools
	##code --install-extension ms-vscode.Go
	##code --install-extension msjsdiag.debugger-for-chrome
	##code --install-extension Nash.awesome-flutter-snippets
	##code --install-extension plex.vscode-protolint
	##code --install-extension thenikso.github-plus-theme
	##code --install-extension VisualStudioExptTeam.vscodeintellicode
	##code --install-extension zxh404.vscode-proto3

	## Settings
	# {
	#    "workbench.startupEditor": "newUntitledFile",
	#    "editor.suggestSelection": "first",
	#    "vsintellicode.modify.editor.suggestSelection": "automaticallyOverrodeDefaultValue",
	#    "workbench.colorTheme": "One Monokai",
	#    "files.autoSave": "afterDelay",
	#    "files.autoSaveDelay": 10000,
	#    "editor.fontFamily": "'Fira Code Medium','Droid Sans Mono', 'monospace', monospace, 'Droid Sans Fallback'",
	#    "editor.wordWrap": "on",
	#    "editor.formatOnSave": true,
	#    "editor.formatOnType": true,
	#    "go.formatTool": "goimports",
	#    "window.titleBarStyle": "custom",
	#    "telemetry.enableCrashReporter": false,
	#    "telemetry.enableTelemetry": false,
	#    "editor.minimap.enabled": false
	# }

}

function android-studio_package() {
	ANDROID_STUDIO_RELEASE=3.5.2.0
        ANDROID_STUDIO_VERSION=191.5977832

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
Exec=env _JAVA_OPTIONS=-Djava.io.tmpdir=/var/tmp \
/opt/android-studio/bin/studio.sh
Terminal=false
Categories=Development;IDE;
EOF

	sudo mkdir -p /opt/android-sdk
	sudo chown -R root:wheel /opt/android-sdk
	sudo chmod -R u+rwX,go+rwX,o-w /opt/android-sdk

	cat <<EOF | sudo tee /etc/profile.d/android-sdk.sh
export ANDROID_HOME=/opt/android-sdk/
export ANDROID_SDK_ROOT=\$ANDROID_HOME
export ANDROID_NDK_ROOT=\$ANDROID_HOME/ndk-bundle
export PATH=\$PATH:\$ANDROID_HOME/platform-tools/
EOF

        sudo ln -sf /opt/android-studio/android-studio.desktop /usr/share/applications/android-studio.desktop
	source /etc/profile.d/android-sdk.sh
}

function dart-sdk_package() {
	wget -c https://storage.googleapis.com/dart-archive/channels/stable/release/2.6.1/sdk/dartsdk-linux-x64-release.zip -P ${CACHE}
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
	#flutter precache
	#pub global activate protoc_plugin
}

function python_packages() {
	sudo dnf -y install python3-virtualenv
	sudo dnf -y install python3-numpy
	sudo dnf -y install python3-matplotlib
}

function gnome_packages() {
	sudo dnf -y install gnome-tweaks
	sudo dnf -y install gnome-shell-extension-dash-to-dock
	sudo dnf -y install gnome-books
	sudo dnf -y install gtk-murrine-engine gtk2-engines
}

function docker_config() {
	sudo groupadd docker 
	sudo gpasswd -a ${USER} docker 
	# sudo systemctl restart docker
}

#RPMFusion
function rpmfusion_source() {
	sudo dnf -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
	sudo dnf -y install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
}
function rpmfusion_packages() {
	sudo dnf -y install gstreamer1-libav
	sudo dnf -y install ffmpeg
}

function httpd_service() {
        sudo mkdir /home/public
        sudo chmod 775 /home/public
        sudo ln -s /home/public /var/www/html/public
        sudo chcon -R --reference=/var/www/html /home/public
        sudo systemctl enable httpd
        sudo systemctl restart httpd
}

# update_hostname

fedora_upgrade

## systools_package
## devtools_package
## server_package
## graphics_package
## internet_package
## python_packages
## gnome_packages
## rpmfusion_source
## rpmfusion_packages
## vscode_package
## android-studio_package
## dart-sdk_package
## flutter-sdk_package
## go_packages
## docker_config
## httpd_service
