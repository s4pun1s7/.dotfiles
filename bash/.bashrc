#!/bin/bash
echo $(clear)
screenfetch -t -p

reset=$(tput sgr0)
bold=$(tput bold)

PS1="\n\[\e[0;34m\]┌─[\[\e[1;36m\u\e[0;34m\]]─[\e[1;37m\w\e[0;34m]─[\[\e[1;36m\]${HOSTNAME%%.*}\[\e[0;34m\]]\[\e[1;35m\] \[\e[0;34m\]\n\[\e[0;34m\]└╼ \[\e[1;35m\]> \[\e[00;00m\]"


# Visualiza los ficheros y directorios 
# function cdls { cd "$1"; ls --color;}
#alias cd='cdls'
#
#export LS_OPTIONS='--color=auto'
#
#eval "`dircolors`"
#alias ls='ls $LS_OPTIONS'

# Transparencia Xterm
[ -n "$XTERM_VERSION" ] && transset-df --id "$WINDOWID" >/dev/null


#ALIAS:
alias ll='ls -al'
alias m='sudo mc -b'
alias terminal='xrdb ~/.dotfiles/X11/.Xresources'
alias red='sudo systemctl restart NetworkManager'
alias synchronize='ping -c 6 8.8.8.8'
alias inter='slurm -zsi wlo1'
alias time='tty-clock -cstDC red'

#	Colors:

#  BLACK=	'\e[0;30m'
#  RED=		'\e[0;31m'
#  GREEN=	'\e[0;32m'
#  YELLOW=	'\e[0;33m'
#  BLUE=	'\e[0;34m'
#  MAGENT=	'\e[0;35m'
#  CYAN=	'\e[0;36m'
#  WHITE=	'\e[0;37m'

#  LIGHTBLACK=	'\e[1;30m'
#  LIGHTRED=	'\e[1;31m'
#  LIGHTGREEN=	'\e[1;32m'
#  LIGHTYELLOW=	'\e[1;33m'
#  LIGHTBLUE=	'\e[1;34m'
#  LIGHTMAGENT= '\e[1;35m'
#  LIGHTCYAN=	'\e[1;36m'
#  LIGHTWHITE=	'\e[1;37m'
