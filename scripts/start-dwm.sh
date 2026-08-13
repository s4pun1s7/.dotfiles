#!/bin/sh
# X session entry point, installed to /usr/local/bin/start-dwm.
# dwm's autostart patch runs ~/.local/share/dwm/autostart.sh itself,
# so this only has to keep dwm alive across restarts (Mod+Shift+c).
while :; do
	dwm || break
done
