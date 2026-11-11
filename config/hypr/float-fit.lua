-- float-fit.lua: floating windows always fit on their monitor.
-- The two screens have different sizes (laptop 1280x720, TV 1600x900 in logical pixels),
-- so a floating window sized on one could hang off the other, and apps that ask for a big
-- size opened partly off screen (Hyprland shrinks them but centers on the old size).
--   * Floating on/off (Super+Shift+Space): the window gets the standard floating size,
--     STD of the monitor's free area, centered.
--   * A new floating window, or one moved to another monitor, or the dropdown terminal
--     shown on another monitor: if it is bigger than MAX of the free area it shrinks to
--     that, and if any part is off the monitor it is centered. Small dialogs keep their size.
-- Loaded from hyprland.lua with dofile().

local STD = { w = 0.66, h = 0.65 } -- standard floating size (same as the dropdown terminal)
local MAX = { w = 0.90, h = 0.90 } -- largest a floating window may be

-- Free area of a monitor in logical pixels (minus the bar)
local function area(mon)
    local r = mon.reserved or {}
    local top, bottom = r.top or 0, r.bottom or 0
    local left, right = r.left or 0, r.right or 0
    return {
        x = mon.x + left,
        y = mon.y + top,
        w = math.floor(mon.width / mon.scale) - left - right,
        h = math.floor(mon.height / mon.scale) - top - bottom,
    }
end

local function xy(v) return v.x or v[1], v.y or v[2] end

local function resize(win, w, h)
    hl.dispatch(hl.dsp.window.resize({ window = "address:" .. win.address, x = w, y = h }))
end

-- Center a w x h window in area a. Computed here instead of the center dispatcher, which
-- can still use the size from before a resize in the same moment.
local function center(win, a, w, h)
    hl.dispatch(hl.dsp.window.move({
        window = "address:" .. win.address,
        x = a.x + math.floor((a.w - w) / 2),
        y = a.y + math.floor((a.h - h) / 2),
    }))
end

-- Shrink if too big, center if off screen
local function fit(win)
    if not (win and win.floating and win.mapped and win.monitor) then return end
    local a = area(win.monitor)
    local x, y = xy(win.at)
    local w, h = xy(win.size)
    local maxw, maxh = math.floor(a.w * MAX.w), math.floor(a.h * MAX.h)
    if w > maxw or h > maxh then
        w, h = math.min(w, maxw), math.min(h, maxh)
        resize(win, w, h)
    end
    if x < a.x or y < a.y or x + w > a.x + a.w or y + h > a.y + a.h then
        center(win, a, w, h)
    end
end

-- The standard size, centered
local function standard(win)
    if not (win and win.floating and win.monitor) then return end
    local a = area(win.monitor)
    local w, h = math.floor(a.w * STD.w), math.floor(a.h * STD.h)
    resize(win, w, h)
    center(win, a, w, h)
end

-- Floating on/off, for the Super+Shift+Space bind in hyprland.lua
local function float_toggle()
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    standard(hl.get_active_window())
end

-- Events can fire before the window has its new monitor and position, so check a moment later
local function fit_later(win)
    if not win then return end
    local addr = "address:" .. win.address
    hl.timer(function() fit(hl.get_window(addr)) end, { timeout = 60, type = "oneshot" })
end

hl.on("window.open", fit_later)
hl.on("window.move_to_workspace", fit_later)
-- The dropdown terminal keeps the size it got on the monitor where it was first opened:
-- give it that monitor's standard size each time it is shown somewhere.
-- Deferred like fit_later: this event also fires from inside the map of the first dropdown
-- window, and resizing a window that is still being mapped crashes Hyprland 0.57.1.
local function special_shown()
    local mon = hl.get_active_monitor()
    local ws = mon and mon.active_special_workspace
    if not ws then return end
    for _, win in ipairs(hl.get_windows()) do
        if win.mapped and win.floating and win.workspace and win.workspace.name == ws.name then
            if win.class == "dropdown" then standard(win) else fit(win) end
        end
    end
end

hl.on("workspace.special_active", function()
    hl.timer(special_shown, { timeout = 60, type = "oneshot" })
end)

return { float_toggle = float_toggle }
