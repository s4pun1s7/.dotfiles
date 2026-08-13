# guake

Guake drop-down terminal theme, kept consistent with the dwm rice.

Guake has no config file — everything lives in dconf under `/apps/guake/`.
`guake.dconf` is the tracked snapshot.

## Usage

```sh
./apply.sh          # load guake.dconf into dconf
./apply.sh --dump   # save current dconf settings back into guake.dconf
```

Colors and fonts apply live; hiding the tab bar needs `guake --restart`
(this closes open guake tabs).

## Theme

Same palette as `dwm/config.h` and `~/.config/alacritty/alacritty.toml`:

| Role       | Color     |
| ---------- | --------- |
| background | `#14171E` |
| foreground | `#C8D0DC` |
| black      | `#1C212B` |
| red        | `#BF616A` |
| green      | `#A3BE8C` |
| yellow     | `#EBCB8B` |
| blue       | `#81A1C1` |
| magenta    | `#B48EAD` |
| cyan       | `#88C0D0` |
| white      | `#E5E9F0` |

Font is `JetBrains Mono 10`, matching `fonts[]` and `dmenufont` in dwm.
The tab bar, scrollbar, and fullscreen toolbar are hidden for a bare
terminal window.
