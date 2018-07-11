" All system-wide defaults are set in $VIMRUNTIME/archlinux.vim (usually just
" /usr/share/vim/vimfiles/archlinux.vim) and sourced by the call to :runtime
" you can find below.  If you wish to change any of those settings, you should
" do it in this file (/etc/vimrc), since archlinux.vim will be overwritten
" everytime an upgrade of the vim packages is performed.  It is recommended to
" make changes after sourcing archlinux.vim since it alters the value of the
" 'compatible' option.

" This line should not be removed as it ensures that various options are
" properly set to work with the Vim-related packages.
runtime! archlinux.vim

" If you prefer the old-style vim functionalty, add 'runtime! vimrc_example.vim'
" Or better yet, read /usr/share/vim/vim80/vimrc_example.vim or the vim manual
" and configure vim to your own liking!

" do not load defaults if ~/.vimrc is missing
"let skip_defaults_vim=1
" Set stuffs
autocmd FileType cpp source ~/.vim/cpp.vim
autocmd FileType c source ~/.vim/cpp.vim
autocmd FileType h source ~/.vim/cpp.vim
"augroup project
"    autocmd!
"    autocmd BufRead,BufNewFile *.h,*.c,*.cpp set filetype=c.doxygen
"augroup END

set wildmenu
set nu
set relativenumber
set nocompatible
set laststatus=2
set exrc
set secure
"set runtimepath^=/home/junk/.vim/bundle/YouCompleteMe
set rtp+=/home/junk/.vim/bundle/c.vim
"set rtp+=/home/junk/.vim/bundle/Vundle.vim
set tabstop=4
set smarttab
set shiftwidth=4
set autoindent
set smartindent
set tabstop=4
set shiftwidth=4
set expandtab
set textwidth=120
set t_Co=256
set showmatch
set omnifunc=syntaxcomplete#Complete
let g:python3_host_prog='/usr/bin/python3'
let g:python_host_prog='/usr/bin/python'
let g:C_UseTool_cmake        = 'yes'
let g:C_UseTool_doxygen      = 'yes'
syntax on

" Vundle plugin manager
"call vundle#begin()

"Plugin 'VundleVim/Vundle.vim'
"Plugin 'vim-scripts/c.vim'
"Plugin 'scrooloose/nerdtree'
"Plugin 'roxma/ncm-clang'
"
"call vundle#end()
filetype plugin indent on

" Mappings
map <C-n> :NERDTreeToggle<CR>