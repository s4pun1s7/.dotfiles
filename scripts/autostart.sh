#!/bin/bash

# dwm runs this via system(), so every child here inherits dwm's ignored
# SIGCHLD (SA_NOCLDWAIT). A shell cannot undo that -- `trap - CHLD` restores
# the disposition the shell started with, which is still SIG_IGN -- so each
# program that needs working popen()/waitpid() resets SIGCHLD itself.
# slstatus does this in main(); see slstatus/slstatus.c.

# This script is symlinked into ~/.local/share/dwm, so resolve back to the repo.
SCRIPTS_DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")

# Monitors before the wallpaper, so feh crops to the final geometry. This is a
# no-op when the arrangement is already right, which it is on every dwm restart
# (RandR state belongs to the X server, not dwm).
"$SCRIPTS_DIR/monitors.sh"

# Keyboard: US + Bulgarian phonetic, Alt+Shift cycles. Nothing else configures
# this -- /etc/X11/xorg.conf.d/00-keyboard.conf is systemd-localed's us-only
# file -- so the layout has to be set per session here. slstatus's keymap block
# shows the active group. Note the greeter and TTYs stay us; use
# `localectl set-x11-keymap us,bg pc105 ,phonetic grp:alt_shift_toggle` if you
# want it system-wide too.
setxkbmap -layout us,bg -variant ,phonetic -option grp:alt_shift_toggle

# Wallpaper + pywal colour scheme. -r restores the cached scheme rather than
# re-extracting colours, which keeps login fast; Mod+Ctrl+w rolls a new one.
# Before picom, so the compositor comes up over an already painted root window.
"$SCRIPTS_DIR/setwallpaper.sh" -r

picom -b --config "$HOME/.config/picom/picom.conf" &
guake &

# dwm restarts (Mod+Shift+c) re-run this script without ending the X session,
# so replace the instances that survive instead of stacking duplicates.
for prog in nm-applet slstatus; do
	pkill -x "$prog" 2>/dev/null || continue
	# Wait for the old one to go, so it cannot clean up over the new one
	# (slstatus clears the root window name on exit).
	for _ in $(seq 20); do
		pgrep -x "$prog" >/dev/null || break
		sleep 0.1
	done
done

nm-applet &
slstatus &
