# The Makima palette

Wallpaper: `wallpapers/makima-torii.jpg`. Artwork "マキマ" by Hikaku (https://www.pixiv.net/en/artworks/113984261), found via https://wallhaven.cc/w/p9pzk9. The full-size original is kept locally in `wallpapers/original/`, which is not in git.
Colors were sampled from the image with ffmpeg's `palettegen` and then adjusted by hand for readability.
Early mockups: `design/mockup.png` and `design/bar-comparison.png` (option B was chosen).

## Main colors

| Name | Hex | Where in the image | Used for |
|---|---|---|---|
| night | `#140b07` | dark corners | bar, terminal, and menu backgrounds |
| surface | `#22140e` | – | inactive elements, unselected menu rows |
| border | `#3a231a` | – | thin separators, selection background |
| muted | `#9f7f70` | shaded skin | empty workspace numbers, secondary text |
| text | `#e8dccb` | white shirt | main text |
| crimson | `#e22e0e` | hair, torii gate | **main accent**: focused window border, active workspace, cursors |
| oxblood | `#7f1d06` | hair shadows | bar underline, low-urgency border, critical background |
| amber | `#f2a33a` | eyes | second accent: volume, progress bars, critical border |
| copper | `#c56b46` | lit skin | low battery, resize mode |
| teal | `#58b4c4` | ghostly hands | cool contrast: Wi-Fi, Bluetooth, command options (was `#4f8f88`, retuned with the set below) |

## Harmonized colors ("uyumlu")

Built in OKLCH around amber and crimson so that more colors can sit next to each other (terminal programs, command-line highlighting, Claude Code) without two of them looking alike. All four share the same perceived lightness (L 0.72-0.80) and spread around the hue wheel; with amber and crimson, every pair is at least 13 OKLab dE apart. Each one passes 8:1 contrast on `night`.

| Name | Hex | OKLCH (L C H) | Used for |
|---|---|---|---|
| rose | `#f196a4` | 0.77 0.110 10 | variables in the command line, terminal magenta |
| sage | `#9fc17d` | 0.77 0.099 130 | strings, plugged-in battery, terminal green |
| teal | `#58b4c4` | 0.72 0.090 210 | options, Wi-Fi, terminal cyan |
| lavender | `#b7b6f6` | 0.80 0.090 285 | paths, terminal blue |

Machine-readable copy: `design/palette.json`. Swatches: `design/palette.svg`.

## Terminal (foot) 16 colors

| | Normal | Bright |
|---|---|---|
| black | `#22140e` | `#6b5348` |
| red | `#e22e0e` | `#ff5a3c` |
| green (sage) | `#9fc17d` | `#bada9c` |
| yellow | `#f2a33a` | `#ffc266` |
| blue (lavender) | `#b7b6f6` | `#d1d1ff` |
| magenta (rose) | `#f196a4` | `#ffb3bf` |
| cyan (teal) | `#58b4c4` | `#7cccdb` |
| white | `#c9b8a6` | `#e8dccb` |

Green, blue, magenta and cyan are the "uyumlu" set: built in OKLCH around amber and crimson, at the same perceived lightness (L 0.72-0.80) with hues spread around the wheel (rose 10, sage 130, teal 210, lavender 285). Every pair of syntax colors is at least 13 OKLab dE apart. The zsh command-line colors (`config/zsh/makima.zsh`) use the same set, and Claude Code's `dark-ansi` theme picks them up from here.

Background `#140b07` (alpha 0.93), foreground `#e8dccb`, cursor a crimson block `#e22e0e`, selection `#3a231a`.

## Mouse cursor

`Makima-Crimson`: the Bibata Modern Amber (v2.0.7) cursors recolored to crimson (`#e22e0e`).
It is installed in `~/.local/share/icons/Makima-Crimson`. It is not stored in the repo; rebuild it with `./install.sh --cursor`, or by hand:

```
curl -LO https://github.com/ful1e5/Bibata_Cursor/releases/download/v2.0.7/Bibata-Modern-Amber.tar.xz
tar -xf Bibata-Modern-Amber.tar.xz
python3 ~/.config/makima-sway/design/recolor-cursor.py Bibata-Modern-Amber ~/.local/share/icons/Makima-Crimson Makima-Crimson e22e0e
```

## Notifications (dunst)

| Urgency | Background | Border |
|---|---|---|
| low (volume, brightness) | night | oxblood, amber progress bar |
| normal | night | crimson |
| critical (stays until dismissed) | oxblood | amber |
