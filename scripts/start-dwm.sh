#!/bin/sh
[ -x "$HOME/.config/autostart/autostart.sh" ] && "$HOME/.config/autostart/autostart.sh" &
while :; do
	dwm || break
done
