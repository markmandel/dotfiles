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

-----------------
--- AUTOSTART ---
-----------------

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:

local programs = require("includes.programs")

hl.on("hyprland.start", function()
    -- Idling and clicking
    hl.exec_cmd("killall hypridle; hypridle")

    -- polkit
    hl.exec_cmd("systemctl --user start hyprpolkitagent")

    -- wallpaper
    hl.exec_cmd("killall hyprpaper; hyprpaper")

    -- Ghostty terminal scratchpad
    hl.exec_cmd("[workspace special:terminal silent] " .. programs.terminalScratch)

    -- Google Drive mounting. Only mount if we have credentials.
    hl.exec_cmd("sleep 5s && grep apps.googleusercontent.com ~/.gdfuse/default/config && google-drive-ocamlfuse ~/GoogleDrive")

    -- CopyQ!
    hl.exec_cmd("sleep 3s && copyq")

    -- Network management
    hl.exec_cmd("sleep 2s && nm-applet --indicator")
    -- bluetooth
    hl.exec_cmd("sleep 2s && blueman-applet")

    -- Razer devices
    hl.exec_cmd("sleep 3s && polychromatic-tray-applet")

    -- lan-mouse
    hl.exec_cmd("killall lan-mouse; sleep 4s && lan-mouse daemon > /tmp/lan.log 2>&1")

    -- streamdeck-agent
    hl.exec_cmd("sleep 5s && streamdeck-agent > /tmp/streamdeck-agent.log 2>&1")

    -- quickshell
    hl.exec_cmd("killall quickshell; quickshell -c ~/scripts/quickshell/shell > /tmp/quickshell.log 2>&1")
end)
