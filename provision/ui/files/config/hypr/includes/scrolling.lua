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

-------------------------
--- SCROLLING LAYOUT  ---
-------------------------

-- `colresize all +conf` / `-conf` isn't supported by the scrolling layout
-- (`all` only takes a number), so step through `explicit_column_widths` here
-- and resize every column to the chosen width.

local M = {}

local fallback_widths = { 0.333, 0.5, 0.75, 0.9, 1.0 }

-- The configured preset widths, sorted ascending.
local function widths()
    local ok, value = pcall(hl.get_config, "scrolling.explicit_column_widths")
    local list = {}
    if ok and type(value) == "string" then
        for n in value:gmatch("[%d%.]+") do
            local w = tonumber(n)
            if w then
                table.insert(list, w)
            end
        end
    end
    if #list == 0 then
        for i, w in ipairs(fallback_widths) do
            list[i] = w
        end
    end
    table.sort(list)
    return list
end

-- The active window's width as a fraction of its monitor's logical width.
-- Gaps/borders make this slightly smaller than the true column width, which
-- is fine since we snap to the nearest preset.
local function current_ratio()
    local window = hl.get_active_window()
    local monitor = window and window.monitor
    if window and monitor and window.size and window.size.x then
        local mon_w = (monitor.transform % 2 == 1) and monitor.height or monitor.width
        mon_w = mon_w / (monitor.scale or 1)
        if mon_w > 0 then
            return window.size.x / mon_w
        end
    end
    local ok, value = pcall(hl.get_config, "scrolling.column_width")
    if ok and type(value) == "number" then
        return value
    end
    return 0.5
end

-- Resize all columns to the next (step = 1) or previous (step = -1) preset width,
-- starting from the preset nearest the active window. Clamps at either end.
function M.colresize_all(step)
    local list = widths()
    local ratio = current_ratio()

    local nearest = 1
    for i, w in ipairs(list) do
        if math.abs(w - ratio) < math.abs(list[nearest] - ratio) then
            nearest = i
        end
    end

    local idx = math.max(1, math.min(#list, nearest + step))
    hl.dispatch(hl.dsp.layout(string.format("colresize all %.3f", list[idx])))
end

return M
