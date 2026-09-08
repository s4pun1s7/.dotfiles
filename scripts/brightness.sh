#!/bin/sh
# External monitor brightness via ddcutil (VCP 0x10), with a cache so slstatus
# does not block on a multi-second DDC round-trip every second.
#
# Usage: brightness.sh get|up|down|sync

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
CACHE="$CACHE_DIR/ddc-brightness"
DISPS="$CACHE_DIR/ddc-displays"
STEP=5

mkdir -p "$CACHE_DIR"

read_pct() {
	tr -dc '0-9' <"$CACHE" 2>/dev/null
}

write_pct() {
	echo "$1%" >"$CACHE"
}

detect_displays() {
	ddcutil detect --brief 2>/dev/null | awk '/^Display /{print $2}' >"$DISPS"
}

set_all() {
	# Absolute value keeps both monitors aligned even if one drifted.
	val=$1
	if [ -s "$DISPS" ]; then
		while read -r d; do
			[ -n "$d" ] || continue
			ddcutil --display "$d" setvcp 10 "$val" --noverify >/dev/null 2>&1 &
		done <"$DISPS"
	else
		ddcutil setvcp 10 "$val" --noverify >/dev/null 2>&1 &
	fi
	wait
}

sync_cache() {
	detect_displays
	d=$(awk 'NR==1{print; exit}' "$DISPS" 2>/dev/null)
	if [ -n "$d" ]; then
		v=$(ddcutil --display "$d" getvcp 10 --brief 2>/dev/null | awk '{print $4}')
	else
		v=$(ddcutil getvcp 10 --brief 2>/dev/null | awk '{print $4}')
	fi
	write_pct "${v:-0}"
}

adjust() {
	delta=$1
	cur=$(read_pct)
	cur=${cur:-50}
	new=$((cur + delta))
	[ "$new" -gt 100 ] && new=100
	[ "$new" -lt 0 ] && new=0
	write_pct "$new"
	pkill -USR1 -x slstatus 2>/dev/null
	# DDC is slow; apply in the background after the bar has refreshed.
	(set_all "$new") &
}

case "$1" in
get)
	if [ -f "$CACHE" ]; then
		cat "$CACHE"
	else
		# First call before sync: avoid blocking the bar for seconds.
		echo "n/a"
	fi
	;;
up)
	adjust "$STEP"
	;;
down)
	adjust "-$STEP"
	;;
sync)
	sync_cache
	pkill -USR1 -x slstatus 2>/dev/null
	;;
*)
	echo "usage: $0 get|up|down|sync" >&2
	exit 1
	;;
esac
