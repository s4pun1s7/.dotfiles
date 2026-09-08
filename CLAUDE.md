# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal configuration for a Fedora + dwm desktop (a MacPro6,1), with the editor and
terminal configs shared with a Mac. `README.md` documents the layout and the desktop
session; `THEME.md` is the single source of truth for colors and fonts. Read both —
this file only covers what they leave implicit.

## Commands

```sh
./scripts/install.sh          # deps, build+install suckless, link configs
./scripts/install.sh -l       # relink configs only (fast, safe to re-run)
./scripts/install.sh -b       # rebuild + sudo make install dwm/st/slstatus
./scripts/install.sh -d       # dependencies only (Fedora/dnf)
./scripts/install.sh -c -b    # clean first, then rebuild

./scripts/submodules.sh status         # branch, dirt, push state of dwm/st/slstatus
./scripts/submodules.sh sync           # pull each submodule's tracked branch
./scripts/submodules.sh push "message" # commit+push submodules, then bump pointers here

./scripts/gamecheck.sh -q     # read-only graphics/perf smoke test; non-zero exit on FAIL
```

`install.sh` refuses to run as root but calls `sudo` itself for `dnf` and
`make install`. Log out and back in to pick up a new dwm build (or `Mod+Ctrl+Shift+q`
to re-exec dwm in place, which preserves the session).

## Things that will bite you

**Configs are symlinks, not copies.** `install.sh` links whole directories from
`config/` into `~/.config`. Editing `~/.config/tmux/tmux.conf` *is* editing this repo,
and edits take effect immediately with no sync step. Never "fix" a config by replacing
a symlink with a real file.

**Edit `config.def.h`, never `config.h`.** `dwm/`, `st/` and `slstatus/` build from
`config.def.h` (and dwm's `patches.def.h`); the generated `config.h`/`patches.h` are
gitignored. suckless Makefiles only copy the template when the generated header is
missing and `make clean` leaves it behind — which is why `install.sh -b` explicitly
`rm -f config.h patches.h` before building. A manual `make` in those directories will
silently keep your old settings.

**The suckless dirs are git submodules with their own remotes** (`dwm` on branch
`flexipatch`, `st` and `slstatus` on `main`, per `.gitmodules`). A change there is a
commit in that repo plus a pointer bump here — use `scripts/submodules.sh push`, which
does both and shows the diffstat first. `git status` in this repo shows them as ` m`.

**Adding a config means adding it to a table.** `install.sh` has three arrays —
`LINKS_SHARED`, `LINKS_LINUX`, `LINKS_MACOS` — and links only the sets matching
`uname`. A new file under `config/` that isn't in a table is simply never linked. Put
anything X11-specific in `LINKS_LINUX` so the Mac (`scripts/macos/flutter-setup.sh`
calls `install.sh --links`) doesn't pick it up.

**Two config formats aren't plain files.** Guake settings are a dconf dump
(`guake/guake.dconf`, colors as 16-bit components: `#88C0D0` → `#8888C0C0D0D0`), loaded
by `install.sh`, not symlinked. Alacritty colors must live in an imported file
(`colors-nord.toml`), never in `alacritty.toml` — imports load first there, so anything
in the main file would beat the pywal import.

**The palette is runtime-generated on Linux.** `scripts/setwallpaper.sh` runs pywal
over the current wallpaper and reloads the consumers, so `THEME.md`'s Nord palette is
the fallback (Mac, fresh box, pywal not yet run) rather than what you see. Update
`THEME.md` first when changing a color, then the per-app files it lists.

**Modkeys differ per platform on purpose.** dwm uses Super, leaving Alt free, and
`config/tmux/tmux.conf` branches on `uname` to bind Alt+hjkl on Fedora and Ctrl+hjkl on
the Mac; yabai+skhd reproduce the dwm keymap on Alt on macOS. Keep that split when
touching bindings. (Unrelated: the `~/drwm` Rust WM uses Alt, matching vanilla dwm.)

## Session wiring

- `/usr/local/bin/start-dwm` (installed from `scripts/start-dwm.sh`) is the X session
  and restarts dwm in a loop.
- dwm's autostart patch runs `~/.local/share/dwm/autostart.sh`, symlinked to
  `scripts/autostart.sh` — monitors, keyboard layouts, wallpaper, picom, nm-applet,
  guake, slstatus.
- dwm's seamless-restart patch stores tags, client order, nmaster, mfact, layouts and
  float geometry in X properties (`_DWM_MONITOR_TAGS_*` on root, `_DWM_CLIENT_TAGS` per
  client), so restarts are transparent but a logout or reboot resets them.
- `docs/` holds upgrade notes (flexipatch, rice pack, performance) and archived
  configs; check `docs/dwm-flexipatch-NOTES.txt` before touching patch selection.
