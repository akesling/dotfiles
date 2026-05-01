# .zshrc — interactive zsh startup.

# Resolve repo root (handle .zshrc being a symlink into the dotfiles repo).
_dotfiles_src="${${(%):-%N}:A:h}"

# === Shared shell layer ===
# PATH, env, aliases, dircolors, fzf integration.
# Reads _dotfiles_src to add bin/ to PATH.
[[ -r "${_dotfiles_src}/lib/sh/common.sh" ]] && source "${_dotfiles_src}/lib/sh/common.sh"
unset _dotfiles_src

# === History ===

export HISTFILE=~/.zsh_history
export HISTSIZE=2000000
export SAVEHIST=2000000

setopt EXTENDED_HISTORY          # ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY        # write immediately, not on shell exit.
setopt SHARE_HISTORY             # share between all sessions.
setopt HIST_IGNORE_DUPS          # don't record consecutive duplicates.
setopt HIST_IGNORE_SPACE         # don't record entries starting with a space.
setopt HIST_VERIFY               # don't execute immediately on history expansion.
setopt HIST_EXPIRE_DUPS_FIRST    # when trimming, drop duplicates first.
setopt HIST_FIND_NO_DUPS         # don't show duplicates in interactive search.
setopt HIST_REDUCE_BLANKS        # collapse runs of whitespace before recording.

# === Shell options ===

setopt AUTO_CD                   # bare directory name = cd into it.
setopt AUTO_PUSHD                # cd pushes onto the dir stack.
setopt PUSHD_IGNORE_DUPS         # don't stack duplicate dirs.
setopt GLOB_DOTS                 # globs include dotfiles by default.
setopt EXTENDED_GLOB             # ^, ~, # globbing operators.
setopt INTERACTIVE_COMMENTS      # # starts a comment in interactive shells.

# === Completion ===
# Daily cache invalidation: regenerate dump only if older than 24h.
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-${HOME}}/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'

# === Vi mode ===

bindkey -v
# Restore ergonomics that pure vi mode breaks.
bindkey '^?' backward-delete-char       # backspace deletes past insert point
bindkey '^H' backward-delete-char
bindkey '^W' backward-kill-word
bindkey '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward
bindkey '^U' backward-kill-line
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
# Mode indicator updated on each keymap change (used in RPROMPT below).
function zle-keymap-select { zle reset-prompt }
zle -N zle-keymap-select

# === Prompt ===
# Native zsh escapes only — zero subshells per redraw.
# History count is a running ~/.zsh_history line count: seeded once at shell
# startup, bumped in precmd. Avoids the per-redraw `wc -l` subshell.
autoload -U colors && colors
setopt PROMPT_SUBST

_zsh_history_count=$(wc -l < ~/.zsh_history 2>/dev/null | tr -d ' ')
: "${_zsh_history_count:=0}"
function _bump_history_count { _zsh_history_count=$(( _zsh_history_count + 1 )) }
autoload -Uz add-zsh-hook
add-zsh-hook precmd _bump_history_count

PROMPT='
%F{10}%M %F{white}| %F{red}%d %F{white}| %F{13}%U%*%f %F{13}%D{%Y-%m-%d}%u%f
%F{green}%n%f%F{white} ( %F{yellow}${_zsh_history_count}%f%F{white} ) %#%f '

RPROMPT='${${KEYMAP/vicmd/N}/(main|viins)/I}'

# === Per-machine overrides ===
# Husk created by setup.sh; safe to source even when empty.
[[ -r ~/.local/dotfiles/.zshrc ]] && source ~/.local/dotfiles/.zshrc
