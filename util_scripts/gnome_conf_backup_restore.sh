
function backup_gnome_config() {
	dconf dump /org/gnome/ > org_gnome.dconf
}

function restore_gnome_config() {
	cat org_gnome.dconf | dconf load /org/gnome/
}


backup_gnome_config
# restore_gnome_config
