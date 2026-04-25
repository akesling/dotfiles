# dotfiles

Personal config for shells, editors, tmux, git. Installed via symlinks from a
declarative manifest.

## Install

```sh
git clone <this-repo> ~/dotfiles
cd ~/dotfiles
./setup.sh             # dry-run: shows what would change
./setup.sh --apply     # actually link
./setup.sh --check     # exit 0 iff everything is linked correctly (CI-friendly)
./setup.sh --uninstall # remove only the symlinks this script created
```

Conflicting real files are moved to `~/.dotfiles-backup/<timestamp>/` before
linking. Conflicting symlinks abort with a warning unless `--force` is passed.

## Layout

| Path             | Purpose                                                    |
| ---------------- | ---------------------------------------------------------- |
| `manifest.txt`   | Declares every link (`<os> link <src> <target>`) and husk. |
| `setup.sh`       | Idempotent installer. `shellcheck`-clean.                  |
| `local_dotfiles/`| Per-machine overrides. Git-ignored. Never commit.          |
| `.vimrc`, `.zshrc`, `nvim/`, … | The tracked configs themselves.              |

## Per-machine overrides (the "husk" pattern)

Tracked rc files end with a `source` of a matching file under
`~/.local/dotfiles/` (a symlink to `local_dotfiles/`). Examples:

```
.vimrc:395   source ~/.local/dotfiles/.vimrc
.bashrc:37   source ~/.local/dotfiles/.bashrc
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
