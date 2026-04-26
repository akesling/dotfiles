# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

###############################################################################
# History #####################################################################
###############################################################################

export HISTCONTROL=ignoreboth
export HISTSIZE=2000000
export HISTFILESIZE=2000000
shopt -s histappend 2>/dev/null

###############################################################################
# Aliases #####################################################################
###############################################################################

alias vim=nvim

# Solarized dark colors for ls/completion. Prefer GNU ls + dircolors when
# available (macOS: `brew install coreutils` provides gls/gdircolors), and
# fall back to BSD ls -G otherwise.
if command -v gdircolors >/dev/null 2>&1; then
    eval "$(gdircolors ~/.dircolors)"
    alias ls='gls --color=auto'
elif command -v dircolors >/dev/null 2>&1; then
    eval "$(dircolors ~/.dircolors)"
    alias ls='ls --color=auto'
else
    alias ls='ls -G'
fi

# Fix tmux color issues (force 256 colors)
alias tmux='tmux -2'

# Calendar with today highlighted - http://www.shell-fu.org/lister.php?id=210
alias tcal='cal | sed "s/^/ /;s/$/ /;s/ $(date +%e) / $(date +%e | sed '\''s/./#/g'\'') /"'

###############################################################################
# Prompt ######################################################################
###############################################################################

export GIT_PS1_SHOWDIRTYSTATE=1
export PS1="\n\[\e[1;32m\]\H \[\e[37m\]| \[\e[31m\]\w \[\e[37m\]| \[\e[1;35m\]\t \[\e[4;35m\]\d\n\[\e[0;32m\]\u\[\e[1;37m\] ( \[\e[1;36m\]\! : \#\[\e[1;37m\] ) \[\e[0;39m\]"

###############################################################################
# Editor ######################################################################
###############################################################################

export EDITOR=nvim
export VISUAL=nvim

###############################################################################
# PATH ########################################################################
###############################################################################

# Homebrew is intentionally installed under $HOME/.local/homebrew (rather than
# the default /opt/homebrew or /usr/local) so that `brew` never requires sudo
# to install, upgrade, or uninstall packages.
PATH="${PATH}:${HOME}/.local/homebrew/bin"
PATH="${PATH}:${HOME}/.local/homebrew/opt/libpq/bin"
PATH="${PATH}:/Applications/Docker.app/Contents/Resources/bin"
PATH="${PATH}:${HOME}/.yarn/bin:${HOME}/.config/yarn/global/node_modules/.bin"
export PATH

###############################################################################
# Tooling #####################################################################
###############################################################################

export HOMEBREW_NO_AUTO_UPDATE=1

# FZF
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

###############################################################################
# Per-machine overrides #######################################################
###############################################################################

# Husk created by setup.sh; safe to source even when empty.
[ -r ~/.local/dotfiles/.bashrc ] && source ~/.local/dotfiles/.bashrc
