" Misc {{{
execute pathogen#infect()
execute pathogen#helptags()

filetype on
filetype plugin on

set path+=**
set background=dark
set shell=bash
set lazyredraw
set nocursorcolumn
set regexpengine=1
set synmaxcol=256
set colorcolumn=110

highlight ColorColumn ctermbg=darkgray

" Misc }}}

" Set {{{
set smartcase
set noignorecase
set scroll=10
set nocompatible
set nobackup
set nowritebackup
set noswapfile
set showcmd
set autowrite
set nowrap
set wrapscan
set wildmenu
set scrolljump=1
set scrolloff=8
set clipboard=unnamedplus
set listchars=trail:·
set timeoutlen=500
set wildignore+=.svn,CVS,.git 
set wildignore+=*.o,*.a,*.class,*.mo,*.la,*.so,*.lo,*.la,*.obj,*.pyc
set wildignore+=*.exe,*.zip,*.jpg,*.png,*.gif,*.jpeg 

" Statusline
set statusline=
set statusline+=%#PmenuSel#
set statusline+=%#LineNr#
set statusline+=\ %F
set statusline+=%m\
set statusline+=%=
set statusline+=%#CursorColumn#
set statusline+=\ %y
set statusline+=\ %{&fileencoding?&fileencoding:&encoding}
set statusline+=\[%{&fileformat}\]
set statusline+=\ %p%%
set statusline+=\ %l:%c
set statusline+=\/\%L
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

" Numbers
set number
set numberwidth=5
set relativenumber

" Indents
set tabstop=4
set shiftwidth=4
set autoindent
set smartindent
set noexpandtab

" Folding
set foldmethod=manual
set foldmarker=region,endregion
set foldlevelstart=1
set foldtext=FoldText()

" SET }}}

" Maps {{{
nnoremap <Left>		:echoerr "Use h"<CR>
nnoremap <Right>	:echoerr "Use l"<CR>
nnoremap <Up>		:echoerr "Use k"<CR>
nnoremap <Down>		:echoerr "Use j"<CR>
nnoremap / /\V\c
nnoremap J 25jzz
nnoremap K 25kzz
nnoremap n nzz
nnoremap N Nzz
nnoremap <leader>fr :call RenameCurrentFile()<cr>
nnoremap <leader>fm :call MoveCurrentFile()<cr>
nnoremap <silent> <leader>fD :call delete(expand('%')) \| bdelete!<CR>
nnoremap <C-n> :NERDTreeToggle<CR><C-W>=
nnoremap zN zR
nnoremap H 0
nnoremap L $
nnoremap ,html :0read ~/Templates/skel.html<CR>6j3wa
nnoremap ,php :0read ~/Templates/skel.php<CR>ggo

inoremap <silent><expr> jk getline('.') =~ '^\s\+$' && empty(&buftype) ? '<ESC>:call setline(line("."), "")<CR>' : '<ESC>'
inoremap {      {}<Left>
inoremap {<CR>  {<CR>}<Esc>O
inoremap {{     {
inoremap {}     {}
" Maps }}}

" Functions {{{
function! FoldText()
	return getline(v:foldstart)
endfunction

function! MoveCurrentFile()
    let old_destination = expand('%:p:h')
    let filename = expand('%:t')
    call inputsave()
    let new_destination = input('New destination: ', expand('%:p:h'), 'file')
    call inputrestore()
    if new_destination != '' && new_destination != old_destination
        exec ':saveas ' . new_destination . '/' . filename
        exec ':silent !rm ' . old_destination . '/' . filename
        redraw!
    endif
endfunction

function! RenameCurrentFile()
    let old_name = expand('%')
    call inputsave()
    let new_name = input('New file name: ')
    call inputrestore()
    if new_name != '' && new_name != old_name
        if expand('%:e') != '' && new_name !~ '\.'
            exec ':saveas ' . expand('%:h'). '/' . new_name . '.' . expand('%:e')
        else
            exec ':saveas ' . expand('%:h'). '/' . new_name
        endif
        call delete(old_name)
        redraw!
        exec ':e!'
    endif
endfunction
" functions }}}

" Settings {{{

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

let g:C_UseTool_cmake    = 'yes' 
let g:C_UseTool_doxygen = 'yes' 

" Settings }}}

" Augroup {{{

if system("uname -s") =~ "Linux"
    augroup linuxAutoCommands
        au!
        " Affects lag
        au BufEnter,FocusGained,InsertLeave,WinEnter * if &nu | set relativenumber   | endif
        au BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu | set norelativenumber | endif

        " remain with clipboard after closing
        au VimLeave * call system("xclip -r -o -sel clipboard | xclip -r -sel clipboard")
    augroup END
endif

augroup folding
    au!

    au FileType vim setl foldlevel=0 |
                \ setl foldmarker={{{,}}} |
                \ setl foldmethod=marker
augroup END

augroup line_return
	au!
	au BufReadPost *
		\ if line("'\"") > 0 && line("'\"") <= line("$") |
		\	execute 'normal! g`"zvzz' |
		\ endif
augroup END

augroup web
	au!

	au FileType html setlocal tabstop=2 |
		\ set softtabstop=2 |
		\ set expandtab |
		\ set foldenable |
		\ set foldlevelstart=1 |
		\ set foldmethod=indent |
		\ set foldnestmax=10 |
		\ set smartindent
	au FileType css setlocal expandtab shiftwidth=4 tabstop=4 softtabstop=4

augroup END


" Augroup }}} 
