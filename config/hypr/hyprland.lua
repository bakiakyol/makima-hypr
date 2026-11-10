-- ~/.config/hypr/hyprland.lua: makima-hypr
-- Source: ~/.config/makima-hypr/config/hypr/hyprland.lua (tracked in git).
-- ~/.config/hypr/hyprland.lua is a symlink to it.
--
-- Ported from makima-sway, with the same keybindings where Hyprland has an equivalent.
-- Colors: the Makima palette (~/.config/makima-hypr/design/palette.md).
--
-- Hyprland reloads this file by itself when it changes (and Super+Shift+c reloads it too).
-- To check for errors without starting Hyprland:
--   Hyprland --verify-config -c ~/.config/hypr/hyprland.lua
-- Lua API reference: /usr/share/hypr/stubs/hl.meta.lua and https://wiki.hypr.land

local mod  = "SUPER"
local home = os.getenv("HOME")
local M    = home .. "/.config/makima-hypr"
local bin  = M .. "/bin/"

-- ---------- colors (Makima palette) ----------
local c = {
    night   = "rgb(140b07)",
    surface = "rgb(22140e)",
    border  = "rgb(3a231a)",
    muted   = "rgb(9f7f70)",
    text    = "rgb(e8dccb)",
    crimson = "rgb(e22e0e)",
    oxblood = "rgb(7f1d06)",
    amber   = "rgb(f2a33a)",
}

-- ---------- monitors ----------
-- Samsung M70D 43" (HDMI) on top, laptop screen centered below it.
-- Positions use scaled sizes: TV 2560x1440 / 1.6 = 1600x900, laptop 1920x1080 / 1.5 = 1280x720,
-- so the laptop sits at x = (1600 - 1280) / 2 = 160, y = 900 (right under the TV).
-- The TV can't be 1.5: Hyprland needs a whole-pixel scaled size (2560 / 1.5 = 1706.67) and
-- rounds it to 1.6. Valid scales near it: 1.25, 1.333 (1920x1080), 1.6, 1.667.
hl.monitor({ output = "HDMI-A-1", mode = "2560x1440@59.95", position = "0x0",   scale = 1.6 })
hl.monitor({ output = "eDP-1",    mode = "preferred",       position = "160x900", scale = 1.5 })
-- Any other screen: its best mode, placed automatically
hl.monitor({ output = "",         mode = "preferred",       position = "auto",  scale = "auto" })

