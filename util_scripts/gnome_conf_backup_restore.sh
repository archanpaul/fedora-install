
function backup_gnome_config() {
	dconf dump /org/gnome/ > ./org_gnome.dconf
	sed -i '/\[login-screen\]\|enable-fingerprint-authentication\|enable-smartcard-authentication/d' ./org_gnome.dconf
}

function restore_gnome_config() {
	cat ./org_gnome.dconf | dconf load /org/gnome/
}


backup_gnome_config
# restore_gnome_config
