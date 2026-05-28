--[[
Copyright 2026 Mark Mandel All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]

---------------------
--- KEYBINDINGS   ---
---------------------

-- See https://wiki.hyprland.org/Configuring/Keywords/

local programs = require("includes.programs")
local mainMod  = "SUPER"

-- Send a Hyprland-branded low-urgency desktop notification.
local function notify(message)
    os.execute(string.format(
        [[notify-send --urgency low --expire-time 2000 --icon ~/.local/share/icons/rose-pine-icons/16x16/actions/draw-cuboid.svg --app-name "Hyprland" %q]],
        message
    ))
end

-- General bindings
hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.exec_cmd(programs.terminal))
hl.bind(mainMod .. " + X",             hl.dsp.window.close())
hl.bind(mainMod .. " + M",             hl.dsp.exit())
hl.bind(mainMod .. " + T",             hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + Z",             hl.dsp.window.fullscreen({ mode = 1 }))
hl.bind("CTRL + ALT + L",              hl.dsp.exec_cmd("loginctl lock-session"))

-- Menus
hl.bind(mainMod .. " + P",        hl.dsp.exec_cmd("wofi --show drun,run"))
hl.bind(mainMod .. " + CTRL + J", hl.dsp.exec_cmd("rofimoji --skin-tone ask --action clipboard"))

-- Layout Manipulation
hl.bind(mainMod .. " + Space", function ()
    local layouts     = { "master", "lua:columns", "dwindle" }
    local workspace   = hl.get_active_workspace()
    local next_layout = "lua:columns"

    if not workspace then
        return
    end

    for i = 1, #layouts do
        if layouts[i] == workspace.tiled_layout then
            local next_layout_idx = (i % #layouts) + 1
            next_layout = layouts[next_layout_idx]
            break
        end
    end

    hl.workspace_rule({ workspace = workspace.name, layout = next_layout })
    notify("Layout: " .. next_layout)
end)

hl.bind(mainMod .. " + minus",        hl.dsp.layout("colresize -conf"))
hl.bind(mainMod .. " + equal",        hl.dsp.layout("colresize +conf"))
hl.bind(mainMod .. " + SHIFT + equal", hl.dsp.layout("fit all"))

-- Primary/Secondary layout toggle
hl.bind(mainMod .. " + SHIFT + Space", function()
    local workspace = hl.get_active_workspace()
    if not workspace then return end
    hl.workspace_rule({ workspace = workspace.name, layout = "master" })
    notify("Layout: master")
end)
hl.bind("CTRL + SHIFT + " .. mainMod .. " + Space", function()
    local workspace = hl.get_active_workspace()
    if not workspace then return end
    notify("Layout: " .. (workspace.tiled_layout or "unknown"))
end)

hl.bind(mainMod .. " + H", hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + L", hl.dsp.window.resize({ x = 50,  y = 0, relative = true }), { repeating = true })

-- Move focus
hl.bind(mainMod .. " + tab",         hl.dsp.window.cycle_next())
hl.bind(mainMod .. " + SHIFT + tab", hl.dsp.window.cycle_next({ next = false }))
hl.bind(mainMod .. " + J",           hl.dsp.window.cycle_next())
hl.bind(mainMod .. " + K",           hl.dsp.window.cycle_next({ next = false }))
hl.bind(mainMod .. " + left",        hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + right",       hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + up",          hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + down",        hl.dsp.focus({ direction = "d" }))

-- Move window around workspace
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.swap({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.swap({ direction = "r" }))
hl.bind(mainMod .. " + Return",    hl.dsp.layout("swapwithmaster"))

-- Switch workspaces with mainMod + [0-9] and numpad
-- Move active window to a workspace with mainMod + SHIFT + [0-9] and numpad
local numpad_keys = {
    "KP_End", "KP_Down", "KP_Next", "KP_Left", "KP_Begin",
    "KP_Right", "KP_Home", "KP_Up", "KP_Prior", "KP_Insert"
}
for i = 1, 10 do
    local key    = i % 10  -- 10 maps to key 0
    local numpad = numpad_keys[i]
    hl.bind(mainMod .. " + " .. key,               hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key,       hl.dsp.window.move({ workspace = i, follow = false }))
    hl.bind(mainMod .. " + " .. numpad,            hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. numpad,    hl.dsp.window.move({ workspace = i, follow = false }))
end

-- Previous workspace
hl.bind(mainMod .. " + grave", hl.dsp.focus({ workspace = "previous" }))

-- Move focus to other monitor
hl.bind(mainMod .. " + W", hl.dsp.focus({ monitor = -1 }))
hl.bind(mainMod .. " + E", hl.dsp.focus({ monitor = 1 }))

-- Move active windows between monitors
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.window.move({ monitor = -1 }))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.window.move({ monitor = 1 }))

-- Expo (overview)
hl.bind(mainMod .. " + G", hl.dsp.exec_cmd("quickshell -c ~/scripts/quickshell/overview"))

-- Special workspaces
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("special"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special", silent = true }))

-- Restore the scratchpad if it gets shut down.
hl.bind(mainMod .. " + F12", function()
    local windows = hl.get_windows()
    for _, w in ipairs(windows) do
        if w.class == "com.markmandel.scratchpad" then return end
    end
    hl.dispatch(hl.dsp.exec_cmd(programs.terminalScratch))
end)
hl.bind(mainMod .. " + F12", hl.dsp.workspace.toggle_special("terminal"))

-- KeePassXC scratchpad
hl.bind(mainMod .. " + CTRL + K", function()
    local windows = hl.get_windows()
    for _, w in ipairs(windows) do
        if w.class == "org.keepassxc.KeePassXC" then return end
    end
    hl.dispatch(hl.dsp.exec_cmd("flatpak run org.keepassxc.KeePassXC"))
end)
hl.bind(mainMod .. " + CTRL + K", hl.dsp.workspace.toggle_special("keepass"))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 && wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),                                               { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),                                              { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),                                            { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl s 10%+"),                                                                    { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"),                                                                    { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),        { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"),  { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"),  { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),    { locked = true })

-- Dunst Notifications
hl.bind(mainMod .. " + End",          hl.dsp.exec_cmd("dunstctl close"))
hl.bind(mainMod .. " + CTRL + End",   hl.dsp.exec_cmd("dunstctl close-all"))
hl.bind(mainMod .. " + Home",         hl.dsp.exec_cmd("dunstctl history-pop"))

-- Screenshots
hl.bind("Print",             hl.dsp.exec_cmd([[grim -g "$(slurp)" - | swappy -f -]]))
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd("grim /tmp/screenshot.png && gimp /tmp/screenshot.png"))

-- CopyQ
hl.bind("CTRL + SHIFT + A", hl.dsp.exec_cmd("copyq show"))

-- lan-mouse keyboard shortcuts
hl.bind("CTRL + ALT + Up",   hl.dsp.exec_cmd("wlrctl pointer move 0 -10000"))
hl.bind("CTRL + ALT + Down", hl.dsp.exec_cmd("wlrctl pointer move 0 10000"))
