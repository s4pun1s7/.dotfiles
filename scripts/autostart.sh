#!/bin/bash

picom -b --config "$HOME/.config/picom/picom.conf" &
nm-applet &
guake &
slstatus &
