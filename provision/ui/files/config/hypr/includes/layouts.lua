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
---  LAYOUTS  ---
-----------------

hl.config({
    general = {
        layout = "master"
    },
    master = {
        new_status = "inherit"
    },
    scrolling = {
        explicit_column_widths = "0.333, 0.5, 0.75, 0.9, 1.0"
    }
})

-----------------------
---  COLUMN LAYOUT  ---
-----------------------

---@param ctx HL.LayoutContext
local function swap_with_master(ctx)
    local len = #ctx.targets
    if len < 2 then
        return true
    end
    hl.dispatch(hl.dsp.window.swap({ with = ctx.targets[1].window }))
    return true
end

-- Top-level map: workspace_id (integer) -> { offsets: table<string, number> }
local workspaces = {}

-- Returns the offsets table for the given workspace id, creating it if needed.
local function get_offsets(workspace_id)
    if workspaces[workspace_id] == nil then
        workspaces[workspace_id] = { offsets = {} }
    end
    return workspaces[workspace_id].offsets
end

-- Returns the active workspace id, or nil if unavailable.
local function active_workspace_id()
    local workspace = hl.get_active_special_workspace() or hl.get_active_workspace()
    if not workspace then
        return nil
    end
    return workspace.id
end

-- Resets all column offsets for the workspace, restoring equal-width columns.
local function reset_offsets()
    local ws_id = active_workspace_id()
    if ws_id ~= nil then
        workspaces[ws_id] = nil
    end
    return true
end

---@param ctx HL.LayoutContext
---@param amount number
-- Resize the active window by the given amount, and adjust the offsets for window on the right.
-- The far right window will need to adjust the window on the left.
local function resize(ctx, amount)
    local n = #ctx.targets
    if n < 2 then
        return true
    end

    -- Find the active window's index in targets
    local active_idx = nil
    for i, target in ipairs(ctx.targets) do
        if target.window ~= nil and target.window.active then
            active_idx = i
            break
        end
    end

    if active_idx == nil then
        return true
    end

    -- The far-right window steals from the left neighbour instead
    local left_idx, right_idx
    if active_idx == n then
        left_idx  = n - 1
        right_idx = n
        amount    = -amount
    else
        left_idx  = active_idx
        right_idx = active_idx + 1
    end

    -- Apply offset: grow left_idx by amount, shrink right_idx by amount
    local left_key  = ctx.targets[left_idx].window and ctx.targets[left_idx].window.address or tostring(left_idx)
    local right_key = ctx.targets[right_idx].window and ctx.targets[right_idx].window.address or tostring(right_idx)

    local ws_id  = active_workspace_id()
    local offsets = get_offsets(ws_id)

    -- Check that the resize won't push either window to 0 or below; if so, abort
    local base_w = ctx.area.w / n
    local new_left_w  = base_w + (offsets[left_key]  or 0) + amount
    local new_right_w = base_w + (offsets[right_key] or 0) - amount
    if new_left_w <= 0 or new_right_w <= 0 then
        return true
    end

    offsets[left_key]  = (offsets[left_key]  or 0) + amount
    offsets[right_key] = (offsets[right_key] or 0) - amount

    return true
end

hl.layout.register("columns", {
    recalculate = function (ctx)
        local n = #ctx.targets
        if n == 0 then
            return
        end

        -- Compute base equal-width columns then apply stored offsets
        local base_w = ctx.area.w / n
        local x = ctx.area.x
        local offsets = get_offsets(active_workspace_id())
        for i, target in ipairs(ctx.targets) do
            local key = target.window and target.window.address or tostring(i)
            local offset = offsets[key] or 0
            local w = base_w + offset
            local box = { x = x, y = ctx.area.y, w = w, h = ctx.area.h }
            target:place(box)
            x = x + w
        end
    end,
    layout_msg = function (ctx, message)
        if message == "swapwithmaster" then
            return swap_with_master(ctx)
        end

        if message == "resize-" then
            return resize(ctx, -50)
        end

        if message == "resize+" then
            return resize(ctx, 50)
        end

        if message == "reset" then
            return reset_offsets()
        end

        return message .. " is not supported"
    end
})
