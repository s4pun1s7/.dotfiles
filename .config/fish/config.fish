set -x PATH $HOME/.cargo/bin $PATH

abbr ai 'sudo apt install'
abbr as 'apt-cache search'
abbr ar 'sudo apt remove'
abbr au 'sudo apt-get update'
abbr auu 'sudo apt-get upgrade'
abbr gs 'git status'
abbr gp 'git push'
abbr gpl 'git pull'
abbr gc 'git commit -m'
abbr gf 'git fetch'
abbr gd 'git diff'

# Base16 Shell
if status --is-interactive
     set BASE16_SHELL "$HOME/.config/base16-shell/"
	 source "$BASE16_SHELL/profile_helper.fish"
end
