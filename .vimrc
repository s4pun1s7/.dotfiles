" Misc {{{
"
filetype off
filetype plugin indent on

" deal with colors
if !has('gui_running')
	set t_Co=256
endif

" Colors
set termguicolors
set background=dark
colorscheme base16-solarized-dark
hi Normal ctermbg=NONE

let mapleader = ","
set path+=**
set shell=bash
set lazyredraw
set nocursorcolumn
set regexpengine=1
set synmaxcol=256
set colorcolumn=110
highlight ColorColumn ctermbg=darkgray

" Misc }}}

" Plugins {{{

call plug#begin('~/.vim/plugged')

" VIM enhancements
Plug 'ciaranm/securemodelines'
Plug 'justinmk/vim-sneak'

" GUI enhancements
Plug 'itchyny/lightline.vim'
Plug 'w0rp/ale'
Plug 'machakann/vim-highlightedyank'
Plug 'andymass/vim-matchup'
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'tpope/vim-fugitive'
Plug 'chriskempson/base16-vim'

" Fuzzy finder
Plug 'airblade/vim-rooter'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

Plug 'ncm2/ncm2'
Plug 'roxma/nvim-yarp'

" Completion plugins
Plug 'ncm2/ncm2-bufword'
Plug 'ncm2/ncm2-tmux'
Plug 'ncm2/ncm2-path'

" Syntactic language support
Plug 'cespare/vim-toml'
Plug 'rust-lang/rust.vim'
Plug 'dag/vim-fish'
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'

call plug#end()

" Plugins }}}

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
noremap <leader>s :Rg
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
nnoremap <leader>html :0read ~/Templates/skel.html<CR>6j3wa
nnoremap <leader>php :0read ~/Templates/skel.php<CR>ggo

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

" <leader>s for Rg search
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)

function! s:list_cmd()
  let base = fnamemodify(expand('%'), ':h:.:S')
  return base == '.' ? 'fd --type file --follow' : printf('fd --type file --follow | proximity-sort %s', expand('%'))
endfunction

command! -bang -nargs=? -complete=dir Files
  \ call fzf#vim#files(<q-args>, {'source': s:list_cmd(),
  \                               'options': '--tiebreak=index'}, <bang>0)

" functions }}}

" Settings {{{

let g:fzf_layout = { 'down': '~20%' }
let g:secure_modelines_allowed_items = [
                \ "textwidth",   "tw",
                \ "softtabstop", "sts",
                \ "tabstop",     "ts",
                \ "shiftwidth",  "sw",
                \ "expandtab",   "et",   "noexpandtab", "noet",
                \ "filetype",    "ft",
                \ "foldmethod",  "fdm",
                \ "readonly",    "ro",   "noreadonly", "noro",
                \ "rightleft",   "rl",   "norightleft", "norl",
                \ "colorcolumn"
                \ ]

"let g:lightline = {
"      \ 'component_function': {
"      \   'filename': 'LightlineFilename',
"      \ },
"\ }

let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 1
let g:ale_lint_on_save = 0
let g:ale_lint_on_enter = 0
let g:ale_virtualtext_cursor = 1
let g:ale_rust_rls_config = {
	\ 'rust': {
		\ 'all_targets': 1,
		\ 'build_on_save': 1,
		\ 'clippy_preference': 'on'
	\ }
\ }

let g:ale_rust_rls_toolchain = ''
let g:ale_linters = {'rust': ['rls']}
highlight link ALEWarningSign Todo
highlight link ALEErrorSign WarningMsg
highlight link ALEVirtualTextWarning Todo
highlight link ALEVirtualTextInfo Todo
highlight link ALEVirtualTextError WarningMsg
highlight ALEError guibg=None
highlight ALEWarning guibg=None
let g:ale_sign_error = "✖"
let g:ale_sign_warning = "⚠"
let g:ale_sign_info = "i"
let g:ale_sign_hint = "➤"

" Completion
let g:python3_host_prog="/usr/bin/python3"
autocmd BufEnter * call ncm2#enable_for_buffer()
set completeopt=noinsert,menuone,noselect
" tab to select
" and don't hijack my enter key
inoremap <expr><Tab> (pumvisible()?(empty(v:completed_item)?"\<C-n>":"\<C-y>"):"\<Tab>")
inoremap <expr><CR> (pumvisible()?(empty(v:completed_item)?"\<CR>\<CR>":"\<C-y>"):"\<CR>")

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
