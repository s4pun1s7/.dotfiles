#!/usr/bin/env bash

if [[ $EUID = 0 ]]; then 
	echo "Please don't run as root"
	exit 1
fi

usage() {
    cat <<EOF

This script is used to install and link dotfiles

Usage: ${0##*/} [command]

    -h, -?, --help      Print this help message
    -u, --update		Load and link configs from github.com/fokditkak/.dotfiles
    -i, --install       Install packages

If no commands are added, script will run in pseudo interactive mode
only executing backup functions.

EOF
}

git_clone() {
	git --version &> /dev/null
	if [[ $? -ne 0 ]]; then
		echo "You need to install git."
		exit 1
	fi
	if ! [[ -d $HOME/.dotfiles ]]; then 
		git clone https://github.com/fokditkak/.dotfiles.git $HOME/.dotfiles
	else
		echo "There is an existing configuration in $HOME/.dotfiles"
		echo "Should you choose to replace, the script WILL delete the dirs(if they exist):"
		echo "	$HOME.tmux"
		echo "	$HOME.vim"
		echo "	$HOME.config/calcurse"
		echo "	$HOME.config/fish"
		echo "	$HOME.config/nvim"
		echo "	$HOME.config/termite"
		echo -n "Replace? (y/n)"
		read -p ": " ganswer
		ganswer=${ganswer,,}
		if ! [[ $ganswer == "y" ]] || [[ $ganswer == "yes" ]]; then
			exit 127
		else
			rm -rf $HOME/.dotfiles
			rm -rf $HOME/.tmux
			rm -rf $HOME/.vim
			rm -rf $HOME/.config/calcurse
			rm -rf $HOME/.config/fish
			rm -rf $HOME/.config/nvim
			rm -rf $HOME/.config/termite
			echo "Removed old dotfiles"
			git clone https://github.com/fokditkak/.dotfiles.git $HOME/.dotfiles
		fi
	fi
}

sym_linker() {
	echo -n "Symlinkig files..."
	ln -sf $HOME/.dotfiles/.vimrc $HOME/.vimrc
	ln -sf $HOME/.dotfiles/.tmux.conf $HOME/.tmux.conf
	ln -sf $HOME/.dotfiles/.vim $HOME/
	ln -sf $HOME/.dotfiles/.tmux $HOME/
	ln -sf $HOME/.dotfiles/.config/calcurse $HOME/.config/
	ln -sf $HOME/.dotfiles/.config/fish $HOME/.config/
	ln -sf $HOME/.dotfiles/.config/termite $HOME/.config/
	ln -sf $HOME/.dotfiles/.config/nvim $HOME/.config/
	echo "Done"
	echo "Installing nvim plugins..."
	exec nvim +PlugInstall &
}

#prompt() {
#	echo "$1 is not installed. Would you like to install it? (y/n)"
#	read -p ": " panswer
#	panswer=${panswer,,}
#	if ! [[ $panswer == "y" ]] || [[ $panswer == "yes" ]]; then
#		echo "Exiting with code 127\n"
#		exit 127
#	else
#		sudo pacman --needed --noconfirm -Sy $1
#	fi
# }
#
#check() {
#	echo -n "Checking to see if $1 is installed... "
#	if ! [[ -x "$(command -v $1)" ]]; then
#		prompt $1
#	else
#		echo "OK"
#	fi
# }
#

while :; do
	case $1 in
		-h|-\?|--help)
			usage
			exit 0
			;;
		-u|--update)
			git_clone
			sym_linker
			break
			;;
        -?*)
            echo ""
            echo "Unknown option: $1" >&2
            usage
            exit 1
            ;;
        ?*)
            echo "Unknown option: $1" >&2
            usage
            exit 1
            ;;
	esac
	shift
done
