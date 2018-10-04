call plug#begin('~/.config/nvim/plugged')

Plug 'AndrewRadev/sideways.vim'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'terryma/vim-multiple-cursors'
Plug 'peterhoeg/vim-qml'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'tpope/vim-fugitive'
Plug 'iCyMind/NeoSolarized'
Plug 'dyng/ctrlsf.vim'
Plug 'thaerkh/vim-workspace'

Plug 'sheerun/vim-polyglot'

function! DoRemote(arg)
  UpdateRemotePlugins
endfunction
" Plug 'Shougo/deoplete.nvim', { 'do': function('DoRemote') }
" Plug 'zchee/deoplete-go'
" Plug 'zchee/deoplete-clang'

call plug#end()

let mapleader=" "
nnoremap ; :
noremap F ;

" preserve buffers (don't require saving before switching buffers)
set hidden

set nowrap
set number

" for when I do turn on wrapping - make hjkl act naturally
nnoremap j gj
nnoremap k gk

" navigation
noremap <A-h> <C-w>h
noremap <A-j> <C-w>j
noremap <A-k> <C-w>k
noremap <A-l> <C-w>l

noremap <C-h> :bp<cr>
noremap <C-j> :bp<cr>
noremap <C-l> :bn<cr>
noremap <C-k> :bp<cr>
noremap <C-right> :bn<cr>
noremap <C-left> :bp<cr>

" colour schemes
colorscheme NeoSolarized
noremap <F5> :set background=dark<cr>
noremap <F6> :set background=light<cr>

set background=dark

" tab/indent options
set tabstop=4
set shiftwidth=4
set shiftround		" snap to indent grid
set autoindent
set copyindent
set smarttab
set expandtab		" tabs -> spaces
filetype plugin indent on	" smart indentation based on filetype

" show matching braces
set showmatch

set ignorecase

" some sensible defaults
set history=1024
set undolevels=1024
set wildignore=*.swp,*.bak,*.pyc,*.class,*.hi
set title	" change terminal's title

" silence!
set visualbell
set noerrorbells

" who uses backups anymore?!
set nobackup

set cursorline      " highlight some stuff
set guicursor=
set colorcolumn=80

" remove search highlight
nnoremap <A-/> :noh<CR>

" When pressing <leader>cd switch to the directory of the open buffer
noremap <leader>cd :cd %:p:h<cr>

" Close the current buffer
noremap <leader>q :Bclose<cr>
command! Bclose call <SID>BufcloseCloseIt()
function! <SID>BufcloseCloseIt()
   let l:currentBufNum = bufnr("%")
   let l:alternateBufNum = bufnr("#")

   if buflisted(l:alternateBufNum)
     buffer #
   else
     bnext
   endif

   if bufnr("%") == l:currentBufNum
     new
   endif

   if buflisted(l:currentBufNum)
     execute("bdelete! ".l:currentBufNum)
   endif
endfunction

" Close all the buffers
noremap <leader>ba :1,300 bd!<cr>

noremap <leader>< :SidewaysLeft<cr>
noremap <leader>> :SidewaysRight<cr>

" CtrlP
let g:ctrlp_map = '<leader>t'
let g:ctrlp_cmd = 'CtrlPMixed'
noremap <leader>f :CtrlP<cr>
noremap <leader>p :CtrlPBuffer<cr>

" Airline

let g:airline_left_sep = ''
let g:airline_right_sep = ''
let g:airline_powerline_fonts = 0
let g:airline_theme = "solarized"

" strip trailing whitespace
fun! <SID>StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun
autocmd FileType * autocmd BufWritePre <buffer> :call <SID>StripTrailingWhitespaces()

" ctrlsf settings
" focus on the ctrlsf window when it's done
let g:ctrlsf_auto_focus = {
    \ "at" : "done"
    \ }

" search from project root by default (finds .git)
" currently trying out current dir, just open vim in project root
let g:ctrlsf_default_root = 'cwd'

" use compact mode by default
let g:ctrlsf_default_view_mode = 'compact'

" maps to not conflict with my binds
" let g:ctrlsf_mapping = {
"     \ "open"    : ["<CR>", "o"],
"     \ "openb"   : "O",
"     \ "split"   : "<C-x>",
"     \ "vsplit"  : "<C-v>",
"     \ "tab"     : "<C-t>",
"     \ "tabb"    : "T",
"     \ "popen"   : "p",
"     \ "popenf"  : "P",
"     \ "quit"    : "q",
"     \ "next"    : "n",
"     \ "prev"    : "N",
"     \ "pquit"   : "q",
"     \ "loclist" : "",
"     \ "chgmode" : "M",
"     \ "stop"    : "<C-C>",
"     \ }

" open window on the right
let g:ctrlsf_position = 'right'

nmap <space>o <Plug>CtrlSFCwordExec
vmap <space>o <Plug>CtrlSFVwordExec

" fugitive git bindings
nnoremap <leader>ga :Git add %:p<CR><CR>
nnoremap <leader>gs :Gstatus<CR>
nnoremap <leader>gc :Gcommit -v -q<CR>
nnoremap <leader>gca :Gcommit -v -a -q<CR>
nnoremap <leader>gt :Gcommit -v -q %:p<CR>
nnoremap <leader>gd :Gdiff<CR>
nnoremap <leader>ge :Gedit<CR>
nnoremap <leader>gr :Gread<CR>
nnoremap <leader>gw :Gwrite<CR><CR>
nnoremap <leader>gl :silent! Glog<CR>:bot copen<CR>
nnoremap <leader>gp :Ggrep<Space>
nnoremap <leader>gm :Gmove<Space>
nnoremap <leader>gb :Git branch<Space>
nnoremap <leader>go :Git checkout<Space>
nnoremap <leader>gps :Dispatch! git push<CR>
nnoremap <leader>gpl :Dispatch! git pull<CR>

" Session management
nnoremap <leader>s :ToggleWorkspace<CR>
let g:workspace_session_disable_on_args = 1
let g:workspace_autosave = 0
set ssop=blank,buffers,sesdir,folds,localoptions,tabpages,winpos,winsize

" Use deoplete.
let g:deoplete#enable_at_startup = 1
let g:deoplete#disable_auto_complete = 1
inoremap <silent><expr> <C-n>
\ pumvisible() ? "\<C-n>" :
\ deoplete#mappings#manual_complete()

set completeopt-=preview

" Language specific settings:
" Golang
let g:go_fmt_command = "goimports"

noremap <leader>m :GoMetaLinter<cr>

" Rust
let g:rustfmt_autosave = 1
