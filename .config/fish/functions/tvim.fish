# Defined in - @ line 0
function tvim --description 'Testing Purposes' 
    if  -w $1 || ( -w $(dirname $1) && ! -f $1 ) 
        command nvim $argv
    else
        sudo nvim -u $HOME/.vimrc $1
	end
end


