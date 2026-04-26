#!/usr/bin/env bash
#
# vim-plugins.sh — clone Vundle if missing, then run :PluginInstall.
# Idempotent. Safe to re-run.
#
# Note: YouCompleteMe still requires `python3 install.py` from inside
# ~/.vim/bundle/YouCompleteMe/ to build its completer. That step is
# intentionally manual (it depends on a working compiler toolchain).

set -euo pipefail
IFS=$'\n\t'

DOTFILES_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=lib/common.sh
source "${DOTFILES_SRC}/lib/common.sh"

VUNDLE_REPO="https://github.com/VundleVim/Vundle.vim.git"
VUNDLE_DIR="${HOME}/.vim/bundle/Vundle.vim"

main() {
    if ! command -v git >/dev/null 2>&1; then
        die "git is required"
    fi

    if [[ ! -d "${VUNDLE_DIR}/.git" ]]; then
        act "clone Vundle -> ${VUNDLE_DIR}"
        mkdir -p -- "$(dirname "${VUNDLE_DIR}")"
        git clone --quiet --depth 1 "${VUNDLE_REPO}" "${VUNDLE_DIR}"
    else
        ok "Vundle present at ${VUNDLE_DIR}"
    fi

    if ! command -v vim >/dev/null 2>&1; then
        warn "vim not on PATH; cannot run :PluginInstall"
        exit 1
    fi

    if [[ ! -e "${HOME}/.vimrc" ]]; then
        warn "${HOME}/.vimrc not present; run setup.sh --apply first"
        exit 1
    fi

    act "vim +PluginInstall (this can take a while)"
    # PluginInstall! upgrades already-installed plugins. Redirect stdin from
    # /dev/null so vim doesn't try to grab the tty in -es mode.
    if vim -es -u "${HOME}/.vimrc" +"PluginInstall!" +qall </dev/null >/dev/null 2>&1; then
        ok ":PluginInstall completed"
    else
        # YouCompleteMe's post-install hook can fail without a built completer;
        # don't treat that as fatal.
        warn ":PluginInstall returned non-zero (some plugins may need manual setup, e.g. YouCompleteMe -> python3 install.py)"
    fi

    printf '\nsummary: ok=%d changed=%d conflict=%d\n' "${N_OK}" "${N_CHANGED}" "${N_CONFLICT}"
    (( N_CONFLICT == 0 ))
}

main "$@"
