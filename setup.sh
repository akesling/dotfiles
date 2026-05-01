#!/usr/bin/env bash
#
# setup.sh — install/check/uninstall dotfile symlinks declared in manifest.txt
#
# Usage:
#   setup.sh [--apply | --check | --uninstall] [--force] [-h|--help]
#
# Default mode is dry-run: prints what would happen, changes nothing.
# --dry-run     explicit no-op alias (the default); prints planned actions
# --apply       perform the changes
# --check       exit 0 if everything is already linked correctly, else 1
# --uninstall   remove only symlinks this script created (pointing into the repo)
# --force       overwrite conflicting symlinks (still backs up real files)
#
# Companion scripts:
#   doctor.sh        deeper health check (required commands, broken symlinks, rc syntax)
#   vim-plugins.sh   bootstrap Vundle and run :PluginInstall

set -euo pipefail
IFS=$'\n\t'

DOTFILES_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_DOTFILES="${DOTFILES_SRC}/local_dotfiles"
MANIFEST="${DOTFILES_SRC}/manifest.txt"
BACKUP_DIR="${HOME}/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

# shellcheck source=lib/common.sh
source "${DOTFILES_SRC}/lib/common.sh"

MODE="dry-run"
FORCE=0

usage() {
    sed -n '2,16p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

run() {
    if [[ "${MODE}" == "apply" || "${MODE}" == "uninstall" ]]; then
        "$@"
    fi
}

# install_link <abs_source> <abs_target>
install_link() {
    local src=$1 tgt=$2 cur
    [[ -e "${src}" || -L "${src}" ]] || { warn "${tgt} -> ${src} (source missing)"; return; }

    if [[ -L "${tgt}" ]]; then
        cur="$(readlink "${tgt}")"
        if [[ "${cur}" == "${src}" ]]; then
            ok "${tgt}"
            return
        fi
        if (( FORCE )); then
            act "relink ${tgt} (was -> ${cur})"
            run rm -- "${tgt}"
        else
            warn "${tgt} is a symlink to ${cur} (use --force to relink)"
            return
        fi
    elif [[ -e "${tgt}" ]]; then
        act "backup ${tgt} -> ${BACKUP_DIR}/"
        run mkdir -p -- "${BACKUP_DIR}"
        run mv -- "${tgt}" "${BACKUP_DIR}/"
    fi

    run mkdir -p -- "$(dirname "${tgt}")"
    act "link ${tgt} -> ${src}"
    run ln -s -- "${src}" "${tgt}"
}

uninstall_link() {
    local src=$1 tgt=$2 cur
    if [[ ! -L "${tgt}" ]]; then
        ok "${tgt} (not a symlink, leaving alone)"
        return
    fi
    cur="$(readlink "${tgt}")"
    if [[ "${cur}" != "${src}" ]]; then
        warn "${tgt} -> ${cur} (not ours, leaving alone)"
        return
    fi
    act "remove ${tgt}"
    run rm -- "${tgt}"
}

install_husk() {
    local tgt=$1 path="${LOCAL_DOTFILES}/$1"
    if [[ -e "${path}" ]]; then
        ok "husk ${tgt}"
        return
    fi
    act "create husk ${path}"
    run mkdir -p -- "$(dirname "${path}")"
    run touch -- "${path}"
}

main() {
    while (( $# )); do
        case "$1" in
            --apply)     MODE=apply ;;
            --check)     MODE=check ;;
            --dry-run)   MODE=dry-run ;;
            --uninstall) MODE=uninstall ;;
            --force)     FORCE=1 ;;
            -h|--help)   usage; exit 0 ;;
            *) die "unknown argument: $1" ;;
        esac
        shift
    done

    local host_os
    host_os=$(detect_os)
    [[ "${host_os}" != unknown ]] || die "unsupported OS: $(uname -s)"

    printf 'mode: %s   os: %s   src: %s\n\n' "${MODE}" "${host_os}" "${DOTFILES_SRC}"

    if [[ "${MODE}" != uninstall ]]; then
        run mkdir -p -- "${LOCAL_DOTFILES}"
        run mkdir -p -- "${HOME}/.local"
        local local_link="${HOME}/.local/dotfiles"
        if [[ -L "${local_link}" && "$(readlink "${local_link}")" == "${LOCAL_DOTFILES}" ]]; then
            ok "${local_link}"
        elif [[ ! -e "${local_link}" && ! -L "${local_link}" ]]; then
            act "link ${local_link} -> ${LOCAL_DOTFILES}"
            run ln -s -- "${LOCAL_DOTFILES}" "${local_link}"
        elif (( FORCE )) && [[ -L "${local_link}" ]]; then
            act "relink ${local_link}"
            run rm -- "${local_link}"
            run ln -s -- "${LOCAL_DOTFILES}" "${local_link}"
        else
            warn "${local_link} exists and is not our symlink"
        fi
    fi

    local kind src tgt abs_src abs_tgt
    while IFS=$'\t' read -r kind src tgt; do
        case "${kind}" in
            link)
                abs_src="${DOTFILES_SRC}/${src}"
                abs_tgt="${HOME}/${tgt}"
                if [[ "${MODE}" == uninstall ]]; then
                    uninstall_link "${abs_src}" "${abs_tgt}"
                else
                    install_link "${abs_src}" "${abs_tgt}"
                fi
                ;;
            husk)
                [[ "${MODE}" == uninstall ]] || install_husk "${tgt}"
                ;;
            *) die "unknown manifest kind: ${kind}" ;;
        esac
    done < <(read_manifest "${host_os}")

    printf '\nsummary: ok=%d changed=%d conflict=%d\n' "${N_OK}" "${N_CHANGED}" "${N_CONFLICT}"

    case "${MODE}" in
        check)
            (( N_CHANGED == 0 && N_CONFLICT == 0 )) || exit 1
            ;;
        dry-run)
            printf 'dry-run: re-run with --apply to make changes\n'
            ;;
        apply|uninstall)
            (( N_CONFLICT == 0 )) || exit 1
            ;;
    esac
}

main "$@"
