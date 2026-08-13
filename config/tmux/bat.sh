#!/usr/bin/env bash
# Battery block for the tmux status bar.
# Prints nothing on desktops without a battery, so the same config works
# on the Fedora tower and on the Mac.

if command -v acpi >/dev/null 2>&1; then
    acpi 2>/dev/null | awk 'NR==1 { printf("%s %s %s | ", $1, $4, $3) }'
elif command -v pmset >/dev/null 2>&1; then
    pmset -g batt 2>/dev/null | awk '/InternalBattery/ { printf("Battery: %s %s | ", $3, $4) }'
fi
