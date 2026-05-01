#!/usr/bin/env bash
#
# tests/snapshot.sh — prompt snapshot tests.
#
# Captures the literal PS1 / PROMPT / RPROMPT format strings after each shell
# has fully sourced its rc files, and diffs them against checked-in fixtures.
# Catches structural drift (token added/removed, newlines moved, color codes
# changed) without tripping on per-machine values, since the format string
# itself contains only escape codes — not the expanded host/cwd/date.
#
# Usage:
#   tests/snapshot.sh           # diff against fixtures; exit 1 on mismatch
#   tests/snapshot.sh --update  # rewrite fixtures from current output

set -euo pipefail
IFS=$'\n\t'

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIXTURES="${DIR}/fixtures"
UPDATE=0

[[ "${1:-}" == "--update" ]] && UPDATE=1

# Capture the prompt format string from a shell after rc-file load.
# stderr is suppressed so non-tty warnings (e.g. zsh "can't change option: zle")
# don't pollute the snapshot.
capture_bash() {
    bash -ic 'printf "PS1=<%s>\n" "$PS1"' 2>/dev/null
}

capture_zsh() {
    zsh -ic 'printf "PROMPT=<%s>\n" "$PROMPT"; printf "RPROMPT=<%s>\n" "${RPROMPT-}"' 2>/dev/null
}

check_one() {
    local name=$1
    local fixture="${FIXTURES}/${name}.txt"
    local current=$2

    if (( UPDATE )); then
        printf '%s\n' "${current}" > "${fixture}"
        printf 'wrote %s\n' "${fixture}"
        return 0
    fi

    if [[ ! -f "${fixture}" ]]; then
        printf 'no fixture: %s (run --update to create)\n' "${fixture}" >&2
        return 1
    fi

    if (( UPDATE )); then
        printf '%s\n' "${current}" > "${fixture}"
        printf 'wrote %s\n' "${fixture}"
        return 0
    fi

    if [[ ! -f "${fixture}" ]]; then
        printf 'no fixture: %s (run --update to create)\n' "${fixture}" >&2
        return 1
    fi

    if diff -u "${fixture}" <(printf '%s\n' "${current}") >&2; then
        printf 'ok %s\n' "${name}"
    else
        printf 'mismatch: %s (run --update if intentional)\n' "${name}" >&2
        return 1
    fi
}

failures=0
check_one bash_prompt "$(capture_bash)" || failures=$((failures + 1))
check_one zsh_prompt  "$(capture_zsh)"  || failures=$((failures + 1))

if (( failures > 0 )); then
    printf '%d snapshot mismatch(es)\n' "${failures}" >&2
    exit 1
fi
printf 'all snapshots match\n'
