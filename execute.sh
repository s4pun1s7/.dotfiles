#!/usr/bin/env bash

prompt() {
	echo "$1 is not installed. Would you like to install it? (y/n)"
	read -p ": " panswer
	panswer=${panswer,,}
	if ! [[ $panswer == "y" ]] || [[ $panswer == "yes" ]]; then
		echo "Exiting with code 127\n"
		exit 127
	else
		sudo pacman --needed --noconfirm -Sy $1
	fi
}

check() {
	echo -n "Checking to see if $1 is installed... "
	if ! [[ -x "$(command -v $1)" ]]; then
		prompt $1
	else
		echo "OK"
	fi
}

check tmux
check nvim
check zsh
check git
