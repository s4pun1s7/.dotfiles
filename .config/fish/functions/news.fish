# Defined in - @ line 0
function news --description 'newsboat RSS feed'
	newsboat -u ~/git/.dotfiles/.config/newsboat/urls $argv;
end
