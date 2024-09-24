###############################################################################
# Basic Configuration #########################################################
###############################################################################

export HISTSIZE=2000000


setopt EXTENDED_HISTORY          # Write the history file in the
                                 # ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not
                                 # when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded
                                 # again.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_VERIFY               # Don't execute immediately upon history expansion.

autoload -U colors && colors
setopt PROMPT_SUBST
# PROMPT='%{$fg[green]%}%m %{$fg[white]%}| %{$fg[red]%}%~ %{$fg[white]%}| %{$fg[magenta]%}%T %{$fg[magenta,underline]%}%D{%Y-%m-%d}
# %{$fg[green]%}%n%{$fg[white]%} ( %{$fg[cyan]%}%! : %#%{$fg[white]%} ) %{$reset_color%}'

# Original Bash configuration
# export PS1="\n\[\e[1;32m\]\H \[\e[37m\]| \[\e[31m\]\w \[\e[37m\]| \[\e[1;35m\]\t \[\e[4;35m\]\d\n\[\e[0;32m\]\u\[\e[1;37m\] ( \[\e[1;36m\]\! : \#\[\e[1;37m\] ) \[\e[0;39m\]"
PROMPT='
$(tput setaf 10)$(hostname) $(tput setaf 7)| $(tput setaf 1)$(pwd) $(tput setaf 7)| $(tput setaf 13)$(tput smul)$(date +%H:%M:%S) $(date +%Y-%m-%d)$(tput rmul)
$(tput setaf 2)$(whoami)$(tput setaf 7) ( $(history | tail -n 1 | awk "{print \$1}") ) %# %{$reset_color%}'

###############################################################################
# PATH ########################################################################
###############################################################################

PATH="${PATH}:${HOME}/.local/homebrew/bin"
PATH="${PATH}:/Applications/Docker.app/Contents/Resources/bin"
PATH="${PATH}:/Users/alex/.local/homebrew/opt/libpq/bin"

###############################################################################
# Aliases #####################################################################
###############################################################################

alias vim=nvim
alias ls="ls -G"

###############################################################################
# Commands ####################################################################
###############################################################################

bindkey -v  # Vim insert mode config

# History managed by FZF plugin now, so the following is vestigial
# bindkey ^R history-incremental-search-backward
# bindkey ^S history-incremental-search-forward

###############################################################################
# Extensions ##################################################################
###############################################################################

# FZF
source ~/dotfiles/fzf_zsh.sh

###############################################################################
# Tooling #####################################################################
###############################################################################

export HOMEBREW_NO_AUTO_UPDATE=1
