" Props go to:
"   * nvie.com/posts/how-i-boosted-my-vim
"   * Fedora base .vimrc


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""" HEADER """""""""""""""""""""""""""""""""""""""""""""

" Change the mapleader from \ to , #Note that this needs to be before everything
let mapleader=","

" Use pathogen to easily modify the runtime path to include all
" plugins under the ~/.vim/bundle directory
call pathogen#helptags()
call pathogen#runtime_append_all_bundles()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""" Change Basic Behavior """"""""""""""""""""""""""""""

if v:lang =~ "utf8$" || v:lang =~ "UTF-8$"
    set fileencodings=ucs-bom,utf-8,latin1
endif

set nocompatible                " Because THIS. IS. VIM.
set bs=indent,eol,start         " Allow backspacing over everything in insert
                                " mode.
set ignorecase                  " Search is now case-insensitive.
set formatoptions+=j            " Allow removal of comment characters and such
                                " when merging lines with J.
set wildmenu                    " Use the wildmenu when doing "open" completions
set wildignore=*.swp,*.bak,*.pyc,*.class
set wildmode=list:longest,full  " Default search to both show the completion
                                " list and auto-complete to longest
                                " simultaneously.
set hidden      " hide buffers instead of closing them
set history=1000         " remember more commands and search history
set nobackup
set undolevels=1000      " use many muchos levels of undo
set noerrorbells         " don't beep
set pastetoggle=<F2>     " toggle paste mode

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""" Change Visual Behavior """""""""""""""""""""""""""""

set title                " change the terminal's title
set showmatch   " set show matching parenthesis
set incsearch   " show search matches as you type

set list
set listchars=tab:»·,trail:·,extends:#,nbsp:·  " Show me tabs and trailing
                                               " whitespace

set ruler       " show the cursor position all the time

let &colorcolumn=join(range(81,999),",")  " Help with line-length visualization.

" Don't wake up system with blinking cursor:
" http://www.linuxpowertop.org/known.php
let &guicursor = &guicursor . ",a:blinkon0"

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
    syntax enable
    set background=dark
    let g:solarized_termtrans=1
    colorscheme solarized
"    let g:solarized_italic=1
"    let g:solarized_bold=1
"    let g:solarized_underline=1
    set hlsearch
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""" Core Remappings """"""""""""""""""""""""""""""""""""

" Give an alternative for having to stretch for ESC. Suggestion by Val Markovic.
inoremap jk <Esc>

" Thank you Val Markovic for pointing out I wasn't doing this in visual mode
" In normal mode, we use : much more often than ; so lets swap them.
" WARNING: this will cause any "ordinary" map command without the "nore" prefix
" that uses ":" to fail. For instance, "map <f2> :w" would fail, since vim will
" read ":w" as ";w" because of the below remappings. Use "noremap"s in such
" situations and you'll be fine.
nnoremap ; :
"nnoremap : ;
vnoremap ; :
vnoremap : ;

" Make moving cursor not jump between newline-delimited lines, but instead do
" so for visual lines
nnoremap j gj
nnoremap k gk

" Because IMAP steals <C-j> if we don't bind it ahead
map <C-space> <Plug>IMAP_JumpForward

" Easy window navigation
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

nmap <silent> <leader>/ :nohlsearch<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""" Latex """"""""""""""""""""""""""""""""""""""""""""""

let g:Tex_ViewRule_pdf='evince'
let g:Tex_DefaultTargetFormat='pdf'
let g:Tex_CompileRule_pdf = 'pdflatex -interaction=nonstopmode $*'

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


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
""""""""" Misc """""""""""""""""""""""""""""""""""""""""""""""

" Quickly edit/reload the vimrc file
nmap <silent> <leader>ev :e $MYVIMRC<CR>
nmap <silent> <leader>sv :so $MYVIMRC<CR>

set viminfo='20,\"50    " read/write a .viminfo file, don't store more
                        " than 50 lines of registers

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

if &term=="xterm"
    set t_Co=8
    set t_Sb=^[[4%dm
    set t_Sf=^[[3%dm
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
