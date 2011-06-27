" Initially built from Fedora base template
if v:lang =~ "utf8$" || v:lang =~ "UTF-8$"
    set fileencodings=ucs-bom,utf-8,latin1
endif

" Change the mapleader from \ to , #Note that this needs to be before
" everything
let mapleader=","

set nocompatible
set bs=indent,eol,start     " allow backspacing over everything in insert mode
set viminfo='20,\"50    " read/write a .viminfo file, don't store more
            " than 50 lines of registers
set ruler       " show the cursor position all the time
set ignorecase
" filetype plugin indent on

set wildmode=full
set wildmenu

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""" Tabs """""""""""""""""""""""""""""""""""""""""""""""

nmap <silent> <leader>n :tabnew<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""" Indentation """"""""""""""""""""""""""""""""""""""""

set expandtab
set tabstop=4     " a tab is 4 spaces
set softtabstop=4 " so deletion at an initial tab will remove 4 spaces
set shiftwidth=4  " number of spaces to use for autoindenting
set shiftround    " use multiple of shiftwidth when indenting with '<' and '>'
set autoindent    " always set autoindenting on
"set copyindent    " copy the previous indentation on autoindenting
set smartindent

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""" NERDTree """""""""""""""""""""""""""""""""""""""""""

nmap <silent> <leader>h :NERDTreeToggle<CR>
nnoremap <F4> :NERDTreeToggle<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""" Gundo """"""""""""""""""""""""""""""""""""""""""""""

nnoremap <silent> <leader>g :GundoToggle<CR>
nnoremap <F5> :GundoToggle<CR>

let g:gundo_right = 1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""" From nvie.com/posts/how-i-boosted-my-vim """""""""""

"set nowrap     " don't wrap lines
set hidden      " hide buffers instead of closing them
set showmatch   " set show matching parenthesis
set incsearch   " show search matches as you type

set history=1000         " remember more commands and search history
set undolevels=1000      " use many muchos levels of undo
set wildignore=*.swp,*.bak,*.pyc,*.class
set title                " change the terminal's title
set noerrorbells         " don't beep

set nobackup

set list
set listchars=tab:»·,trail:·,extends:#,nbsp:·

set pastetoggle=<F2>     " toggle paste mode

" replaces : with ;... so you don't need SHIFT all the time
nnoremap ; :

" Use Q for formatting the current paragraph (or selection)
vmap Q gq
nmap Q gqap

" Use pathogen to easily modify the runtime path to include all
" plugins under the ~/.vim/bundle directory
call pathogen#helptags()
call pathogen#runtime_append_all_bundles()


" Quickly edit/reload the vimrc file
nmap <silent> <leader>ev :e $MYVIMRC<CR>
nmap <silent> <leader>sv :so $MYVIMRC<CR>

" Make moving cursor not jump between newline-delimited lines, but instead do
" so for visual lines
nnoremap j gj
nnoremap k gk


" Easy window navigation
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

nmap <silent> <leader>/ :nohlsearch<CR>

"" nvie.com """""""""""""""""""""""""""""""""""""""""""""""""""

" Only do this part when compiled with support for autocommands
if has("autocmd")
    augroup fedora
    autocmd!
    " In text files, always limit the width of text to 78 characters
    " autocmd BufRead *.txt set tw=78
    " When editing a file, always jump to the last cursor position
    autocmd BufReadPost *
    \ if line("'\"") > 0 && line ("'\"") <= line("$") |
    \   exe "normal! g'\"" |
    \ endif
    " don't write swapfile on most commonly used directories for NFS mounts or USB sticks
    autocmd BufNewFile,BufReadPre /media/*,/mnt/* set directory=~/tmp,/var/tmp,/tmp
    " start with spec file template
    autocmd BufNewFile *.spec 0r /usr/share/vim/vimfiles/template.spec
    augroup END
endif

" Better cscope integration
if has("cscope") && filereadable("/usr/bin/cscope")
    set csprg=/usr/bin/cscope
    set csto=0
    set cst
    set nocsverb
    " add any database in current directory
    if filereadable("cscope.out")

        cs add cscope.out
    " else add database pointed to by environment
    elseif $CSCOPE_DB != ""
        cs add $CSCOPE_DB
    endif
    set csverb
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
    syntax enable
    set background=dark
    colorscheme solarized
    let g:solarized_termtrans=1
"    let g:solarized_italic=1
"    let g:solarized_bold=1
"    let g:solarized_underline=1
    set hlsearch
endif

if &term=="xterm"
    set t_Co=8
    set t_Sb=^[[4%dm
    set t_Sf=^[[3%dm
endif

" Don't wake up system with blinking cursor:
" http://www.linuxpowertop.org/known.php
let &guicursor = &guicursor . ",a:blinkon0"
