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

-------------------
--- COPY WINDOW ---
-------------------

-- Emulates XMonad.Actions.CopyWindow. A window can only live on one workspace,
-- so we track the set of workspaces each window has been "copied" to, and move
-- it to whichever of those workspaces becomes active. Its place in each
-- workspace's layout is remembered and restored when it comes back.

local M = {}

-- window address -> { [workspace_id] = true }
local copies = {}

-- window address -> { [workspace_id] = { prev = address|nil, index = integer } }
local positions = {}

local function forget(address)
    copies[address] = nil
    positions[address] = nil
end

local function count(set)
    local n = 0
    for _ in pairs(set) do n = n + 1 end
    return n
end

-- Tiled windows on a workspace in layout order. There's no API for a layout's
-- internal order, so go by on-screen position: left to right, then top to bottom.
local function tiled_order(workspace_id)
    local windows = {}
    for _, w in ipairs(hl.get_workspace_windows(workspace_id)) do
        if not w.floating then
            table.insert(windows, w)
        end
    end
    table.sort(windows, function (a, b)
        if a.at.x ~= b.at.x then
            return a.at.x < b.at.x
        end
        return a.at.y < b.at.y
    end)
    return windows
end

local function index_of(windows, address)
    for i, w in ipairs(windows) do
        if w.address == address then
            return i
        end
    end
    return nil
end

-- Record where the window sits in its current workspace's layout.
local function remember(window)
    if window.floating or not window.workspace then
        return
    end
    local windows = tiled_order(window.workspace.id)
    local index = index_of(windows, window.address)
    if not index then
        return
    end
    local prev = windows[index - 1]
    positions[window.address] = positions[window.address] or {}
    positions[window.address][window.workspace.id] = { prev = prev and prev.address, index = index }
end

-- Put the window back where it was last seen on this workspace, by swapping it
-- with its neighbours one step at a time so everything else keeps its order.
local function restore(window, workspace_id)
    local saved = positions[window.address] and positions[window.address][workspace_id]
    if not saved or window.floating then
        return
    end
    local windows = tiled_order(workspace_id)
    local current = index_of(windows, window.address)
    if not current then
        return
    end

    -- Prefer sitting after the same neighbour, in case windows came or went.
    local target = math.min(saved.index, #windows)
    local prev = saved.prev and index_of(windows, saved.prev)
    if prev then
        target = prev < current and prev + 1 or prev
    end

    local step = target < current and -1 or 1
    while current ~= target do
        local other = windows[current + step]
        hl.dispatch(hl.dsp.window.swap({ window = window, with = other }))
        windows[current], windows[current + step] = other, windows[current]
        current = current + step
    end
end

-- Silently move a tracked window, then restore its place in the layout.
-- Resolve it first: if the selector doesn't match a window, Hyprland falls back
-- to moving the *active* window instead.
local function move_silent(address, workspace_id)
    local window = hl.get_window("address:" .. address)
    if not window then
        forget(address)
        return
    end
    hl.dispatch(hl.dsp.window.move({ workspace = workspace_id, window = window, follow = false }))
    restore(window, workspace_id)
end

-- Copy the active window to the given workspace, leaving it where it is.
function M.copy_to(workspace_id)
    local window = hl.get_active_window()
    if not window or not window.workspace or window.workspace.special then
        return
    end
    local set = copies[window.address] or {}
    set[window.workspace.id] = true
    set[workspace_id] = true
    copies[window.address] = set
end

-- Remove the active window from the current workspace if it has been copied
-- elsewhere, otherwise close it.
function M.kill_copy()
    local window = hl.get_active_window()
    if not window then
        return
    end
    local set = copies[window.address]
    if not set or count(set) < 2 or not window.workspace then
        forget(window.address)
        hl.dispatch(hl.dsp.window.close())
        return
    end

    set[window.workspace.id] = nil
    if positions[window.address] then
        positions[window.address][window.workspace.id] = nil
    end
    local next_id = next(set)
    move_silent(window.address, next_id)
    if count(set) < 2 then
        forget(window.address)
    end
end

-- Bring copied windows along to the workspace that just became active.
hl.on("workspace.active", function (workspace)
    workspace = workspace or hl.get_active_workspace()
    if not workspace or workspace.special then
        return
    end
    for address, set in pairs(copies) do
        if set[workspace.id] then
            local window = hl.get_window("address:" .. address)
            if window and window.workspace and window.workspace.id ~= workspace.id then
                remember(window)
                move_silent(address, workspace.id)
            end
        end
    end
end)

-- Moving a copied window somewhere outside its set (e.g. mod+shift+N) makes it
-- a regular window again.
hl.on("window.move_to_workspace", function (window, workspace)
    local set = window and copies[window.address]
    if set and workspace and not set[workspace.id] then
        forget(window.address)
    end
end)

hl.on("window.close", function (window)
    if window then
        forget(window.address)
    end
end)

return M
