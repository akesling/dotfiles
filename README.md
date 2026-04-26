# dotfiles

Personal config for shells, editors, tmux, git. Installed via symlinks from a
declarative manifest.

## Install

```sh
git clone <this-repo> ~/dotfiles
cd ~/dotfiles
./packages.sh --bootstrap-brew  # install Homebrew under ~/.local/homebrew (no sudo)
./packages.sh --check     # report missing commands (exit 1 if any required missing)
./packages.sh --install   # install missing required packages via brew/apt/dnf/pacman
./packages.sh --install-all  # required + optional
./setup.sh                # dry-run: shows what would change
./setup.sh --apply        # actually link
./setup.sh --check        # exit 0 iff everything is linked correctly (CI-friendly)
./setup.sh --uninstall    # remove only the symlinks this script created
./vim-plugins.sh          # bootstrap Vundle + run :PluginInstall (one-time)
./doctor.sh               # health check: commands, links, rc syntax, editor smoke tests
```

Conflicting real files are moved to `~/.dotfiles-backup/<timestamp>/` before
linking. Conflicting symlinks abort with a warning unless `--force` is passed.

On a fresh macOS box with no package manager, `packages.sh` automatically
bootstraps Homebrew under `~/.local/homebrew` using the "untar anywhere"
install from <https://docs.brew.sh/Installation> so `brew` never needs sudo.

## Layout

| Path                | Purpose                                                    |
| ------------------- | ---------------------------------------------------------- |
| `manifest.txt`      | Declares every link (`<os> link <src> <target>`) and husk. |
| `packages.txt`      | Expected commands and their package names per OS / PM.     |
| `setup.sh`          | Idempotent linkfarm installer.                             |
| `packages.sh`       | Verifies / installs commands declared in `packages.txt`.   |
| `doctor.sh`         | Deeper health check (commands, links, rc syntax, editors). |
| `vim-plugins.sh`    | Bootstraps Vundle and runs `:PluginInstall`.               |
| `lib/common.sh`     | Shared helpers (sourced by the scripts above).             |
| `local_dotfiles/`   | Per-machine overrides. Git-ignored. Never commit.          |
| `.vimrc`, `.zshrc`, `nvim/`, … | The tracked configs themselves.                 |

## Per-machine overrides (the "husk" pattern)

Tracked rc files end with a guarded `source` of a matching file under
`~/.local/dotfiles/` (a symlink to `local_dotfiles/`), e.g.:

```sh
[ -r ~/.local/dotfiles/.bashrc ] && source ~/.local/dotfiles/.bashrc
```

`setup.sh` `touch`es those files as empty husks so the `source` is a no-op on a
fresh machine. Drop machine-specific tweaks (work-only env vars, host paths,
GUI font sizes) into the husk; nothing under `local_dotfiles/` is committed.

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
.my-new-rc` and `source ~/.local/dotfiles/.my-new-rc` at the bottom of the rc
file itself.

## Notes

- `setup.sh` works from any cwd (uses its own location, not `pwd`).
- Default mode is dry-run — no flag, no changes.
- macOS and Linux are both supported; Linux-only files (`.xinitrc`,
  `.Xresources`, `.Xmodmap`) are skipped on macOS.
