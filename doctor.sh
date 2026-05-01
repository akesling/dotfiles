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
    if [[ -r "${HOME}/.inputrc" ]]; then
        ok ".inputrc readable"
    elif [[ -e "${HOME}/.inputrc" ]]; then
        fail ".inputrc exists but is not readable"
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

    printf '\n== performance budgets ==\n'
    perf_check

    printf '\ndoctor: issues=%d\n' "${ISSUES}"
    (( ISSUES == 0 ))
}

# perf_check: measure cold-start times for bash, zsh, vim, and nvim against
# documented budgets. Each measurement is appended to ~/.local/dotfiles/perf.log
# as CSV (timestamp,tool,ms) so regressions become visible over time.
perf_check() {
    local perf_log="${HOME}/.local/dotfiles/perf.log"
    mkdir -p -- "$(dirname "${perf_log}")"
    [[ -f "${perf_log}" ]] || printf 'timestamp,tool,ms\n' > "${perf_log}"

    perf_one bash 150 bash -ic exit
    perf_one zsh  150 zsh  -ic exit

    # Prefer the system vim binary so we don't accidentally measure nvim via
    # an alias or PATH precedence.
    if [[ -x /usr/bin/vim ]]; then
        perf_one vim 100 /usr/bin/vim -es -u "${HOME}/.vimrc" -c qa
    elif command -v vim >/dev/null 2>&1; then
        perf_one vim 100 vim -es -u "${HOME}/.vimrc" -c qa
    else
        note "vim not on PATH, skipping perf check"
    fi

    perf_one nvim 100 nvim --headless +qa
}

# perf_one <label> <budget_ms> <cmd...>
# Runs the command three times, takes the best wall-time, appends the result
# to the perf log, and fails if it exceeds the budget.
perf_one() {
    local label=$1 budget=$2; shift 2
    local first_arg=$1
    if ! command -v "${first_arg}" >/dev/null 2>&1 && [[ ! -x "${first_arg}" ]]; then
        note "${label}: ${first_arg} unavailable, skipping"
        return
    fi

    local best_ms=999999 ms _
    for _ in 1 2 3; do
        ms=$(measure_ms "$@") || { fail "${label}: command failed"; return; }
        (( ms < best_ms )) && best_ms=${ms}
    done

    local perf_log="${HOME}/.local/dotfiles/perf.log"
    local ts
    ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf '%s,%s,%d\n' "${ts}" "${label}" "${best_ms}" >> "${perf_log}"

    if (( best_ms <= budget )); then
        ok "${label}: ${best_ms}ms (budget ${budget}ms)"
    else
        fail "${label}: ${best_ms}ms exceeds ${budget}ms budget"
    fi
}

# measure_ms <cmd...>: print elapsed wall time as integer milliseconds.
# Uses perl Time::HiRes for portability (macOS `date` lacks %N).
measure_ms() {
    perl -MTime::HiRes=time -e '
        open(my $out, ">&", STDOUT) or die;
        open(STDIN,  "<", "/dev/null") or die;
        open(STDOUT, ">", "/dev/null") or die;
        open(STDERR, ">", "/dev/null") or die;
        my $t0 = time();
        my $ec = system(@ARGV);
        printf $out "%d\n", int((time() - $t0) * 1000);
        exit($ec == 0 ? 0 : 1);
    ' -- "$@"
}

main "$@"
