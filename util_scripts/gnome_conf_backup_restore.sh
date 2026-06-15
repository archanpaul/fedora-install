
function backup_gnome_config() {
	dconf dump /org/gnome/ > ../confs/org_gnome.dconf
	sed -i '/\[login-screen\]\|enable-fingerprint-authentication\|enable-smartcard-authentication/d' ../confs/org_gnome.dconf
}

function restore_gnome_config() {
	cat ../confs/org_gnome.dconf | dconf load /org/gnome/
}


backup_gnome_config
# restore_gnome_config
