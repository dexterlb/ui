call plug#begin('~/.config/nvim/plugged')
Plug 'dpc/vim-smarttabs'
Plug 'roryokane/detectindent'
Plug 'AndrewRadev/sideways.vim'
Plug 'junegunn/fzf.vim'
Plug 'terryma/vim-multiple-cursors'
Plug 'dyng/ctrlsf.vim'
Plug 'luochen1990/rainbow'
Plug 'dexterlb/vim-dim'

" language-specific
Plug 'isovector/cornelis'
Plug 'mattn/vim-goimports'
Plug 'neovimhaskell/nvim-hs.vim'

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

colorscheme dim

" while checkalign might offer nice functionality, it causes the cursor to go
" to the end of the line each time when we press enter, so keep it disabled
let g:ctab_disable_checkalign=1

" tab/indent options
set tabstop=4
set shiftwidth=4
set shiftround      " snap to indent grid
set autoindent
set copyindent      " makes autoindent just copy leading whitespace from prev line
set nosmartindent
set nocindent
set smarttab

" automatic detection using heuristics
augroup DetectIndent
    autocmd!
    autocmd BufReadPost *  DetectIndent
augroup END

" no auto indent based on filetype
filetype indent off
" load the filetype plugin
filetype plugin on

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

" who uses backups nowadays?!
set nobackup

set cursorline      " highlight some stuff
set guicursor=
" set colorcolumn=80

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

" these come from the vim-dim colour scheme
noremap <leader>f :Files<cr>
noremap <leader>i :GFiles<cr>
noremap <leader>p :Buffers<cr>

" status line
set laststatus=0

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

set completeopt-=preview

" Language specific settings:
" Golang
let g:goimports = 1
let g:go_fmt_command = "goimports"
let g:goimports_simplify = 1

" Agda
let g:cornelis_use_global_binary = 1
autocmd FileType agda call AgdaFiletype()
function! AgdaFiletype()
    nnoremap <buffer> <leader>l :CornelisLoad<CR>
    nnoremap <buffer> <leader>m :CornelisQuestionToMeta<CR>
    nnoremap <buffer> <leader>r :CornelisRefine<CR>
    nnoremap <buffer> <leader>c :CornelisMakeCase<CR>
    nnoremap <buffer> <leader>, :CornelisTypeContext<CR>
    nnoremap <buffer> <leader><leader>, :CornelisTypeContext Normalised<CR>
    nnoremap <buffer> <leader>d :CornelisTypeInfer<CR>
    nnoremap <buffer> <leader><leader>d :CornelisTypeInfer Normalised<CR>
    nnoremap <buffer> <leader>. :CornelisTypeContextInfer<CR>
    nnoremap <buffer> <leader><leader>. :CornelisTypeContextInfer Normalised<CR>
    nnoremap <buffer> <leader>g :CornelisGive<CR>

    nnoremap <buffer> <leader>n :CornelisSolve<CR>
    nnoremap <buffer> <leader>a :CornelisAuto<CR>
    nnoremap <buffer> <leader>h :CornelisGoToDefinition<CR>
    nnoremap <buffer> <leader>[ :CornelisPrevGoal<CR>
    nnoremap <buffer> <leader>] :CornelisNextGoal<CR>
    nnoremap <buffer> <C-A>     :CornelisInc<CR>
    nnoremap <buffer> <C-X>     :CornelisDec<CR>
endfunction

" LFE
autocmd BufNewFile,BufRead *.lfe set syntax=lisp
autocmd BufNewFile,BufRead *.l set syntax=lisp
" let g:rainbow_active = 1

function! SteamLocomotive()
    terminal sl
endfunction