-- ---------- environment ----------
-- Dark GTK apps (Firefox's menus and pages included)
hl.env("GTK_THEME", "Adwaita:dark")
-- Mouse cursor: Makima-Crimson, 24 px (built by makima-sway's "install.sh --cursor")
hl.env("XCURSOR_THEME", "Makima-Crimson")
hl.env("XCURSOR_SIZE", "24")

-- ---------- startup ----------
hl.on("hyprland.start", function()
    -- GTK3 apps (like Firefox) read the cursor from here on Wayland
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme Makima-Crimson")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size 24")
    -- Tell systemd and D-Bus which display this is, so services they start (the screen
    -- sharing portal, dunst, ...) can find it. Sway does this in /etc/sway/config.d.
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE")
    -- Wallpaper, idle (lock at 10 min, screens off at 11) and the password prompt for apps
    -- that need root. Their configs: ~/.config/hypr/hyprpaper.conf, hypridle.conf, hyprlock.conf
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("/usr/lib/hyprpolkitagent/hyprpolkitagent")
    -- Bar and notifications, with this repo's own config files
    hl.exec_cmd("waybar -c " .. M .. "/config/waybar/config.jsonc -s " .. M .. "/config/waybar/style.css")
    -- Only one dunst can run per user (D-Bus), and Sway's may still be up on tty1: replace it
    -- so notifications show here. (While both run, Sway's notifications then show here too.)
    hl.exec_cmd("pkill -x dunst; sleep 0.3; dunst --config " .. M .. "/config/dunst/dunstrc")
end)

-- ---------- look ----------
hl.config({
    general = {
        -- 2 px border: crimson-to-amber on the focused window, dark on the rest
        border_size = 2,
        col = {
            active_border   = { colors = { c.crimson, c.amber }, angle = 45 },
            inactive_border = c.surface,
        },
        -- Hyprland's inner gap is per window, so 3 here = 6 px between two windows (as on Sway)
        gaps_in  = 3,
        gaps_out = 6,
        -- Drag a border or gap to resize
        resize_on_border = true,
        layout = "dwindle",
    },

    decoration = {
        rounding       = 8,
        rounding_power = 2,

        shadow = {
            enabled      = true,
            range        = 12,
            render_power = 3,
            color        = "rgba(000000bb)",
        },

        -- A faint crimson glow around the focused window
        glow = {
            enabled        = true,
            range          = 10,
            render_power   = 3,
            color          = "rgba(e22e0e44)",
            color_inactive = "rgba(7f1d0600)",
        },

        -- Blur behind see-through windows (Firefox at 93 %, the bar)
        blur = {
            enabled           = true,
            size              = 3,
            passes            = 1,
            vibrancy          = 0.17,
            new_optimizations = true,
        },

        -- Windows wobble like jelly while dragged. Costs the most of all the effects here
        -- (about 3-4x the CPU of having it off with the default mesh of 12). A mesh of 8 with
        -- more damping settles sooner and costs less. Set enabled = false to save battery.
        wobble = {
            enabled   = true,
            mesh      = 8,
            stiffness = 260,
            damping   = 20,
            mass      = 1,
            intensity = 0.2,
        },

        motion_blur = { enabled = false },

        -- Unfocused windows 25 % darker, and a dimmed backdrop behind the dropdown terminal.
        -- Each monitor keeps its own last focused window bright: dim-per-monitor.lua
        dim_inactive = true,
        dim_strength = 0.25,
        dim_special  = 0.35,
    },

    misc = {
        -- No anime mascot wallpaper or logo: hyprpaper draws ours
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        disable_splash_rendering = true,
        background_color        = c.night,
    },

    input = {
        -- Turkish Q layout. Change "tr" to your own layout (us, de, ...).
        kb_layout    = "tr",
        follow_mouse = 1,
        -- Touchpad: tap to click, normal scroll direction, ignore while typing
        touchpad = {
            tap_to_click         = true,
            natural_scroll       = false,
            disable_while_typing = true,
        },
    },

    dwindle = {
        -- Keep a split's direction when windows move around
        preserve_split = true,
    },

    group = {
        col = {
            border_active   = c.crimson,
            border_inactive = c.surface,
        },
    },
})

-- Touchpad: swipe three fingers left or right to change workspace
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- ---------- animations ----------
-- Designed with Claude Fable and measured with tools/anim-bench (11 Nov 2026): Hyprland's own
-- CPU went from 25 % to 21 % of one core compared with the stock set, with more effects.
-- speed is in tenths of a second (speed 4 = 0.4 s).
hl.curve("easeOutQuint", { type = "bezier", points = { {0.23, 1},  {0.32, 1}  } })
hl.curve("easeOutExpo",  { type = "bezier", points = { {0.16, 1},  {0.3, 1}   } })
hl.curve("easeInCubic",  { type = "bezier", points = { {0.4, 0},   {0.9, 0.6} } })
hl.curve("linear",       { type = "bezier", points = { {0, 0},     {1, 1}     } })
hl.curve("almostLinear", { type = "bezier", points = { {0.5, 0.5}, {0.75, 1}  } })
hl.curve("quick",        { type = "bezier", points = { {0.15, 0},  {0.1, 1}   } })
-- A spring that settles in about 0.28 s, with one small overshoot
hl.curve("snappy",       { type = "spring", mass = 1, stiffness = 300, damping = 29 })

-- global is the fallback for every leaf not listed below (it used to be 1 s)
hl.animation({ leaf = "global",              enabled = true,  speed = 5,    bezier = "default" })
hl.animation({ leaf = "border",              enabled = true,  speed = 3,    bezier = "easeOutQuint" })
-- A rotating border gradient would redraw the screen every frame, forever: keep it off
hl.animation({ leaf = "borderangle",         enabled = false })
hl.animation({ leaf = "windows",             enabled = true,  speed = 4,    spring = "snappy" })
hl.animation({ leaf = "windowsIn",           enabled = true,  speed = 3.8,  spring = "snappy",       style = "popin 88%" })
hl.animation({ leaf = "windowsOut",          enabled = true,  speed = 1.7,  bezier = "easeInCubic",  style = "popin 90%" })
hl.animation({ leaf = "windowsMove",         enabled = true,  speed = 3.6,  spring = "snappy" })
hl.animation({ leaf = "fade",                enabled = true,  speed = 2.4,  bezier = "quick" })
hl.animation({ leaf = "fadeIn",              enabled = true,  speed = 1.7,  bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",             enabled = true,  speed = 1.5,  bezier = "almostLinear" })
hl.animation({ leaf = "fadeDim",             enabled = true,  speed = 2.5,  bezier = "easeOutQuint" })
hl.animation({ leaf = "fadeGlow",            enabled = true,  speed = 3,    bezier = "easeOutQuint" })
hl.animation({ leaf = "layers",              enabled = true,  speed = 2.6,  bezier = "easeOutExpo",  style = "fade" })
hl.animation({ leaf = "layersIn",            enabled = true,  speed = 2.6,  bezier = "easeOutExpo",  style = "fade" })
hl.animation({ leaf = "layersOut",           enabled = true,  speed = 1.4,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",        enabled = true,  speed = 1.6,  bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut",       enabled = true,  speed = 1.3,  bezier = "almostLinear" })
-- Workspace switches slide 12 % while fading, so they have a direction. All three leaves are
-- set: workspacesIn/Out override workspaces, so setting only the parent does nothing.
hl.animation({ leaf = "workspaces",          enabled = true,  speed = 2.4,  bezier = "easeOutQuint", style = "slidefade 12%" })
hl.animation({ leaf = "workspacesIn",        enabled = true,  speed = 2.4,  bezier = "easeOutQuint", style = "slidefade 12%" })
hl.animation({ leaf = "workspacesOut",       enabled = true,  speed = 2.4,  bezier = "easeOutQuint", style = "slidefade 12%" })
-- The dropdown terminal's special workspace slides down from the top
hl.animation({ leaf = "specialWorkspaceIn",  enabled = true,  speed = 3,    bezier = "easeOutExpo",  style = "slidefadevert 20%" })
hl.animation({ leaf = "specialWorkspaceOut", enabled = true,  speed = 1.8,  bezier = "easeInCubic",  style = "slidefadevert 20%" })

-- Per-layer rules: no fade for the wallpaper (a full-screen layer); fuzzel pops in and
-- notifications slide in from the right. Both are 93 % opaque, so they get the windows' blur;
-- ignore_alpha keeps the blur out of their transparent rounded corners.
hl.layer_rule({ name = "wallpaper-noanim", match = { namespace = "^hyprpaper$" }, no_anim = true })
hl.layer_rule({ name = "launcher-pop",     match = { namespace = "^launcher$" },
                animation = "popin 92%", blur = true, ignore_alpha = 0.5 })
hl.layer_rule({ name = "notif-slide",      match = { namespace = "^notifications$" },
                animation = "slide right", blur = true, ignore_alpha = 0.5 })

-- ---------- window rules ----------
-- Ignore apps asking to be maximized: tiling decides the size
hl.window_rule({
    name  = "suppress-maximize",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Firefox at 93 %, like the terminal (focused and unfocused)
hl.window_rule({
    name    = "firefox-opacity",
    match   = { class = "^firefox$" },
    opacity = "0.93 override 0.93 override",
})

-- Dropdown terminal: floating, 66 % x 65 % of the screen, centered, kept in its own
-- special workspace so Super+u can show and hide it (see the bind below)
hl.window_rule({
    name      = "dropdown",
    match     = { class = "^dropdown$" },
    float     = true,
    size      = { "monitor_w*0.66", "monitor_h*0.65" },
    center    = true,
    workspace = "special:dropdown",
    animation = "slide top",
})

-- ---------- helpers ----------
-- Floating windows always fit on their monitor (standard size, shrink, center)
local float_fit = dofile(M .. "/config/hypr/float-fit.lua")
local function exec(cmd) return hl.dsp.exec_cmd(cmd) end

-- Super+u: show/hide the dropdown terminal, start it on the first press
local function dropdown()
    for _, w in ipairs(hl.get_windows()) do
        if w.class == "dropdown" then
            hl.dispatch(hl.dsp.workspace.toggle_special("dropdown"))
            return
        end
    end
    hl.exec_cmd("foot --app-id dropdown")
end

-- Super+space: jump between floating and tiled windows on this workspace (Sway's "focus mode_toggle")
local function focus_mode_toggle()
    local active = hl.get_active_window()
    if not active or not active.workspace then return end
    for _, w in ipairs(hl.get_windows()) do
        if w.mapped and w.workspace and w.workspace.id == active.workspace.id
            and w.floating ~= active.floating then
            hl.dispatch(hl.dsp.focus({ window = "address:" .. w.address }))
            return
        end
    end
end

-- ---------- volume and brightness keys (popups via dunst) ----------
-- locked: also work on the lock screen   repeating: hold the key to keep going
local media = { locked = true, repeating = true }
hl.bind("XF86AudioRaiseVolume",  exec(bin .. "volume up"),       media)
hl.bind("XF86AudioLowerVolume",  exec(bin .. "volume down"),     media)
hl.bind("XF86AudioMute",         exec(bin .. "volume mute"),     { locked = true })
hl.bind("XF86AudioMicMute",      exec(bin .. "volume mic"),      { locked = true })
hl.bind("XF86MonBrightnessUp",   exec(bin .. "brightness up"),   media)
hl.bind("XF86MonBrightnessDown", exec(bin .. "brightness down"), media)

-- ---------- apps ----------
hl.bind(mod .. " + Return",      exec("foot"),            { desc = "Terminal (foot)" })
hl.bind(mod .. " + D",           exec("fuzzel"),          { desc = "App launcher (fuzzel)" })
hl.bind(mod .. " + X",           exec(bin .. "lock"),     { desc = "Lock the screen" })
hl.bind(mod .. " + SHIFT + Q",   hl.dsp.window.close(),   { desc = "Close the window" })
hl.bind(mod .. " + U",           dropdown,                { desc = "Dropdown terminal" })
hl.bind(mod .. " + F1",          exec(bin .. "keybindings"), { desc = "This keybinding list" })

-- Screenshots (this laptop has no Print key): ~/Pictures/Screenshots/ + clipboard
hl.bind(mod .. " + P",           exec(bin .. "screenshot"),        { desc = "Screenshot: full screen" })
hl.bind(mod .. " + SHIFT + P",   exec(bin .. "screenshot select"), { desc = "Screenshot: select a region" })
hl.bind(mod .. " + CTRL + P",    exec(bin .. "screenshot window"), { desc = "Screenshot: focused window" })
hl.bind(mod .. " + ALT + P",     exec(bin .. "screenshot delay"),  { desc = "Screenshot: full screen after 3 s" })

-- Notifications (dunst)
hl.bind(mod .. " + N",           exec("dunstctl close-all"),   { desc = "Close notifications" })
hl.bind(mod .. " + SHIFT + N",   exec("dunstctl history-pop"), { desc = "Bring back the last notification" })
hl.bind(mod .. " + CTRL + N",    exec(bin .. "dnd"),           { desc = "Do Not Disturb on/off" })

-- ---------- focus and move (j k l ş + arrows) ----------
-- "ş" (scedilla) sits where ";" is on a US keyboard, so this is i3's default j k l ;
local dirs = {
    { "J", "left" }, { "K", "down" }, { "L", "up" }, { "scedilla", "right" },
    { "left", "left" }, { "down", "down" }, { "up", "up" }, { "right", "right" },
}
for _, d in ipairs(dirs) do
    hl.bind(mod .. " + " .. d[1],         hl.dsp.focus({ direction = d[2] }),       { desc = "Focus " .. d[2] })
    hl.bind(mod .. " + SHIFT + " .. d[1], hl.dsp.window.move({ direction = d[2] }), { desc = "Move window " .. d[2] })
end

-- ---------- layout ----------
hl.bind(mod .. " + F",           hl.dsp.window.fullscreen({ action = "toggle" }), { desc = "Fullscreen on/off" })
hl.bind(mod .. " + SHIFT + space", float_fit.float_toggle,                       { desc = "Floating on/off (standard size, centered)" })
hl.bind(mod .. " + space",       focus_mode_toggle,                               { desc = "Focus floating / tiled" })
hl.bind(mod .. " + E",           hl.dsp.layout("togglesplit"),                    { desc = "Split side by side / stacked" })
-- Tabs: Hyprland's groups play the part of Sway's tabbed layout
hl.bind(mod .. " + W",           hl.dsp.group.toggle(),                           { desc = "Tabs (group) on/off" })
hl.bind(mod .. " + Tab",         hl.dsp.group.next(),                             { desc = "Next tab" })

-- Super + left mouse: move a window   Super + right mouse: resize it
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ---------- workspaces ----------
for i = 1, 10 do
    local key = i % 10 -- 10 is on the 0 key
    hl.bind(mod .. " + " .. key,         hl.dsp.focus({ workspace = i }),       { desc = "Workspace " .. i })
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }), { desc = "Move window to workspace " .. i })
end

-- ---------- Hyprland itself ----------
-- Animation benchmark: 30 s of the same moves on workspace 9, then CPU/GPU averages
-- (tools/anim-bench; results in ~/.local/state/makima-hypr/bench.tsv). Hands off while it runs.
hl.bind(mod .. " + CTRL + T",    exec(M .. "/tools/anim-bench"), { desc = "Animation benchmark (30 s)" })
hl.bind(mod .. " + SHIFT + C",   hl.dsp.reload_config(),   { desc = "Reload the config" })
-- Power menu in fuzzel: lock, suspend, log out, reboot, shut down (the last three ask first)
hl.bind(mod .. " + SHIFT + E",   exec(bin .. "power-menu"), { desc = "Power menu" })

-- Resize mode: Super+r, then j k l ş or the arrows; Enter, Esc or Super+r to leave
hl.bind(mod .. " + R", hl.dsp.submap("resize"), { desc = "Resize mode" })
hl.define_submap("resize", function()
    local grow = {
        { "J", -10, 0 }, { "K", 0, 10 }, { "L", 0, -10 }, { "scedilla", 10, 0 },
        { "left", -10, 0 }, { "down", 0, 10 }, { "up", 0, -10 }, { "right", 10, 0 },
    }
    for _, g in ipairs(grow) do
        hl.bind(g[1], hl.dsp.window.resize({ x = g[2], y = g[3], relative = true }), { repeating = true })
    end
    hl.bind("Return",      hl.dsp.submap("reset"))
    hl.bind("escape",      hl.dsp.submap("reset"))
    hl.bind(mod .. " + R", hl.dsp.submap("reset"))
end)

-- ---------- TEMPORARY: compare animation variants (tools/anim-variants) ----------
-- Super+Ctrl+V cycles base (this file) -> the files in tools/anim-variants listed in "variants";
-- Super+Ctrl+T benchmarks the one shown.
-- Remove this block once a variant is chosen.
local variant_state = home .. "/.local/state/makima-hypr"
local variants = { "base" }
-- Per-monitor dimming (see the dim_inactive comment above)
dofile(M .. "/config/hypr/dim-per-monitor.lua")

local function read_variant()
    local f = io.open(variant_state .. "/anim-variant", "r")
    local v = f and f:read("*l") or "base"
    if f then f:close() end
    return v
end
local current_variant = read_variant()
local variant_file = M .. "/tools/anim-variants/" .. current_variant .. ".lua"
-- A variant that was deleted since it was picked: just stay on this file
if current_variant ~= "base" and io.open(variant_file, "r") then
    dofile(variant_file)
end
hl.bind(mod .. " + CTRL + V", function()
    local nxt = variants[1]
    for i, v in ipairs(variants) do
        if v == read_variant() then nxt = variants[i % #variants + 1] end
    end
    os.execute("mkdir -p " .. variant_state)
    for _, name in ipairs({ "anim-variant", "bench-label" }) do
        local f = io.open(variant_state .. "/" .. name, "w"); f:write(nxt .. "\n"); f:close()
    end
    hl.dispatch(hl.dsp.reload_config())
    hl.exec_cmd("notify-send -t 3000 -h string:x-dunst-stack-tag:variant 'Animation variant' '" .. nxt .. "'")
end, { desc = "Next animation variant (temporary)" })
