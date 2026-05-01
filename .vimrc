" .vimrc — vim-specific entry point. Shared base lives in vim/shared/common.vim.

" === Header ===
" Mapleader must be set before any mapping that uses <leader>.
let mapleader=","

" === Pre-plugin ===
set nocompatible
filetype off
syntax off

" === Vundle ===
set rtp+=~/.vim/bundle/Vundle.vim/
call vundle#begin()

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

" === Post-plugin ===
filetype plugin indent on
syntax on

" === Shared base ===
" Resolve the dotfiles repo via the .vimrc symlink and source the shared file.
let s:dotfiles_src = fnamemodify(resolve(expand('<sfile>:p')), ':h')
execute 'source ' . s:dotfiles_src . '/vim/shared/common.vim'

" === Vim-only options ===

" Don't wake up system with blinking cursor.
set guicursor+=a:blinkon0

" Airline tabline.
let g:airline#extensions#tabline#enabled=1
let g:airline#extensions#tabline#formatter='jsformatter'

" Help with line-length visualization (vim handles colorcolumn ranges natively;
" nvim has its own decoration provider in init.lua).
let &colorcolumn = join(map(range(1,1000), '"+" . v:val'), ",")

" === Toggle to last active tab ===

au TabLeave * let g:lasttab = tabpagenr()
nnoremap <silent> <leader>- :exe "tabn ".g:lasttab<cr>
vnoremap <silent> <leader>- :exe "tabn ".g:lasttab<cr>

" === Markdown ===

let g:markdown_fenced_languages = ['rust', 'python', 'java', 'javascript', 'typescript']

" === Latex ===

" Because IMAP steals <C-j> if we don't bind it ahead.
map <C-space> <Plug>IMAP_JumpForward

let g:Tex_FormatDependency_pdf='dvi,pdf'
let g:Tex_CompileRule_pdf = 'dvipdf $*.dvi'
let g:Tex_ViewRule_pdf='evince'
let g:Tex_DefaultTargetFormat='pdf'

" === NERDTree ===

nmap <silent> <leader>h :NERDTreeToggle<CR>
nnoremap <F4> :NERDTreeToggle<CR>

" === YouCompleteMe ===

" When YCM opens a preview window, show syntax highlighting for rustdoc.
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

" === Mundo ===

nnoremap <silent> <leader>g :MundoToggle<CR>
nnoremap <F5> :MundoToggle<CR>
let g:mundo_right = 1

" === Misc ===

set viminfo='20,\"50

" Better cscope integration.
if has("cscope") && filereadable("/usr/bin/cscope")
    set csprg=/usr/bin/cscope
    set csto=0
    set cst
    set nocsverb
    if filereadable("cscope.out")
        cs add cscope.out
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

" === Per-machine overrides ===
" Husk created by setup.sh; safe to source even when empty.
if filereadable(expand('~/.local/dotfiles/.vimrc'))
    source ~/.local/dotfiles/.vimrc
endif
