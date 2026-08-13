# Theme

One Nord-derived palette across every app. When adding a config, take its
colors from here rather than inventing new ones.

On Fedora this palette is the *fallback*: pywal derives a palette from the
current wallpaper and overrides it at runtime. See "Wallpaper colors" below.
Everything here is still what you get on the Mac, on a fresh box, and any time
pywal has not run — so keep it correct.

## Palette

| Role       | Hex       | Used for                                  |
| ---------- | --------- | ----------------------------------------- |
| background | `#14171E` | terminal and bar background               |
| foreground | `#C8D0DC` | body text                                 |
| surface    | `#1C212B` | inactive borders, ANSI black              |
| overlay    | `#2A303C` | bright black                              |
| accent     | `#88C0D0` | selection, active border, focused tag     |
| accent alt | `#8FBCBB` | hidden/secondary highlight, bright cyan   |
| red        | `#BF616A` | urgent, errors                            |
| green      | `#A3BE8C` | success                                   |
| yellow     | `#EBCB8B` | warnings, tmux messages                   |
| blue       | `#81A1C1` | ANSI blue                                 |
| magenta    | `#B48EAD` | ANSI magenta                              |
| white      | `#E5E9F0` | ANSI white                                |
| bright fg  | `#D8DEE9` | selected text                             |

## Font

`JetBrains Mono` at size 10 for bars and menus, 11 for terminals.

## Where each value lives

| App        | File                                       |
| ---------- | ------------------------------------------ |
| dwm        | `dwm/config.def.h` (colors + `fonts[]`)    |
| alacritty  | `config/alacritty/colors-nord.toml`        |
| guake      | `guake/guake.dconf`                        |
| dunst      | `config/dunst/dunstrc`                     |
| tmux       | `config/tmux/tmux.conf` (DESIGN section)   |

dwm's `config.h` is gitignored and generated from `config.def.h`, so edit the
`.def` file and rebuild. Same for `st` and `slstatus`.

Alacritty is the odd one: imports load first and the importing file loads
*last*, so colors must live in an imported file, never in `alacritty.toml`
itself, or they would beat the pywal import.

## Changing a color

Update `THEME.md` first, then the files above. `guake/guake.dconf` stores
colors as 16-bit components (`#RRRRGGGGBBBB`), so `#88C0D0` becomes
`#8888C0C0D0D0`.

## Wallpaper colors

`scripts/setwallpaper.sh` picks a wallpaper from `~/wallpapers`, runs pywal
over it, and reloads the four apps that consume the result. `Mod+Ctrl+w` rolls
a new one; login restores the last one with `-r` (no re-extraction, so it stays
fast). Without pywal installed the script degrades to a plain `feh --bg-fill`,
which is what the Mac gets.

pywal renders `config/wal/templates/*` into `~/.cache/wal/`:

| Template                 | Consumed by                                            |
| ------------------------ | ------------------------------------------------------ |
| `colors-dwm.Xresources`  | `xrdb -merge`, then dwm's xrdb patch via `fsignal:xrdb` |
| `colors-alacritty.toml`  | `general.import` in `alacritty.toml`                    |
| `colors-tmux.conf`       | `source-file -q` at the end of `tmux.conf`              |
| `colors-dunst.conf`      | symlinked to `~/.config/dunst/dunstrc.d/50-wal.conf`    |

Each one maps pywal's slots onto the roles in the palette table: `background`
and `foreground` as-is, `color0` for surface, `color4` for accent, `color1` for
red/urgent. Adjust the mapping in the template, not in the app config.

This needs `XRDB_PATCH` and `FSIGNAL_PATCH` enabled in `dwm/patches.def.h`;
both are, and dwm must be rebuilt and restarted if they are ever turned off.
`st` has no Xresources support in this build, so it keeps the static palette.
