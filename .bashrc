# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

export HISTCONTROL=ignoreboth
export HISTSIZE=20000

alias exit='history -a && exit'

# pretty colors, in ssh and vim at least
if [ "$COLORTERM" = "gnome-terminal" ]
then
#    export TERM=xterm-256color
    eval `dircolors ~/.dircolors`
fi
# Fix tmux color issues (force 256 colors)
alias tmux='tmux -2'
alias ls='ls --color'

export GIT_PS1_SHOWDIRTYSTATE=1

# User specific aliases and functions
export PS1="\n\[\e[1;32m\]\H \[\e[37m\]| \[\e[31m\]\w \[\e[37m\]| \[\e[1;35m\]\t \[\e[4;35m\]\d\n\[\e[0;32m\]\u\[\e[1;37m\] ( \[\e[1;36m\]\! : \#\[\e[1;37m\] ) \$(__git_ps1 '%s ')\$ \[\e[0;39m\]"

### Used for blog post to clean up username/hostname. Saving in case of need ##
#export PS1="\n   \[\e[1;32m\]herein \[\e[37m\]| \[\e[31m\]\w \[\e[37m\]| \[\e[1;35m\]\t \[\e[4;35m\]\d\n\[\e[0;32m\]   echoet\[\e[1;37m\] ( \[\e[1;36m\]\! : \#\[\e[1;37m\] ) \$(__git_ps1 '%s ')\$ \[\e[0;39m\]"

export UAEDITOR=vim
export EDITOR=vim
export VISUAL=vim

alias pip='pip-python'

#calendar with today highlighted - http://www.shell-fu.org/lister.php?id=210
alias tcal='cal | sed "s/^/ /;s/$/ /;s/ $(date +%e) / $(date +%e | sed '\''s/./#/g'\'') /"'

# Add npm installed binaries to path
PATH=$PATH:~/Devel/nodejs/npm/bin

source ~/.local/dotfiles/.bashrc
