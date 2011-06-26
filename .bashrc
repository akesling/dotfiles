# .bashrc
#alias cd='pushd'

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

# User specific aliases and functions
export PS1="\n\[\e[1;32m\]\H \[\e[37m\]| \[\e[31m\]\w \[\e[37m\]| \[\e[1;35m\]\t \[\e[4;35m\]\d\n\[\e[0;32m\]\u\[\e[1;37m\] ( \[\e[1;36m\]\! : \#\[\e[1;37m\] ) \$(__git_ps1 '%s ')\$ \[\e[0;39m\]"

export UAEDITOR=vim
export EDITOR=vim
export VISUAL=vim
export GOROOT=$HOME/Devel/go
export GOOS=linux
export GOARCH=amd64
export GOBIN=$GOROOT/bin

export PATH=$PATH:$GOROOT/bin
export CHROMIUM_ROOT=/home/akesling/Devel/Chromium
export GYP_GENERATORS=make

export PKG_CONFIG_PATH+=":/usr/local/lib64/pkgconfig/"
export LD_LIBRARY_PATH+=":/usr/local/lib64/:/lib/:/usr/lib/"

alias pip='pip-python'

# Nodejs
export PATH=$HOME/local/node/bin:$PATH


#Fix for fucked up flash/glibc issue
alias firefox="LD_PRELOAD=$HOME/Devel/linusmemcpy/linusmemcpy.so firefox"
alias huludesktop="LD_PRELOAD=$HOME/Devel/linusmemcpy/linusmemcpy.so huludesktop"
#alias google-chrome="LD_PRELOAD=$HOME/Devel/linusmemcpy/linusmemcpy.so; google-chrome"

#calendar with today highlighted - http://www.shell-fu.org/lister.php?id=210
alias tcal='cal | sed "s/^/ /;s/$/ /;s/ $(date +%e) / $(date +%e | sed '\''s/./#/g'\'') /"'
