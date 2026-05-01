# dotfiles

Personal config for shells, editors, tmux, and git. Bash, zsh, vim, and nvim
are all first-class peers — no aliasing, no preferred fork. Installed via
symlinks declared in `manifest.txt`. macOS and Linux supported.

## Quickstart

```sh
git clone <this-repo> ~/dotfiles
cd ~/dotfiles
./packages.sh --bootstrap-brew    # one-time on macOS w/o brew
./packages.sh --install-all       # install required + optional packages
./setup.sh --apply                # link rc files into $HOME
./vim-plugins.sh                  # bootstrap Vundle + run :PluginInstall
./doctor.sh                       # health check (links, syntax, perf budgets)
```

Conflicting real files are moved to `~/.dotfiles-backup/<timestamp>/` before
linking. Conflicting symlinks abort with a warning unless `--force` is passed.

On a fresh macOS box with no package manager, `packages.sh` automatically
bootstraps Homebrew under `~/.local/homebrew` using the "untar anywhere"
install from <https://docs.brew.sh/Installation> so `brew` never needs sudo.

## Layout

| Path                           | Purpose                                                            |
| ------------------------------ | ------------------------------------------------------------------ |
| `manifest.txt`                 | Declares every link (`<os> link <src> <target>`) and husk slot.    |
| `packages.txt`                 | Expected commands and their package names per OS / package manager.|
| `setup.sh`                     | Idempotent linkfarm installer (`--dry-run`/`--apply`/`--check`/`--uninstall`). |
| `packages.sh`                  | Verifies / installs commands declared in `packages.txt`.           |
| `doctor.sh`                    | Health check (commands, links, rc syntax, editors, perf budgets).  |
| `vim-plugins.sh`               | Bootstraps Vundle and runs `:PluginInstall`.                       |
| `lib/common.sh`                | Helpers for the install/check scripts (NOT sourced by shells).     |
| `lib/sh/common.sh`             | Shared interactive-shell layer (PATH/env/aliases/fzf) — see below. |
| `vim/shared/common.vim`        | Shared vim+nvim base (options/mappings/colors/autocmds).           |
| `tests/snapshot.sh`            | Prompt format snapshot tests; fixtures in `tests/fixtures/`.       |
| `bin/`                         | Personal scripts; auto-added to PATH by `lib/sh/common.sh`.        |
| `linux/`                       | Linux-only files (`.xinitrc`, `.Xresources`, `.Xmodmap`).          |
| `local_dotfiles/`              | Per-machine overrides. Git-ignored. Never commit.                  |
| `.bashrc`, `.zshrc`, `.vimrc`, `nvim/init.lua` | The four first-class entry points.                 |

## Shells (bash + zsh)

Both shells share `lib/sh/common.sh` for PATH, environment, aliases, dircolors,
and fzf integration. Native sections live in each rc file:

- **`.bashrc`**: history options, prompt (`\[\e[..m\]` escapes — zero subshells
  per redraw), `set -o vi`, bash-completion@2 (sourced from Homebrew when
  present), bash-4-only `shopt` flags gated by `$BASH_VERSINFO`.
- **`.zshrc`**: history options, prompt (`%F{...}%f`/`%m`/`%~`/`%*`/`%!` —
  zero subshells per redraw), compinit with daily cache, completion menu,
  vi-mode keymap.

Cold-start budgets (verified each `doctor.sh` run): bash <150ms, zsh <150ms.

## Editors (vim + nvim)

Both editors share `vim/shared/common.vim` for options, mappings, colors, and
filetype tweaks. Native sections live in each entry point:

- **`.vimrc`**: Vundle plugin block, YouCompleteMe, NERDTree, Mundo, latex-suite,
  airline tabline, cscope.
- **`nvim/init.lua`**: lazy.nvim spec (`require("config.lazy")`), nvim-cmp
  completion, nvim-only wrap-width shading via decoration provider.

Cold-open budgets: vim <100ms, nvim <100ms. The `g:dotfiles_user` global
(default `$USER`) parametrizes the `<leader>o` TODO map.

`.ideavimrc` `silent! source`s `vim/shared/common.vim` so JetBrains IDEs get
the same mappings (minus features IdeaVim doesn't implement).

## Per-machine overrides (the "husk" pattern)

Each first-class entry point ends with a guarded `source` of a matching file
under `~/.local/dotfiles/`:

```sh
# .bashrc
[ -r ~/.local/dotfiles/.bashrc ] && source ~/.local/dotfiles/.bashrc
```

```vim
" .vimrc
if filereadable(expand('~/.local/dotfiles/.vimrc'))
    source ~/.local/dotfiles/.vimrc
endif
```

```lua
-- nvim/init.lua
local husk = vim.fn.expand('~/.local/dotfiles/init.lua')
if vim.fn.filereadable(husk) == 1 then dofile(husk) end
```

`.gitconfig` follows the same pattern via `[include] path = ~/.local/dotfiles/.gitconfig`,
which is where per-machine `user.name` / `user.email` live.

`setup.sh` creates these as empty husks so the `source` is a no-op on a fresh
machine. Drop machine-specific tweaks (work env vars, identity, host paths,
GUI font sizes) into the husk; nothing under `local_dotfiles/` is committed.

Example husk contents:

```sh
# ~/.local/dotfiles/.zshrc
export PATH="${PATH}:${HOME}/.bun/bin"
[ -s "${HOME}/.bun/_bun" ] && source "${HOME}/.bun/_bun"
```

```ini
# ~/.local/dotfiles/.gitconfig
[user]
    name  = Your Name
    email = you@example.com
```

## Tests + perf log

- `tests/snapshot.sh` captures the literal `PS1` / `PROMPT` / `RPROMPT` strings
  after each shell sources its rc files and diffs against `tests/fixtures/`.
  Run `tests/snapshot.sh --update` after an intentional prompt change.
- `doctor.sh` measures cold-start times for bash/zsh/vim/nvim, fails if any
  exceeds its budget, and appends each measurement to
  `~/.local/dotfiles/perf.log` as `timestamp,tool,ms` so regressions become
  visible over time.

## Adding a new dotfile

1. Drop the file in the repo.
2. Add a row to `manifest.txt`:
   ```
   all link .my-new-rc .my-new-rc
   ```
   Use `macos` or `linux` instead of `all` for OS-gated files. For directories,
   point `target` at the destination (e.g. `nvim` → `.config/nvim`).
3. `./setup.sh --apply`.

If the file should support per-machine overrides, also add `all husk -
.my-new-rc` and source `~/.local/dotfiles/.my-new-rc` at the bottom of the
file itself.

## Notes

- `setup.sh` works from any cwd (uses its own location, not `pwd`).
- Default `setup.sh` mode is dry-run — no flag, no changes.
- Solarized is the single source of truth for colors: `dircolors/dircolors.ansi-dark`
  for ls, `vim-colors-solarized` (Vundle) for vim, `solarized.nvim` (lazy) for nvim,
  hand-rolled palette in `.tmux.conf`.
