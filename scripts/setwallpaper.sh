#!/bin/bash
# Set the wallpaper and retheme the desktop from it via pywal.
#
#   setwallpaper.sh              random image from ~/wallpapers
#   setwallpaper.sh IMAGE        that specific image
#   setwallpaper.sh -r           restore the last scheme without re-running
#                                colour extraction (used at login)
#
# pywal renders the templates in config/wal/templates into ~/.cache/wal and
# sets the wallpaper itself; the rest of this script is the reload plumbing
# for the four apps that consume them. Without pywal installed it degrades to
# a plain feh call, which is what the Mac and a fresh box get.

set -u

WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/wallpapers}"
CACHE="$HOME/.cache/wal"

pick_wallpaper() {
	find "$WALLPAPER_DIR" -maxdepth 1 -type f \
		\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) 2>/dev/null |
		shuf -n 1
}

# dunst cannot include files, so the drop-in is a symlink into the cache.
link_dunst_dropin() {
	local dropin="${XDG_CONFIG_HOME:-$HOME/.config}/dunst/dunstrc.d/50-wal.conf"
	[ -e "$CACHE/colors-dunst.conf" ] || return 0
	mkdir -p "$(dirname "$dropin")"
	[ "$(readlink "$dropin")" = "$CACHE/colors-dunst.conf" ] && return 0
	ln -sfn "$CACHE/colors-dunst.conf" "$dropin"
}

reload_apps() {
	# dwm reads dwm.* from the X resource database; -merge keeps whatever else
	# (pywal's own *.color0 etc) is already loaded.
	if [ -f "$CACHE/colors-dwm.Xresources" ] && command -v xrdb >/dev/null; then
		xrdb -merge "$CACHE/colors-dwm.Xresources"
		# Ask the running dwm to re-read them, same as the Mod+Shift+F5 bind.
		# fsignal rides the root window name; the patch is explicitly designed
		# not to collide with slstatus doing the same. Needs FSIGNAL_PATCH and
		# XRDB_PATCH, both enabled in dwm/patches.def.h.
		command -v xsetroot >/dev/null && xsetroot -name "fsignal:xrdb"
	fi

	link_dunst_dropin
	# Not SIGUSR2 -- that is unpause. dunstctl reload is the documented way and
	# the man page warns the signal meanings are not stable.
	command -v dunstctl >/dev/null && dunstctl reload 2>/dev/null

	# Alacritty watches its own config file; tmux needs telling.
	if [ -f "$CACHE/colors-tmux.conf" ] && command -v tmux >/dev/null; then
		tmux source-file "$CACHE/colors-tmux.conf" 2>/dev/null
	fi
}

main() {
	local wallpaper=""

	case "${1:-}" in
	-r | --restore)
		# -R reuses the cached scheme: no colour extraction, much faster login.
		# With no cache yet (first login after install) fall through to a full
		# run so the very first session is themed too.
		if command -v wal >/dev/null && [ -f "$CACHE/wal" ] && wal -R -q -n 2>/dev/null; then
			wallpaper=$(cat "$CACHE/wal")
			[ -n "$wallpaper" ] && [ -f "$wallpaper" ] || wallpaper=$(pick_wallpaper)
			[ -n "$wallpaper" ] && feh --no-fehbg --bg-fill "$wallpaper"
			reload_apps
			return 0
		fi
		wallpaper=$(pick_wallpaper)
		;;
	"")
		wallpaper=$(pick_wallpaper)
		;;
	*)
		wallpaper="$1"
		;;
	esac

	if [ -z "$wallpaper" ] || [ ! -f "$wallpaper" ]; then
		echo "setwallpaper: no image found in $WALLPAPER_DIR" >&2
		return 1
	fi

	if command -v wal >/dev/null; then
		# -n stops pywal setting the wallpaper so feh does it, matching the
		# --bg-fill crop across both monitors that pywal's own call does not do.
		wal -i "$wallpaper" -q -n || return 1
	fi

	feh --no-fehbg --bg-fill "$wallpaper"
	reload_apps
}

main "$@"
