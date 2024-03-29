" Props go to:
"   * nvie.com/posts/how-i-boosted-my-vim
"   * Fedora base .vimrc


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""" HEADER """""""""""""""""""""""""""""""""""""""""""""
" Change the mapleader from \ to , #Note that this needs to be before everything
let mapleader=","               " Make life easier.

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""" Pre-plugins"""""""""""""""""""""""""""""""""""""""""

" Put everything in a consistent state for plugin enabling
set nocompatible    " Because... THIS. IS. VIM.
filetype off
syntax off

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""" Vundle """""""""""""""""""""""""""""""""""""""""""""

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim/
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

" Visual
Plugin 'altercation/vim-colors-solarized'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'google/vim-searchindex'
Plugin 'leafgarland/typescript-vim'
Plugin 'pangloss/vim-javascript'
Plugin 'jonsmithers/vim-html-template-literals'
Plugin 'mhinz/vim-signify'
Plugin 'tpope/vim-markdown'

" Movement extension
Plugin 'easymotion/vim-easymotion'
Plugin 'tpope/vim-unimpaired'

" Code interactions
Plugin 'tpope/vim-commentary'
Plugin 'ycm-core/YouCompleteMe'

Plugin 'ternjs/tern_for_vim'

" Full-on Plugins
Plugin 'scrooloose/nerdtree'
Plugin 'simnalamburt/vim-mundo'

" tmux integrations
Plugin 'tmux-plugins/vim-tmux-focus-events'

" Misc
Plugin 'tpope/vim-sensible'
Plugin 'tpope/vim-repeat'
Plugin 'ConradIrwin/vim-bracketed-paste'

call vundle#end()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""" Post-plugins """""""""""""""""""""""""""""""""""""""

" All Plugins are done, let's make this human-useable
filetype plugin indent on
syntax on

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""" Change Basic Behavior """"""""""""""""""""""""""""""

set bs=indent,eol,start         " Allow backspacing over everything in insert
                                " mode.
set ignorecase smartcase        " Search is now case-insensitive by default, but
                                " case-sensitive if it contains an upper-case
                                " symbol.
set formatoptions+=j            " Allow removal of comment characters and such
                                " when merging lines with J.
set wildmenu                    " Use the wildmenu when doing "open" completions
set wildignore=*.swp,*.bak,*.pyc,*.class
set wildmode=list:longest,full  " Default search to both show the completion
                                " list and auto-complete to longest
                                " simultaneously.
                                "
set nobackup
set hidden               " hide buffers instead of closing them
set autoread             " if the file has been changed outside vim and not
                         " inside, update the buffer to the new file.

set history=1000         " remember more commands and search history
set undolevels=1000      " use many muchos levels of undo
set noerrorbells         " don't beep
set pastetoggle=<F2>     " toggle paste mode


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""" Change Visual Behavior """""""""""""""""""""""""""""

set title                " Change the terminal's title.

set showmatch            " Set show matching parenthesis.

set incsearch            " Show search matches as you type.
set hlsearch             " highlight the last used search pattern.
nohlsearch               " Clear current highlight so 'set hlsearch' doesn't
                         " actually highlight anything _now_ if .vimrc
                         " is ever re-sourced.

set scrolloff=1          " Show at least one line above/below cursor.

set showcmd              " Show command-mode commands cleanly in the lower right
                         " e.g. when using c, r, etc., indicate those are in an
                         " active state while executing.

set list
set listchars=tab:»·,trail:·,extends:#,nbsp:·  " Show me tabs and trailing
                                               " whitespace

set ruler                " show the cursor position all the time

set relativenumber       " Show relative line-number offset from current line
set numberwidth=2        " Reduce gutter size as much as is reasonable

set textwidth=80         " Default to 80 character text width
" Help with line-length visualization.
let &colorcolumn = join(map(range(1,1000), '"+" . v:val'), ",")

" Don't wake up system with blinking cursor:
" http://www.linuxpowertop.org/known.php
set guicursor += ",a:blinkon0"

colorscheme solarized
let g:solarized_termtrans=1 " Solarized otherwise doesn't respect transparency

let g:airline#extensions#tabline#enabled=1 " Enable Airline control of tabline
let g:airline#extensions#tabline#formatter='jsformatter'

set background=dark  " Dark like cave.

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

" INSERT A @#$%ing NEWLINE WITHOUT ENTERING INSERT MODE
" nnoremap <silent> <CR> o<Esc>
" nnoremap <silent> <S-CR> O<Esc>

" Easy window navigation
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

" Easy tab navigation by number
noremap <leader>1 1gt
noremap <leader>2 2gt
noremap <leader>3 3gt
noremap <leader>4 4gt
noremap <leader>5 5gt
noremap <leader>6 6gt
noremap <leader>7 7gt
noremap <leader>8 8gt
noremap <leader>9 9gt
noremap <leader>0 :tablast<cr>

" Insert TODO(alex) on next line
map <leader>o oTODO(alex):<Esc>gcc$a

" Toggle to last active tab

au TabLeave * let g:lasttab = tabpagenr()
nnoremap <silent> <leader>- :exe "tabn ".g:lasttab<cr>
vnoremap <silent> <leader>- :exe "tabn ".g:lasttab<cr>

nmap <silent> <leader>/ :nohlsearch<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""" Markdown """""""""""""""""""""""""""""""""""""""""""

