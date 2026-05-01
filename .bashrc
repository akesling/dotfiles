# .bashrc — interactive bash startup.

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# Resolve repo root (handle .bashrc being a symlink into the dotfiles repo).
_dotfiles_src="$(cd -P -- "$(dirname -- "$(readlink "${HOME}/.bashrc" 2>/dev/null || echo "${HOME}/.bashrc")")" && pwd)"

# === Shared shell layer ===
# PATH, env, aliases, dircolors, fzf integration.
# Reads _dotfiles_src to add bin/ to PATH.
# shellcheck source=lib/sh/common.sh
[ -r "${_dotfiles_src}/lib/sh/common.sh" ] && . "${_dotfiles_src}/lib/sh/common.sh"
unset _dotfiles_src

# === History ===

export HISTSIZE=1000000
export HISTFILESIZE=1000000
export HISTCONTROL=ignoreboth:erasedups
export HISTTIMEFORMAT='%F %T '
PROMPT_COMMAND='history -a'

# === Shell options ===

# Always available on bash 3.2+.
shopt -s histappend cmdhist checkwinsize nocaseglob cdspell

# Bash 4+ only.
if (( BASH_VERSINFO[0] >= 4 )); then
    shopt -s globstar autocd dirspell
fi

# === Vi mode ===
# Mirrors ~/.inputrc; explicit here for safety in subshells that ignore inputrc.
set -o vi

# === Completion ===
# Source bash-completion@2 from Homebrew when present.
if command -v brew >/dev/null 2>&1; then
    _brew_prefix="$(brew --prefix 2>/dev/null)"
    if [[ -r "${_brew_prefix}/etc/profile.d/bash_completion.sh" ]]; then
        # shellcheck disable=SC1091
        . "${_brew_prefix}/etc/profile.d/bash_completion.sh"
    fi
    unset _brew_prefix
fi

# === Prompt ===
# Native bash escapes only — zero subshells per redraw.
export GIT_PS1_SHOWDIRTYSTATE=1
export PS1="\n\[\e[1;32m\]\H \[\e[37m\]| \[\e[31m\]\w \[\e[37m\]| \[\e[1;35m\]\t \[\e[4;35m\]\d\n\[\e[0;32m\]\u\[\e[1;37m\] ( \[\e[1;36m\]\! : \#\[\e[1;37m\] ) \[\e[0;39m\]"

# === Per-machine overrides ===
# Husk created by setup.sh; safe to source even when empty.
[ -r ~/.local/dotfiles/.bashrc ] && source ~/.local/dotfiles/.bashrc
