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
(`config/skhd/skhdrc`), which is why tmux uses Ctrl+hjkl for pane
navigation on both machines rather than Alt.

## What runs the desktop

- `/usr/local/bin/start-dwm` (from `scripts/start-dwm.sh`) is the X session,
  and just restarts dwm in a loop
- dwm's autostart patch runs `~/.local/share/dwm/autostart.sh`, symlinked to
  `scripts/autostart.sh`, which starts picom, nm-applet, guake and slstatus

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
