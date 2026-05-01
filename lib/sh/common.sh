# shellcheck shell=bash
# lib/sh/common.sh — shared interactive-shell setup for bash and zsh.
#
# Strict scope: PATH, environment, aliases, dircolors, fzf source.
# No functions, no interactive bits (history, prompt, completion, keymaps),
# no OS-detection helper — use [[ "$OSTYPE" == darwin* ]] inline if needed.

# === PATH ===

# Homebrew is intentionally installed under $HOME/.local/homebrew (rather than
# the default /opt/homebrew or /usr/local) so that `brew` never requires sudo.
[[ -d "${HOME}/.local/homebrew/bin" ]] && PATH="${PATH}:${HOME}/.local/homebrew/bin"
[[ -d "${HOME}/.local/homebrew/opt/libpq/bin" ]] && PATH="${PATH}:${HOME}/.local/homebrew/opt/libpq/bin"
[[ -d /Applications/Docker.app/Contents/Resources/bin ]] && PATH="${PATH}:/Applications/Docker.app/Contents/Resources/bin"
[[ -d "${HOME}/.yarn/bin" ]] && PATH="${PATH}:${HOME}/.yarn/bin"
[[ -d "${HOME}/.config/yarn/global/node_modules/.bin" ]] && PATH="${PATH}:${HOME}/.config/yarn/global/node_modules/.bin"
[[ -d "${HOME}/.local/bin" ]] && PATH="${PATH}:${HOME}/.local/bin"
[[ -d "${HOME}/bin" ]] && PATH="${PATH}:${HOME}/bin"
# Personal scripts vendored in the dotfiles repo (_dotfiles_src is set by the
# rc file that sourced us).
[[ -n "${_dotfiles_src:-}" && -d "${_dotfiles_src}/bin" ]] && PATH="${PATH}:${_dotfiles_src}/bin"
export PATH

# === Environment ===

export EDITOR=nvim
export VISUAL=nvim
export PAGER=less
export LESS=-FRX
export LANG=en_US.UTF-8
export HOMEBREW_NO_AUTO_UPDATE=1

# === Aliases ===

# `vim` opens neovim (the daily driver); `vi` opens classic vim. `command vim`
# bypasses the `vim=nvim` alias so it actually runs the vim binary on PATH.
alias vim=nvim
alias vi='command vim'

# Force tmux to assume 256-color capability.
alias tmux='tmux -2'

# Calendar with today highlighted - http://www.shell-fu.org/lister.php?id=210
alias tcal='cal | sed "s/^/ /;s/$/ /;s/ $(date +%e) / $(date +%e | sed '\''s/./#/g'\'') /"'

# === Dircolors ===

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

# === FZF ===

# Source upstream fzf shell integration from Homebrew when present.
# shellcheck disable=SC1091
if command -v brew >/dev/null 2>&1; then
    _fzf_shell_dir="$(brew --prefix 2>/dev/null)/opt/fzf/shell"
    if [[ -n "${BASH_VERSION:-}" && -d "${_fzf_shell_dir}" ]]; then
        [[ -r "${_fzf_shell_dir}/key-bindings.bash" ]] && source "${_fzf_shell_dir}/key-bindings.bash"
        [[ -r "${_fzf_shell_dir}/completion.bash"   ]] && source "${_fzf_shell_dir}/completion.bash"
    elif [[ -n "${ZSH_VERSION:-}" && -d "${_fzf_shell_dir}" ]]; then
        [[ -r "${_fzf_shell_dir}/key-bindings.zsh" ]] && source "${_fzf_shell_dir}/key-bindings.zsh"
        [[ -r "${_fzf_shell_dir}/completion.zsh"   ]] && source "${_fzf_shell_dir}/completion.zsh"
    fi
    unset _fzf_shell_dir
fi
