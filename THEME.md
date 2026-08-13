# Theme

One Nord-derived palette across every app. When adding a config, take its
colors from here rather than inventing new ones.

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

| App        | File                                    |
| ---------- | --------------------------------------- |
| dwm        | `dwm/config.def.h` (colors + `fonts[]`) |
| alacritty  | `config/alacritty/alacritty.toml`       |
| guake      | `guake/guake.dconf`                     |
| dunst      | `config/dunst/dunstrc`                  |
| tmux       | `config/tmux/tmux.conf`                 |

dwm's `config.h` is gitignored and generated from `config.def.h`, so edit the
`.def` file and rebuild. Same for `st` and `slstatus`.

## Changing a color

Update `THEME.md` first, then the files above. `guake/guake.dconf` stores
colors as 16-bit components (`#RRRRGGGGBBBB`), so `#88C0D0` becomes
`#8888C0C0D0D0`.
