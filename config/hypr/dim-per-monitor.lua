-- dim-per-monitor.lua: treat each monitor as its own screen for dim_inactive.
-- Hyprland's dim_inactive darkens every window except the one with keyboard focus, so
-- focusing the external monitor also darkened the laptop's window. Here the last focused
-- window of each monitor's visible workspace (or its open special workspace, like the
-- dropdown terminal) gets the no_dim prop, so every monitor keeps one bright window.
-- Loaded from hyprland.lua with dofile().

local bright = {}   -- address -> true for windows we currently keep bright
local first = true

local function set_no_dim(win, on)
    hl.dispatch(hl.dsp.window.set_prop({
        window = "address:" .. win.address,
        prop = "no_dim",
        value = on and "1" or "0",
    }))
end

local function refresh()
    local want = {}
    for _, mon in ipairs(hl.get_monitors()) do
        local ws = mon.active_special_workspace or mon.active_workspace
        local win = ws and ws.last_window
        if win and win.mapped then want[win.address] = win end
    end
    -- After a config reload `bright` is empty but the props may still be set, so the
    -- first pass sets every window; later passes only touch windows that changed.
    local now = {}
    for _, win in ipairs(hl.get_windows()) do
        local on = want[win.address] ~= nil
        if first or on ~= (bright[win.address] == true) then set_no_dim(win, on) end
        now[win.address] = on or nil
    end
    bright, first = now, false
end

for _, ev in ipairs({
    "window.active", "window.open", "window.close", "window.move_to_workspace",
    "workspace.active", "workspace.special_active", "workspace.move_to_monitor",
    "monitor.focused", "monitor.added", "monitor.removed", "config.reloaded",
}) do
    hl.on(ev, function() refresh() end)
end
