" vim/shared/common.vim — portable vim+nvim base.
"
" Sourced by both .vimrc (after Vundle) and nvim init.lua.
" Anything that needs `if has('nvim')` belongs in the native layer instead.

let g:dotfiles_user = get(g:, 'dotfiles_user', $USER)

" === Options ===

set bs=indent,eol,start         " Allow backspacing over everything in insert mode.
set ignorecase smartcase        " Case-insensitive search unless capital is typed.
set formatoptions+=j            " Strip comment leaders when joining lines.
set wildmenu
set wildignore=*.swp,*.bak,*.pyc,*.class
set wildmode=list:longest,full
set nobackup
set hidden                      " Hide buffers instead of closing them.
set autoread                    " Reload files changed outside vim.
set history=1000
set undolevels=1000
set noerrorbells
if exists('+pastetoggle')
    set pastetoggle=<F2>
endif

set title
set showmatch
set incsearch
set hlsearch
nohlsearch
set scrolloff=1
set showcmd
set list
set listchars=tab:»·,trail:·,extends:#,nbsp:·
set ruler
set relativenumber
set numberwidth=2
set textwidth=80

set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
set shiftround
set autoindent
set smartindent

" === Mappings ===

" Easier escape.
inoremap jk <Esc>

" Swap : and ; in normal/visual — colon is used far more than semicolon.
nnoremap ; :
vnoremap ; :
vnoremap : ;

" Move by visual line, not logical line.
nnoremap j gj
nnoremap k gk

" Window navigation.
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

" Tab navigation by number.
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

nmap <silent> <leader>n :tabnew<CR>
nmap <silent> <leader>/ :nohlsearch<CR>

" Insert TODO(<user>) on next line.
execute 'map <leader>o oTODO(' . g:dotfiles_user . '):<Esc>gcc$a'

" Quickly edit/reload the vimrc file.
nmap <silent> <leader>ev :e $MYVIMRC<CR>
nmap <silent> <leader>sv :so $MYVIMRC<CR>

" === Colors ===
" Each native layer owns its own background+colorscheme load. Touching either
" of those here causes nvim's solarized.nvim to re-derive its palette after
" lazy.nvim already initialized it, which clobbers some treesitter links.

" === Autocommands ===

" Restore cursor position on file open.
augroup dotfiles_restore_cursor
    autocmd!
    autocmd BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \   exe "normal! g'\"" |
        \ endif
augroup END

augroup dotfiles_filetypes
    autocmd!
    autocmd BufNewFile,BufReadPost *.{yaml,yml} set filetype=yaml foldmethod=indent
    autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
    autocmd BufNewFile,BufReadPost *.{tsx} set filetype=typescript foldmethod=indent
    autocmd FileType typescript setlocal ts=2 sts=2 sw=2 expandtab
    autocmd BufNewFile,BufReadPost *.{go} set filetype=go foldmethod=indent
    autocmd FileType go setlocal ts=4 sts=4 sw=4 noexpandtab
augroup END

" Pick up external edits when refocusing vim.
autocmd FocusGained,BufEnter * :checktime
