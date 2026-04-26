# shellcheck shell=bash
# lib/common.sh — shared helpers for setup.sh / doctor.sh / vim-plugins.sh.
# Source this; do not execute directly.

# Counters used by ok/act/warn. Scripts may read these to decide exit status.
: "${N_OK:=0}"
: "${N_CHANGED:=0}"
: "${N_CONFLICT:=0}"

die()  { printf 'error: %s\n' "$*" >&2; exit 2; }
ok()   { printf '  \033[32mok\033[0m       %s\n' "$*";  N_OK=$(( N_OK + 1 )); }
act()  { printf '  \033[33mchange\033[0m   %s\n' "$*";  N_CHANGED=$(( N_CHANGED + 1 )); }
warn() { printf '  \033[31mconflict\033[0m %s\n' "$*";  N_CONFLICT=$(( N_CONFLICT + 1 )); }
note() { printf '  \033[33mwarn\033[0m     %s\n' "$*"; }  # advisory; doesn't tally

detect_os() {
    case "$(uname -s)" in
        Darwin) echo macos ;;
        Linux)  echo linux ;;
        *)      echo unknown ;;
    esac
}

# Read manifest, filter by os, emit "kind\tsource\ttarget" rows.
# Caller must set MANIFEST.
read_manifest() {
    local host_os=$1 line os kind src tgt
    [[ -f "${MANIFEST}" ]] || die "manifest not found: ${MANIFEST}"
    while IFS= read -r line || [[ -n "${line}" ]]; do
        line="${line%%#*}"
        [[ -z "${line// }" ]] && continue
        IFS=$' \t' read -r os kind src tgt <<<"${line}"
        [[ "${os}" == "all" || "${os}" == "${host_os}" ]] || continue
        printf '%s\t%s\t%s\n' "${kind}" "${src}" "${tgt}"
    done < "${MANIFEST}"
}

# Detect the active package manager. Echoes one of: brew, apt, dnf, pacman, unknown.
detect_pm() {
    if command -v brew    >/dev/null 2>&1; then echo brew;    return; fi
    if command -v apt-get >/dev/null 2>&1; then echo apt;     return; fi
    if command -v dnf     >/dev/null 2>&1; then echo dnf;     return; fi
    if command -v pacman  >/dev/null 2>&1; then echo pacman;  return; fi
    echo unknown
}

# Read packages.txt and emit "command\tcategory\tpkg" rows for the given PM.
# Rows whose package column is "-" for the active PM are skipped (the tool is
# either built-in or not packaged for that OS). Caller must set PACKAGES.
read_packages() {
    local pm=$1 line cmd cat brew_p apt_p dnf_p pacman_p pkg
    [[ -f "${PACKAGES}" ]] || die "packages list not found: ${PACKAGES}"
    while IFS= read -r line || [[ -n "${line}" ]]; do
        line="${line%%#*}"
        [[ -z "${line// }" ]] && continue
        IFS=$' \t' read -r cmd cat brew_p apt_p dnf_p pacman_p <<<"${line}"
        case "${pm}" in
            brew)   pkg="${brew_p}" ;;
            apt)    pkg="${apt_p}" ;;
            dnf)    pkg="${dnf_p}" ;;
            pacman) pkg="${pacman_p}" ;;
            *)      pkg="-" ;;
        esac
        [[ "${pkg}" == "-" ]] && continue
        printf '%s\t%s\t%s\n' "${cmd}" "${cat}" "${pkg}"
    done < "${PACKAGES}"
}
