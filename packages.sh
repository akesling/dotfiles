#!/usr/bin/env bash
#
# packages.sh — verify or install the expected commands declared in packages.txt.
#
# Usage:
#   packages.sh [--check | --install | --install-all | --bootstrap-brew] [--dry-run] [-h|--help]
#
# Modes:
#   --check           (default) report which commands are missing; exit 1 if any
#                     required command is missing, 0 otherwise.
#   --install         install missing required packages.
#   --install-all     install missing required + optional packages.
#   --bootstrap-brew  install Homebrew under $HOME/.local/homebrew and exit.
#   --dry-run         print the install command without executing it.
#
# Detects brew, apt-get, dnf, or pacman. brew is preferred when available.
# On macOS, if no package manager is detected, Homebrew is bootstrapped under
# $HOME/.local/homebrew (the "untar anywhere" install from
# https://docs.brew.sh/Installation) so brew never needs sudo.

set -euo pipefail
IFS=$'\n\t'

DOTFILES_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES="${DOTFILES_SRC}/packages.txt"

# shellcheck source=lib/common.sh
source "${DOTFILES_SRC}/lib/common.sh"

MODE=check
INCLUDE_OPTIONAL=0
DRY_RUN=0

usage() {
    sed -n '2,19p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

BREW_PREFIX="${HOME}/.local/homebrew"

# bootstrap_brew: install Homebrew into $BREW_PREFIX using the "untar anywhere"
# method documented at https://docs.brew.sh/Installation. Keeps brew sudo-free.
# Idempotent: re-running on an existing prefix only re-evals shellenv.
bootstrap_brew() {
    if [[ -x "${BREW_PREFIX}/bin/brew" ]]; then
        ok "brew already at ${BREW_PREFIX}"
    else
        if ! command -v curl >/dev/null 2>&1; then
            die "curl is required to bootstrap Homebrew"
        fi
        act "fetch Homebrew tarball -> ${BREW_PREFIX}"
        if (( DRY_RUN )); then
            return 0
        fi
        mkdir -p -- "${BREW_PREFIX}"
        curl -fsSL https://github.com/Homebrew/brew/tarball/main \
            | tar xz --strip-components 1 -C "${BREW_PREFIX}"
    fi
    # Make brew callable for the rest of this run (sets PATH, MANPATH, HOMEBREW_*).
    eval "$("${BREW_PREFIX}/bin/brew" shellenv)"
    ok "brew: $(command -v brew)"
}

# install_packages <pm> <pkg>...
install_packages() {
    local pm=$1; shift
    local cmd
    case "${pm}" in
        brew)
            cmd=(brew install --quiet "$@")
            ;;
        apt)
            cmd=(sudo apt-get install -y "$@")
            ;;
        dnf)
            cmd=(sudo dnf install -y "$@")
            ;;
        pacman)
            cmd=(sudo pacman -S --noconfirm --needed "$@")
            ;;
        *)
            die "no install support for: ${pm}"
            ;;
    esac
    ( IFS=' '; printf 'running: %s\n' "${cmd[*]}" )
    if (( DRY_RUN )); then
        return 0
    fi
    if [[ "${pm}" == apt ]]; then
        sudo apt-get update -qq
    fi
    "${cmd[@]}"
}

main() {
    while (( $# )); do
        case "$1" in
            --check)           MODE=check ;;
            --install)         MODE=install ;;
            --install-all)     MODE=install; INCLUDE_OPTIONAL=1 ;;
            --bootstrap-brew)  MODE=bootstrap-brew ;;
            --dry-run)         DRY_RUN=1 ;;
            -h|--help)         usage; exit 0 ;;
            *) die "unknown argument: $1" ;;
        esac
        shift
    done

    if [[ "${MODE}" == bootstrap-brew ]]; then
        bootstrap_brew
        exit 0
    fi

    local pm
    pm=$(detect_pm)

    # On macOS with no package manager available, bootstrap Homebrew under
    # $HOME/.local/homebrew so the rest of the run has something to install with.
    if [[ "${pm}" == unknown && "$(uname -s)" == Darwin ]]; then
        note "no package manager detected; bootstrapping Homebrew under ${BREW_PREFIX}"
        bootstrap_brew
        pm=$(detect_pm)
    fi

    [[ "${pm}" != unknown ]] || die "no supported package manager (need brew, apt-get, dnf, or pacman)"
    printf 'mode: %s   pm: %s\n\n' "${MODE}" "${pm}"

    local cmd cat pkg
    local missing_required=() missing_optional=()
    while IFS=$'\t' read -r cmd cat pkg; do
        if command -v "${cmd}" >/dev/null 2>&1; then
            ok "${cmd} ($(command -v "${cmd}"))"
        else
            if [[ "${cat}" == required ]]; then
                warn "missing required: ${cmd} -> ${pkg}"
                missing_required+=("${pkg}")
            else
                note "missing optional: ${cmd} -> ${pkg}"
                missing_optional+=("${pkg}")
            fi
        fi
    done < <(read_packages "${pm}")

    if [[ "${MODE}" == check ]]; then
        printf '\nrequired missing: %d   optional missing: %d\n' \
            "${#missing_required[@]}" "${#missing_optional[@]}"
        local total_missing=$(( ${#missing_required[@]} + ${#missing_optional[@]} ))
        if (( total_missing > 0 )); then
            printf '\nto install:\n'
            (( ${#missing_required[@]} > 0 )) && \
                printf '  %s --install         # required only (%d package(s))\n' \
                    "$0" "${#missing_required[@]}"
            (( ${#missing_optional[@]} > 0 )) && \
                printf '  %s --install-all     # required + optional (%d package(s))\n' \
                    "$0" "${total_missing}"
            printf '  %s --install-all --dry-run   # preview the command without running it\n' "$0"
        fi
        (( ${#missing_required[@]} == 0 )) || exit 1
        exit 0
    fi

    # install mode
    local to_install=()
    if (( ${#missing_required[@]} > 0 )); then
        to_install+=("${missing_required[@]}")
    fi
    if (( INCLUDE_OPTIONAL )) && (( ${#missing_optional[@]} > 0 )); then
        to_install+=("${missing_optional[@]}")
    fi
    if (( ${#to_install[@]} == 0 )); then
        printf '\nnothing to install\n'
        exit 0
    fi

    # Dedupe (a single package can provide several commands, e.g. coreutils -> gls,gdircolors).
    # bash 3.2 compatible — no associative arrays.
    local pkg_to_add seen=" " unique=()
    for pkg_to_add in "${to_install[@]}"; do
        case "${seen}" in
            *" ${pkg_to_add} "*) ;;
            *) seen+="${pkg_to_add} "; unique+=("${pkg_to_add}") ;;
        esac
    done

    ( IFS=' '; printf '\nwill install: %s\n' "${unique[*]}" )
    install_packages "${pm}" "${unique[@]}"
    printf '\ninstall complete\n'
}

main "$@"
