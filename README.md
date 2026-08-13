# .dotfiles

Personal configuration for a Fedora + dwm desktop, with the editor and
terminal parts shared with a Mac.

```
config/     -> ~/.config/*        symlinked per directory
home/       -> ~/*                dotfiles that live at the top of $HOME
guake/                            guake settings (dconf, not a config file)
dwm/ st/ slstatus/                suckless builds, git submodules
scripts/                          installer and helpers
scripts/macos/                    mac-only tooling
docs/                             upgrade notes and archived configs
```

`install.sh` links every directory under `config/` into `~/.config`, so
editing a file in this repo takes effect immediately - no copy step, nothing
to re-sync.

## Setup

Clone with submodules:

```sh
git clone --recursive https://github.com/s4pun1s7/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles && ./scripts/install.sh
```

To update submodules:

```sh
git submodule update --init --recursive
```

## Install script

```sh
./scripts/install.sh          # dependencies, build suckless, link configs
./scripts/install.sh -l       # link configs only
./scripts/install.sh -b       # rebuild and install dwm/st/slstatus
./scripts/install.sh -d       # dependencies only
```

It detects the platform and links accordingly:

| Set    | Configs                                                        |
| ------ | -------------------------------------------------------------- |
| shared | vim, nvim, tmux, alacritty                                     |
| linux  | dunst, picom, flameshot, volumeicon, htop, Thunar, guake, dwm autostart |
| macos  | yabai, skhd                                                    |

The mac Flutter setup (`scripts/macos/flutter-setup.sh`) calls
`install.sh --links` for the shared set, so both machines get the same editor
and terminal config from one source.

On the Mac, yabai + skhd reproduce the dwm keymap on the Alt modkey
(`config/skhd/skhdrc`). dwm itself uses Super, so Alt stays free on Linux:
`config/tmux/tmux.conf` branches on `uname` and binds pane navigation to
Alt+hjkl on Fedora, Ctrl+hjkl on the Mac.

## What runs the desktop

- `/usr/local/bin/start-dwm` (from `scripts/start-dwm.sh`) is the X session,
  and just restarts dwm in a loop
- dwm's autostart patch runs `~/.local/share/dwm/autostart.sh`, symlinked to
  `scripts/autostart.sh`, which pins the monitors, sets the keyboard layouts,
  applies the wallpaper, and starts picom, nm-applet, guake and slstatus

### Restarting dwm

`Mod+Ctrl+Shift+q` re-execs dwm in place. Your windows are X clients, so they
survive regardless; what used to be lost was dwm's own bookkeeping. The
`SEAMLESS_RESTART_PATCH` now stores that in X properties - client tags and
monitor, client order, nmaster, mfact, per-tag layouts, and (with
`SAVEFLOATS_PATCH`) floating geometry - so the session comes back as it was.

The state lives in the X server (`_DWM_MONITOR_TAGS_*` on the root window,
`_DWM_CLIENT_TAGS` on each client), so it survives any number of dwm restarts
but **not** a reboot or logout, which takes the X server with it.

Monitor arrangement is RandR state and belongs to the X server too, so it is
never disturbed by a dwm restart. `scripts/monitors.sh` exists for login and
hotplug; it is a no-op unless the layout is actually wrong, and `-f` forces it.

### Graphics and gaming

`scripts/gamecheck.sh` reports driver, Mesa/Vulkan, 32-bit userspace, CPU/GPU
power state and compositor settings, with a fix hint on every warning. It is
read-only; `-q` prints only problems and it exits non-zero on a FAIL, so it
works as a smoke test after a kernel or Mesa update.

This box is a MacPro6,1: dual FirePro D300 (Pitcairn, GCN 1.0) on `amdgpu`.
Only the second card has outputs wired, so it both renders and drives the two
panels - the first card sits idle and is not usable for games. There is no
CrossFire and no PRIME offload to arrange; treat it as a single-GPU machine.

## Suckless submodules

`dwm` tracks `flexipatch`, `st` and `slstatus` track `main`; the branches are
recorded in `.gitmodules`. Each builds from `config.def.h` - `config.h` is
gitignored and regenerated, so **edit `config.def.h`** and rebuild with
`./scripts/install.sh -b`.

```sh
./scripts/submodules.sh status            # branch, dirt, push state
./scripts/submodules.sh sync              # pull tracked branches
./scripts/submodules.sh push "message"    # commit, push, bump pointers
```

## Theme

Colors and fonts are shared across dwm, alacritty, guake, dunst and tmux.
See [THEME.md](THEME.md) before changing any of them.
