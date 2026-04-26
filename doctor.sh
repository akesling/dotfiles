#!/usr/bin/env bash
#
# doctor.sh — health check for an installed dotfiles linkfarm.
#
# Verifies: required commands on PATH, manifest links resolve to the repo,
# husk files exist, no broken symlinks under ~/.vim, shell rcs parse, and
# vim/nvim load their configs.
#
# Exit 0 if no issues; non-zero otherwise. Optional warnings never affect
# the exit code.

set -euo pipefail
IFS=$'\n\t'

DOTFILES_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_DOTFILES="${DOTFILES_SRC}/local_dotfiles"
MANIFEST="${DOTFILES_SRC}/manifest.txt"
PACKAGES="${DOTFILES_SRC}/packages.txt"

# shellcheck source=lib/common.sh
source "${DOTFILES_SRC}/lib/common.sh"

ISSUES=0
fail() { warn "$*"; ISSUES=$(( ISSUES + 1 )); }

main() {
    local host_os
    host_os=$(detect_os)
    [[ "${host_os}" != unknown ]] || die "unsupported OS: $(uname -s)"
    printf 'doctor: os=%s home=%s\n\n' "${host_os}" "${HOME}"

    # Source-of-truth for the command list is packages.txt. Filter to whichever
    # package manager is active so we don't, e.g., flag `gls` as missing on a
    # Linux box where it isn't packaged.
    local pm
    pm=$(detect_pm)
    if [[ "${pm}" == unknown ]]; then
        note "no supported package manager detected; skipping command checks"
    else
        printf '== commands (pm: %s) ==\n' "${pm}"
        local cmd cat pkg
        while IFS=$'\t' read -r cmd cat pkg; do
            if command -v "${cmd}" >/dev/null 2>&1; then
                ok "${cmd}: $(command -v "${cmd}")"
            else
                if [[ "${cat}" == required ]]; then
                    fail "missing required: ${cmd} (pkg: ${pkg})"
                else
                    note "missing optional: ${cmd} (pkg: ${pkg})"
                fi
            fi
        done < <(read_packages "${pm}")
    fi

    printf '\n== manifest links ==\n'
    local kind src tgt abs_src abs_tgt cur
    while IFS=$'\t' read -r kind src tgt; do
        case "${kind}" in
            link)
                abs_src="${DOTFILES_SRC}/${src}"
                abs_tgt="${HOME}/${tgt}"
                if [[ ! -L "${abs_tgt}" ]]; then
                    fail "not linked: ${abs_tgt}"
                else
                    cur="$(readlink "${abs_tgt}")"
                    if [[ "${cur}" != "${abs_src}" ]]; then
                        fail "wrong target: ${abs_tgt} -> ${cur} (want ${abs_src})"
                    elif [[ ! -e "${abs_tgt}" ]]; then
                        fail "broken link: ${abs_tgt} -> ${cur}"
                    else
                        ok "${tgt}"
                    fi
                fi
                ;;
            husk)
                if [[ ! -e "${LOCAL_DOTFILES}/${tgt}" ]]; then
                    fail "missing husk: ${LOCAL_DOTFILES}/${tgt}"
                else
                    ok "husk ${tgt}"
                fi
                ;;
        esac
    done < <(read_manifest "${host_os}")

    printf '\n== broken symlinks under .vim/ ==\n'
    if [[ -d "${HOME}/.vim" ]]; then
        local broken=0 link
        while IFS= read -r link; do
            fail "broken: ${link} -> $(readlink "${link}")"
            broken=$(( broken + 1 ))
        done < <(find -H "${HOME}/.vim" -type l ! -exec test -e {} \; -print 2>/dev/null)
        (( broken == 0 )) && ok ".vim/ has no dangling symlinks"
    else
        note "${HOME}/.vim missing (run setup.sh --apply)"
    fi

    printf '\n== shell rc syntax ==\n'
    if [[ -f "${HOME}/.bashrc" ]] && command -v bash >/dev/null 2>&1; then
        if bash -n "${HOME}/.bashrc" 2>/dev/null; then
            ok ".bashrc parses"
        else
            fail ".bashrc syntax error"
        fi
    fi
    if [[ -f "${HOME}/.zshrc" ]] && command -v zsh >/dev/null 2>&1; then
        if zsh -n "${HOME}/.zshrc" 2>/dev/null; then
            ok ".zshrc parses"
        else
            fail ".zshrc syntax error"
        fi
    fi

    printf '\n== editor smoke tests ==\n'
    if [[ -f "${HOME}/.vimrc" ]] && command -v vim >/dev/null 2>&1; then
        if [[ -d "${HOME}/.vim/bundle/Vundle.vim" ]]; then
            if vim -es -u "${HOME}/.vimrc" +qall </dev/null >/dev/null 2>&1; then
                ok "vim loads .vimrc"
            else
                fail "vim returned non-zero loading .vimrc"
            fi
        else
            note "Vundle not installed (run vim-plugins.sh); skipping vim load test"
        fi
    fi
    if command -v nvim >/dev/null 2>&1; then
        if nvim --headless +qall </dev/null >/dev/null 2>&1; then
            ok "nvim --headless +qall"
        else
            fail "nvim returned non-zero on +qall"
        fi
    fi

    printf '\ndoctor: issues=%d\n' "${ISSUES}"
    (( ISSUES == 0 ))
}

main "$@"
