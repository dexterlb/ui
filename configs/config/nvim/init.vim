call plug#begin('~/.config/nvim/plugged')
Plug 'dpc/vim-smarttabs'
Plug 'roryokane/detectindent'
Plug 'AndrewRadev/sideways.vim'
Plug 'junegunn/fzf.vim'
Plug 'terryma/vim-multiple-cursors'
Plug 'peterhoeg/vim-qml'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'tpope/vim-fugitive'
Plug 'iCyMind/NeoSolarized'
Plug 'morhetz/gruvbox'
Plug 'dyng/ctrlsf.vim'
Plug 'thaerkh/vim-workspace'
Plug 'sheerun/vim-polyglot'
Plug 'mattn/vim-goimports'

function! DoRemote(arg)
    UpdateRemotePlugins
endfunction

call plug#end()

let mapleader=" "
nnoremap ; :
noremap F ;

" allow external vimrc
set exrc

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
colorscheme gruvbox
noremap <F5> :set background=dark<cr>
noremap <F6> :set background=light<cr>
set termguicolors

set background=dark

" while checkalign might offer nice functionality, it causes the cursor to go
" to the end of the line each time when we press enter, so keep it disabled
let g:ctab_disable_checkalign=1

" tab/indent options
set tabstop=4
set shiftwidth=4
set shiftround      " snap to indent grid
set autoindent
set copyindent
set smarttab

" automatic detection using heuristics
augroup DetectIndent
    autocmd!
    autocmd BufReadPost *  DetectIndent
augroup END

" automatic detection based on filetype
filetype plugin indent on

" always use spaces by default
set expandtab       " tabs -> spaces

" don't insert new comments on enter when inside a comment
augroup NoNewComment
    autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
augroup END

" show matching braces
set showmatch

set ignorecase

" some sensible defaults
set history=1024
set undolevels=1024
set wildignore=*.swp,*.bak,*.pyc,*.class,*.hi
set title   " change terminal's title

" silence!
set visualbell
set noerrorbells

" who uses backups anymore?!
set nobackup

set cursorline      " highlight some stuff
set guicursor=
set colorcolumn=80

" highlight search on each typed character
set incsearch

" add search highlight
set hlsearch
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

" CtrlPa
let g:fzf_colors =
            \ { 'fg':      ['fg', 'Normal'],
            \ 'bg':      ['bg', 'Normal'],
            \ 'hl':      ['fg', 'Comment'],
            \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
            \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
            \ 'hl+':     ['fg', 'Statement'],
            \ 'info':    ['fg', 'PreProc'],
            \ 'border':  ['fg', 'Ignore'],
            \ 'prompt':  ['fg', 'Conditional'],
            \ 'pointer': ['fg', 'Exception'],
            \ 'marker':  ['fg', 'Keyword'],
            \ 'spinner': ['fg', 'Label'],
            \ 'header':  ['fg', 'Comment'] }
noremap <leader>f :Files<cr>
noremap <leader>i :GFiles<cr>
noremap <leader>p :Buffers<cr>

" Airline

let g:airline_left_sep = ''
let g:airline_right_sep = ''
let g:airline_powerline_fonts = 0
let g:airline_theme = "gruvbox"

" strip trailing whitespace
function! StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun
augroup AutoStrip
    " autocmd FileType * autocmd BufWritePre <buffer> :call StripTrailingWhitespaces()
augroup END
noremap <F3> :call StripTrailingWhitespaces()<CR>

" highlight trailing whitespace
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()

" bulgarian layout
set langmap=чявертъуиопшщасдфгхйклзьцжбнмЧЯВЕРТЪУИОПШЩАСДФГХЙКЛЗѝЦЖБНМ;`qwertyuiop[]asdfghjklzxcvbnm~QWERTYUIOP{}ASDFGHJKLZXCVBNM

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
nnoremap <leader>gb :Git branch<Space>
nnoremap <leader>go :Git checkout<Space>
nnoremap <leader>gps :Dispatch! git push<CR>
nnoremap <leader>gpl :Dispatch! git pull<CR>

" Session management
nnoremap <leader>s :ToggleWorkspace<CR>
let g:workspace_session_disable_on_args = 1
let g:workspace_autosave = 0
set ssop=blank,buffers,sesdir,folds,localoptions,tabpages,winpos,winsize

set completeopt-=preview

" Language specific settings:
" Golang
let g:goimports = 1
let g:go_fmt_command = "goimports"

noremap <leader>m :GoMetaLinter<cr>

" Rust
let g:rustfmt_autosave = 1

" LFE
autocmd BufNewFile,BufRead *.lfe set syntax=lisp

function! SteamLocomotive()
    terminal sl
endfunction
