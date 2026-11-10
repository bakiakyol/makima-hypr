<div align="center">

# makima-hypr

**A hand-written Hyprland desktop themed after Makima from *Chainsaw Man*.**

Crimson hair, amber eyes, a dark shrine at night. Every color on screen is sampled from one wallpaper.

![Hyprland](https://img.shields.io/badge/hyprland-0.57-e22e0e?style=flat-square&labelColor=140b07)
![Wayland](https://img.shields.io/badge/wayland-native-f2a33a?style=flat-square&labelColor=140b07)
![Arch Linux](https://img.shields.io/badge/arch-linux-4f8f88?style=flat-square&labelColor=140b07)

</div>

---

## Contents

- [About](#about)
- [Components](#components)
- [Color palette](#color-palette)
- [Requirements](#requirements)
- [Installation](#installation)
- [Starting Hyprland](#starting-hyprland)
- [Keybindings](#keybindings)
- [Scripts](#scripts)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)
- [Repository layout](#repository-layout)
- [Credits](#credits)
- [License](#license)

---

## About

This is my personal Hyprland setup, ported from my earlier Sway setup, [makima-sway](https://github.com/bakiakyol/makima-sway). The keybindings, colors, bar, menus and scripts carry over. What Hyprland adds is motion: windows pop in and fade out, workspaces cross-fade, and dragged windows wobble.

It runs on a mid-range laptop:

| | |
|---|---|
| Machine | Lenovo laptop |
| CPU | Intel Core i5-8250U (4 cores, 8 threads) |
| GPU | Intel UHD Graphics 620 (the NVIDIA MX110 is left unused) |
| RAM | 8 GB |
| Screens | the laptop's 1920×1080 at 1.5×, plus a 2560×1440 TV above it |

I measured before I chose. Hyprland with the stock animations, blur and shadow used about 4 % of the CPU on average and about 9 % of one core for itself. Window wobble costs the most: roughly 3 to 4 times the CPU of having it off. It's on, and the config says how to turn it off.

The config is **Lua** (`hyprland.lua`). Hyprland 0.57 dropped the old `hyprland.conf` format, so most configs and snippets you find online won't load as they are. The reference is `/usr/share/hypr/stubs/hl.meta.lua` and the [Hyprland wiki](https://wiki.hypr.land). hyprlock, hypridle and hyprpaper still read the old `.conf` format.

---

## Components

| Role | Program | Config in this repo |
|---|---|---|
| Compositor | [Hyprland](https://hypr.land) 0.57 | `config/hypr/hyprland.lua` |
| Bar | [Waybar](https://github.com/Alexays/Waybar) | `config/waybar/config.jsonc`, `style.css` |
| Terminal | [foot](https://codeberg.org/dnkl/foot) | `config/foot/foot.ini` |
| Launcher | [fuzzel](https://codeberg.org/dnkl/fuzzel) | `config/fuzzel/fuzzel.ini` |
| Notifications | [dunst](https://dunst-project.org) | `config/dunst/dunstrc` |
| Lock screen | [hyprlock](https://github.com/hyprwm/hyprlock) | `config/hypr/hyprlock.conf`, `bin/lock` |
| Idle | [hypridle](https://github.com/hyprwm/hypridle) | `config/hypr/hypridle.conf` |
| Wallpaper | [hyprpaper](https://github.com/hyprwm/hyprpaper) | `config/hypr/hyprpaper.conf` |
| Password prompts | hyprpolkitagent | started by `hyprland.lua` |
| Screen sharing | xdg-desktop-portal-hyprland | started on demand |
| Screenshots | grim + slurp + wl-clipboard | `bin/screenshot` |
| Wi-Fi | iwd (D-Bus) | `bin/wifi-menu` |
| Bluetooth | BlueZ (D-Bus + bluetoothctl) | `bin/bluetooth-menu` |
| Cursor | Bibata Modern Amber → recolored | `design/recolor-cursor.py` |
| Font | JetBrainsMono Nerd Font | – |

---

## Color palette

![Palette](assets/palette.png)

| | Name | Hex | Used for |
|---|---|---|---|
| ![](assets/palette/140b07.png) | Night | `#140b07` | backgrounds: bar, terminal, menus, notifications |
| ![](assets/palette/22140e.png) | Surface | `#22140e` | inactive borders and elements |
| ![](assets/palette/3a231a.png) | Border | `#3a231a` | separators, selection background |
| ![](assets/palette/9f7f70.png) | Muted | `#9f7f70` | secondary text, the lock screen date |
| ![](assets/palette/e8dccb.png) | Text | `#e8dccb` | main text |
| ![](assets/palette/e22e0e.png) | **Crimson** | `#e22e0e` | **main accent**: focused window, active workspace, wrong password |
| ![](assets/palette/7f1d06.png) | Oxblood | `#7f1d06` | bar underline, the lock screen's password box |
| ![](assets/palette/f2a33a.png) | Amber | `#f2a33a` | second accent: the lock screen clock, progress bars |
| ![](assets/palette/c56b46.png) | Copper | `#c56b46` | resize mode, Caps Lock, low battery |
| ![](assets/palette/4f8f88.png) | Teal | `#4f8f88` | cool contrast: Wi-Fi |

The full story of the palette (and the terminal's 16 colors) is in [design/palette.md](design/palette.md).

---

## Requirements

Tested on **Arch Linux** with Hyprland 0.57.1, hyprlock 0.9.7, hypridle 0.1.8, hyprpaper 0.8.5 and Waybar 0.15.

```bash
sudo pacman -S --needed \
	hyprland hyprlock hypridle hyprpaper xdg-desktop-portal-hyprland hyprpolkitagent \
	waybar foot fuzzel dunst libnotify \
	grim slurp wl-clipboard xorg-xwayland \
	brightnessctl pipewire wireplumber iwd bluez bluez-utils \
	python ttf-jetbrains-mono-nerd
```

`bluez` needs `sudo systemctl enable --now bluetooth`. The Wi-Fi module and menu expect **iwd**, not NetworkManager. `curl` and `xz` are needed only by `install.sh --cursor`.

### Things that are specific to my machine

| Setting | File | My value | Find yours with |
|---|---|---|---|
| Keyboard layout | `hyprland.lua` → `kb_layout` | `tr` (Turkish Q) | – |
| Monitors | `hyprland.lua` → `hl.monitor` | `HDMI-A-1` on top, `eDP-1` below, both at 1.5× | `hyprctl monitors` |
| Intel GPU | `bin/start-makima` → `intel_card` | PCI `0000:00:02.0` | `ls /dev/dri/by-path` |
| Wi-Fi interface | `waybar/config.jsonc` → `network.interface` | `wlan0` | `ip -br link` |
| Backlight | `waybar/config.jsonc` → `backlight.device` | `intel_backlight` | `ls /sys/class/backlight` |
| Battery / adapter | `waybar/config.jsonc` → `battery` | `BAT0` / `ADP0` | `ls /sys/class/power_supply` |

Any screen not named in `hyprland.lua` still works: a catch-all rule gives it its preferred mode and places it automatically.

---

## Installation

```bash
git clone https://github.com/bakiakyol/makima-hypr ~/projects/makima-hypr
cd ~/projects/makima-hypr
./install.sh -n          # dry run: shows what would change
./install.sh             # the real thing
./install.sh --cursor    # also build the crimson cursor (downloads Bibata, checks its hash)
```

`install.sh` only makes symlinks:

- `~/.config/makima-hypr` → this repo. Every other link goes through this path, so if you move the repo, run `./install.sh` again and only this one link changes.
- `~/.config/hypr/{hyprland.lua, hyprlock.conf, hypridle.conf, hyprpaper.conf}`, `~/.config/foot/foot.ini`, `~/.config/fuzzel/fuzzel.ini`.
- Firefox's `chrome/userChrome.css` (tab strip colors), plus the one pref that makes Firefox read it.
- `~/.local/bin/*` → `bin/`, and the battery warning timer.

A link left by makima-sway is replaced. Any other file already in the way is kept as `<name>.bak-makima-<date>`, never deleted. Waybar and dunst get no links: `hyprland.lua` starts them with this repo's files.

---

## Starting Hyprland

No display manager. Log in on a TTY and run:

```bash
start-makima
```

It picks the Intel GPU by its PCI address and runs `start-hyprland`, Hyprland's own launcher with a watchdog. To start it automatically when you log in on tty1, add this to `~/.zprofile` (or `~/.bash_profile`):

```sh
if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 1 ] && command -v start-hyprland >/dev/null; then
	exec start-makima
fi
```

---

## Keybindings

`Super+F1` shows all of them in a searchable list, read live from Hyprland (`hyprctl binds`).

### Apps

| Keys | Action |
|---|---|
| `Super+Enter` | Terminal (foot) |
| `Super+D` | App launcher (fuzzel) |
| `Super+U` | Dropdown terminal, show / hide |
| `Super+X` | Lock the screen |
| `Super+Shift+Q` | Close the window |
| `Super+P` | Screenshot: full screen |
| `Super+Shift+P` | Screenshot: select a region |
| `Super+Ctrl+P` | Screenshot: focused window |
| `Super+Alt+P` | Screenshot: full screen after 3 s |

### Windows and layout

| Keys | Action |
|---|---|
| `Super+J K L Ş` or arrows | Focus left, down, up, right |
| `Super+Shift+J K L Ş` or arrows | Move the window |
| `Super+F` | Fullscreen on / off |
| `Super+Shift+Space` | Floating on / off |
| `Super+Space` | Jump between floating and tiled windows |
| `Super+E` | Split side by side / stacked |
| `Super+W` | Tabs (a window group) on / off |
| `Super+Tab` | Next tab |
| `Super+R` | Resize mode: `J K L Ş` or arrows, then `Enter` or `Esc` |
| `Super` + left / right mouse | Move / resize a window |

### Workspaces, notifications, session

| Keys | Action |
|---|---|
| `Super+1` … `Super+0` | Workspace 1 … 10 |
| `Super+Shift+1` … `0` | Move the window to that workspace |
| `Super+N` | Close notifications |
| `Super+Shift+N` | Bring back the last notification |
| `Super+Ctrl+N` | Do Not Disturb on / off |
| `Super+Shift+C` | Reload the config (it also reloads by itself when the file changes) |
| `Super+Shift+E` | Power menu: lock, suspend, log out, reboot, shut down |

Volume, mute, mic mute and brightness keys work too, also on the lock screen.

---

## Scripts

All in `bin/`, linked into `~/.local/bin`:

| Script | What it does |
|---|---|
| `start-makima` | Starts Hyprland from a TTY on the Intel GPU |
| `volume up\|down\|mute\|mic` | Volume through `wpctl`, with a popup that updates in place |
| `brightness up\|down` | Brightness through `brightnessctl`, with a popup |
| `lock` | hyprlock (never two at once) |
| `screenshot [select\|window\|delay]` | grim/slurp to `~/Pictures/Screenshots/` (or your XDG pictures folder) and the clipboard |
| `power-menu` | Lock / suspend / log out / reboot / shut down in fuzzel; the last three ask first |
| `keybindings` | The searchable keybinding list (`Super+F1`) |
| `dnd` | Do Not Disturb toggle (`dnd status` feeds the bar's bell) |
| `battery-warning` | Low battery popup at 15 % and 7 %, run every 2 minutes by a systemd user timer |
| `wifi-menu` | Wi-Fi networks from iwd in fuzzel: connect, disconnect, forget, enter a password |
| `bluetooth-menu` | Known Bluetooth devices in fuzzel (paired, trusted or connected): connect, disconnect, forget, or scan and pair a new one. A device whose pairing got lost is paired again on Connect |

The dropdown terminal and the floating/tiled focus jump are small Lua functions inside `hyprland.lua`, not scripts.

---

## Customization

**Animations.** The `animations` section of `hyprland.lua` uses Hyprland's stock set: windows pop in from 87 %, workspaces fade. Styles you can try for `windowsIn`/`windowsOut` and `workspaces`: `popin`, `slide`, `slidevert`, `fade`, `slidefade`, `slidefadevert`, `gnomed`. `speed` is in tenths of a second.

**Save battery.** In `hyprland.lua`, set `wobble.enabled` to `false` first (it costs the most), then `blur` and `shadow`. Setting `animations = { enabled = false }` turns all motion off.

**Accent color.** The colors sit at the top of `hyprland.lua` (`local c = {...}`), `hyprlock.conf` (`$crimson`...), `waybar/style.css`, `dunstrc`, `foot.ini` and `fuzzel.ini`.

**Check the config without restarting:**

```bash
Hyprland --verify-config -c ~/.config/hypr/hyprland.lua
```

---

## Troubleshooting

**Hyprland won't start or freezes:** switch to another TTY (`Ctrl+Alt+F2`, `F3`...), log in, and remove or comment out the `exec start-makima` line in `~/.zprofile`. Hyprland's log is in `$XDG_RUNTIME_DIR/hypr/<instance>/hyprland.log`.

| Symptom | Try |
|---|---|
| Red error bar at the top | `hyprctl configerrors` shows the bad line |
| A snippet from the internet doesn't work | It's probably `hyprland.conf` syntax. Since 0.57 only Lua loads; translate it with the wiki and `hl.meta.lua` |
| No notifications, or they appear on another TTY's screen | Only one dunst can run per user. `hyprland.lua` replaces any running one when Hyprland starts; restart Hyprland or run `pkill dunst; dunst --config ~/.config/makima-hypr/config/dunst/dunstrc &` |
| A Bluetooth device is missing from the menu | It must be paired, trusted or connected. Otherwise use **Scan for new devices** |
| Screen sharing shows nothing | Check that `xdg-desktop-portal-hyprland` is installed, then log out and back in |
| Animations stutter | On Intel with TLP, raise `INTEL_GPU_MIN_FREQ_ON_AC`/`_ON_BAT` in `/etc/tlp.conf` a little (for example 300 → 500), as the [Hyprland wiki](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Performance/) suggests |

---

## Repository layout

```
makima-hypr/
├── install.sh                 # symlinks everything into place
├── config/
│   ├── hypr/
│   │   ├── hyprland.lua       # compositor: keys, monitors, colors, animations, rules
│   │   ├── hyprlock.conf      # lock screen
│   │   ├── hypridle.conf      # lock at 10 min, screens off at 11, lock before suspend
│   │   └── hyprpaper.conf     # wallpaper
│   ├── waybar/                # thin top bar (started by hyprland.lua)
│   ├── foot/ fuzzel/ dunst/   # terminal, launcher, notifications
│   ├── firefox/userChrome.css # tab strip in the palette
│   └── systemd/               # battery warning timer
├── bin/                       # scripts (linked into ~/.local/bin)
├── wallpapers/                # the wallpaper and its pre-blurred lock screen copy
├── design/                    # palette notes, cursor recolor script
└── assets/                    # README images
```

---

## Credits

The wallpaper is **「マキマ」 (Makima) by [Hikaku](https://www.pixiv.net/en/users/88393280)**, published on pixiv on 5 December 2023: <https://www.pixiv.net/en/artworks/113984261>. It's used here with credit to the artist, scaled down for the screen, with a blurred copy for the lock screen. All rights to the artwork belong to Hikaku. The whole color palette of this setup comes from this piece, so please go support the artist.

*If you are the artist and would like the image removed or credited differently, please open an issue and I will act on it right away.*

**Makima** is a character from ***Chainsaw Man*** by **Tatsuki Fujimoto** (© Tatsuki Fujimoto / Shueisha, MAPPA). This is a non-commercial fan setup with no affiliation.

Built with [Hyprland](https://hypr.land) and its tools (hyprlock, hypridle, hyprpaper), [Waybar](https://github.com/Alexays/Waybar), [foot](https://codeberg.org/dnkl/foot) and [fuzzel](https://codeberg.org/dnkl/fuzzel) by dnkl, [dunst](https://dunst-project.org), [iwd](https://iwd.wiki.kernel.org), [Bibata Cursor](https://github.com/ful1e5/Bibata_Cursor) by ful1e5 (GPL-3.0; only the recolor script is in this repo), and [JetBrains Mono](https://www.jetbrains.com/lp/mono/) with [Nerd Fonts](https://www.nerdfonts.com) icons.

---

## License

The configuration files and scripts are released under the [MIT License](LICENSE). The **wallpaper artwork is not covered** by this license; it belongs to its artist (see [Credits](#credits)). The Makima character belongs to her rights holders.
