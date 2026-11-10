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
-- Positions use scaled sizes: 2560/1.5 = 1706 wide, 1920/1.5 = 1280 wide.
hl.monitor({ output = "HDMI-A-1", mode = "2560x1440@59.95", position = "0x0",   scale = 1.5 })
hl.monitor({ output = "eDP-1",    mode = "preferred",       position = "213x960", scale = 1.5 })
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
        -- 2 px border: crimson on the focused window, dark on the rest
        border_size = 2,
        col = {
            active_border   = c.crimson,
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
            range        = 8,
            render_power = 3,
            color        = "rgba(000000aa)",
        },

        -- Blur behind see-through windows (Firefox at 93 %, the bar)
        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.17,
        },

        -- Windows wobble like jelly while dragged. Costs the most of all the effects here:
        -- measured about 3-4x the CPU of having it off (11 Nov 2026). Set false to save battery.
        wobble = {
            enabled = true,
        },
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

-- ---------- animations ----------
-- speed is in tenths of a second (speed 4 = 0.4 s)
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}    } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1} } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}  } })
hl.curve("easy",           { type = "spring", mass = 1, stiffness = 238.1191, damping = 24.21279333 })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  spring = "easy",         style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })

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
})

-- ---------- helpers ----------
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
hl.bind(mod .. " + SHIFT + space", hl.dsp.window.float({ action = "toggle" }),    { desc = "Floating on/off" })
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
