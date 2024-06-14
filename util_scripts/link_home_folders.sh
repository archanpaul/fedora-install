## Link home folders

REPOS_SRC=/home/repos.arp
REPOS=~/repos
CACHE=${REPOS}/app_cache

function create_home_folders() {
	cd ~
	
	ln -sfn ${REPOS_SRC} ${REPOS}
	mkdir -p ${CACHE}

	unlink ~/Documents
	mkdir -p ${REPOS}/documents
	ln -sfn ${REPOS}/documents Documents

	unlink ~/Downloads
	mkdir -p ${REPOS}/downloads
	ln -sfn ${REPOS}/downloads Downloads
	
	unlink ~/Music
	mkdir -p ${REPOS}/audio
	ln -sfn ${REPOS}/audio Music
	
	unlink ~/Videos
	mkdir -p ${REPOS}/videos
	ln -sfn ${REPOS}/videos Videos
	
	unlink ~/Pictures
	mkdir -p ${REPOS}/pictures
	ln -sfn ${REPOS}/pictures Pictures

	unlink ~/Templates
	mkdir -p ${REPOS}/templates
	ln -sfn ${REPOS}/templates Templates

	unlink ~/Public
	mkdir -p ${REPOS}/public
	ln -sfn ${REPOS}/public Public

	mkdir -p ${REPOS}/workspace
	ln -sfn ${REPOS}/workspace .

	mkdir ~/.ssh
	chmod 700 ~/.ssh
}

function create_app_cache() {
	mkdir -p ~/.config
	mkdir -p ~/.local/share/ ~/.cache

	mkdir -p ${CACHE}/gradle.cache
	ln -sfn ${CACHE}/gradle.cache ~/.gradle

	mkdir -p ${CACHE}/minikube.cache
	ln -sfn ${CACHE}/minikube.cache ~/.minikube

	# mkdir -p ${CACHE}/firebase.cache
	# ln -sfn ${CACHE}/firebase.cache ~/.cache/firebase

	mkdir -p ~/.local/share/containers
	mkdir -p ${CACHE}/containers.cache
	mkdir -p ${CACHE}/containers.cache/storage
	mkdir -p ${CACHE}/containers.cache/cache
	mkdir -p ${CACHE}/containers.cache/shared_folder
	ln -sfn ${CACHE}/containers.cache/storage ~/.local/share/containers/storage
	ln -sfn ${CACHE}/containers.cache/cache ~/.local/share/containers/cache
	ln -sfn ${CACHE}/containers.cache/shared_folder ~/.local/share/containers/shared_folder

	mkdir -p ${CACHE}/docker.cache
	ln -sfn ${CACHE}/docker.cache ~/.local/share/docker

	mkdir -p ${CACHE}/vm.cache
	ln -sfn ${CACHE}/vm.cache ~/.local/share/vm

	mkdir -p ${CACHE}/libvirt
	ln -sfn ${CACHE}/libvirt ~/.config/libvirt

	mkdir -p ${CACHE}/gnome-boxes.cache/gnome-boxes_cache ${CACHE}/gnome-boxes.cache/gnome-boxes_config ${CACHE}/gnome-boxes.cache/gnome-boxes_local_share
	ln -sfn ${CACHE}/gnome-boxes.cache/gnome-boxes_cache ~/.cache/gnome-boxes
	ln -sfn ${CACHE}/gnome-boxes.cache/gnome-boxes_config ~/.config/gnome-boxes
	ln -sfn ${CACHE}/gnome-boxes.cache/gnome-boxes_local_share ~/.local/share/gnome-boxes

	mkdir -p ${CACHE}/firefox.cache
	rm -rf ~/.mozilla
	ln -sfn ${CACHE}/firefox.cache ~/.mozilla

	mkdir -p ${CACHE}/edge/cache ${CACHE}/edge/config 
	ln -sfn ${CACHE}/edge/cache .cache/microsoft-edge
	ln -sfn ${CACHE}/edge/config .config/microsoft-edge

	mkdir -p ${CACHE}/google-chrome.cache
	ln -sfn ${CACHE}/google-chrome.cache ~/.config/google-chrome

	mkdir -p ${CACHE}/virtualenvs.cache
	ln -sfn ${CACHE}/virtualenvs.cache ~/.virtualenvs

	mkdir -p ${CACHE}/npm.cache
	mkdir -p ${CACHE}/npm.cache/npm
	ln -sfn ${CACHE}/npm.cache/npm ~/.npm
	mkdir -p ${CACHE}/npm.cache/node_modules
	ln -sfn ${CACHE}/npm.cache/node_modules ~/node_modules
	echo "export PATH=$PATH:~/node_modules/.bin"

	# pytorch
	mkdir -p ${CACHE}/torch.cache
	ln -sfn ${CACHE}/torch.cache ~/.cache/torch
}

create_home_folders
create_app_cache
ls -lah
