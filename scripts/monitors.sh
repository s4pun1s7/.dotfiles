#!/bin/bash
# Pin the desktop monitor arrangement: two 1080p panels side by side.
#
#   monitors.sh        apply only if the current layout does not already match
#   monitors.sh -f     apply unconditionally (after a hotplug that went wrong)
#
# RandR state lives in the X server, not in dwm, so this is NOT needed for a dwm
# restart -- the arrangement already survives that untouched. It matters at
# login, after a reboot, and when a cable is replugged.
#
# Xorg had left `primary` on DisplayPort-6, which is disconnected. Anything
# asking for the primary output (tray applets, some fullscreen apps) gets a
# useless answer, so this claims it for the left panel.

set -u

LEFT="DisplayPort-8"
RIGHT="DisplayPort-9"
MODE="1920x1080"

connected() {
	xrandr --query | grep -q "^$1 connected"
}

expected_layout() {
	printf '%s %s\n' "$LEFT+0+0" "$RIGHT+1920+0"
}

# "OUTPUT+X+Y" per active output, sorted, space separated.
current_layout() {
	xrandr --query |
		awk '/ connected /{ for (i=3; i<=NF; i++) if ($i ~ /^[0-9]+x[0-9]+\+[0-9]+\+[0-9]+$/) { print $1 "+" substr($i, index($i, "+")+1); break } }' |
		sort | tr '\n' ' ' | sed 's/ $//'
}

apply() {
	if connected "$LEFT" && connected "$RIGHT"; then
		xrandr --output "$LEFT" --mode "$MODE" --pos 0x0 --primary \
			--output "$RIGHT" --mode "$MODE" --pos 1920x0 --right-of "$LEFT"
	else
		# Different machine, or a panel is unplugged: let RandR work it out and
		# just make sure primary lands on something that actually exists.
		echo "monitors: $LEFT/$RIGHT not both connected, falling back to --auto" >&2
		xrandr --auto
		local first
		first=$(xrandr --query | awk '/ connected /{ print $1; exit }')
		[ -n "$first" ] && xrandr --output "$first" --primary
	fi
}

case "${1:-}" in
-f | --force)
	apply
	;;
*)
	want=$(expected_layout | tr ' ' '\n' | sort | tr '\n' ' ' | sed 's/ $//')
	have=$(current_layout)
	if [ "$want" = "$have" ] && xrandr --query | grep -q "^$LEFT connected primary"; then
		exit 0
	fi
	apply
	;;
esac
