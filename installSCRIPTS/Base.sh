#!/bin/bash

apt-get update -y

add-apt-repository -y ppa:aguignard/ppa

apt-get update

apt-get upgrade -y

apt-get install -y i3 fish thefuck stow tty-clock dunst conky dmenu mc htop rxvt-unicode tmux fonts-font-awesome unrar feh xbacklight screenfetch git qbittorrent compton vlc guake rofi chromium-browser screengrab libxcb1-dev libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev libxcb-icccm4-dev libyajl-dev libstartup-notification0-dev libxcb-randr0-dev libev-dev libxcb-cursor-dev libxcb-xinerama0-dev libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev autoconf libxcb-xrm-dev  