" for 'tpope/vim-markdown'
let g:markdown_fenced_languages = ['rust', 'python', 'java', 'javascript', 'typescript']

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""" Latex """"""""""""""""""""""""""""""""""""""""""""""

" Because IMAP steals <C-j> if we don't bind it ahead
map <C-space> <Plug>IMAP_JumpForward

let g:Tex_FormatDependency_pdf='dvi,pdf'
let g:Tex_CompileRule_pdf = 'dvipdf $*.dvi'

let g:Tex_ViewRule_pdf='evince'
let g:Tex_DefaultTargetFormat='pdf'
"let g:Tex_CompileRule_pdf = 'pdflatex -interaction=nonstopmode $*'

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
""""""""" YouCompleteMe """"""""""""""""""""""""""""""""""""""

" When YCM opens a preview window, show syntax highlighting for rustdoc
function PreviewSyntax() abort
    if &previewwindow && getbufvar('#', "&filetype") == 'rust'
        setlocal syntax=markdown
    endif
endfunction
autocmd WinEnter * call PreviewSyntax()

let g:ycm_rust_toolchain_root = expand('~') . '/.cargo/'
nmap <silent> <leader>t :YcmCompleter GoTo<CR>
nmap <silent> <leader>c :YcmCompleter GetDoc<CR>
nmap <silent> <leader>r :YcmCompleter GoToReferences<CR>
nmap <silent> <leader>u :YcmCompleter GoToCallers<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""" Mundo """"""""""""""""""""""""""""""""""""""""""""""

nnoremap <silent> <leader>g :MundoToggle<CR>
nnoremap <F5> :MundoToggle<CR>

let g:mundo_right = 1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""" Language Specific Configuration """"""""""""""""""""

" YAML
au! BufNewFile,BufReadPost *.{yaml,yml} set filetype=yaml foldmethod=indent
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

" TSX files
au! BufNewFile,BufReadPost *.{tsx} set filetype=typescript foldmethod=indent
autocmd FileType typescript setlocal ts=2 sts=2 sw=2 expandtab

" Go
au! BufNewFile,BufReadPost *.{go} set filetype=go foldmethod=indent
autocmd FileType go setlocal ts=4 sts=4 sw=4 noexpandtab

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""" Misc """""""""""""""""""""""""""""""""""""""""""""""

" Quickly edit/reload the vimrc file
nmap <silent> <leader>ev :e $MYVIMRC<CR>
nmap <silent> <leader>sv :so $MYVIMRC<CR>

set viminfo='20,\"50    " read/write a .viminfo file, don't store more
                        " than 50 lines of registers

au FocusGained,BufEnter * :checktime " trigger autoread when changing vim
                                     " buffers

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

" Select a position from the jump list.
function! GotoJump()
  jumps
  let j = input("Please select your jump: ")
  if j != ''
    let pattern = '\v\c^\+'
    if j =~ pattern
      let j = substitute(j, pattern, '', 'g')
      execute "normal " . j . "\<c-i>"
    else
      execute "normal " . j . "\<c-o>"
    endif
  endif
endfunction
nmap <Leader>j :call GotoJump()<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""" Local Configurations """""""""""""""""""""""""""""""
source ~/.local/dotfiles/.vimrc

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
