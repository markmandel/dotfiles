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

-- Top-level map: workspace key (string) -> { offsets: table<string, number> }
local workspaces = {}

-- Returns a stable key for a workspace. Workspace ids can be nil (e.g. special
-- workspaces as of Hyprland 0.57), so prefer the name, which is always set.
local function workspace_key(workspace)
    if not workspace then
        return nil
    end
    return workspace.name or (workspace.id ~= nil and tostring(workspace.id)) or nil
end

---@param ctx HL.LayoutContext
-- Returns the key of the workspace being laid out. Derived from the targets'
-- windows rather than the active workspace, since recalculate can run for a
-- workspace that isn't focused (e.g. the normal workspace under a special one).
local function ctx_workspace_key(ctx)
    for _, target in ipairs(ctx.targets) do
        local key = target.window and workspace_key(target.window.workspace)
        if key ~= nil then
            return key
        end
    end
    return workspace_key(hl.get_active_special_workspace() or hl.get_active_workspace()) or ""
end

---@param ctx HL.LayoutContext
-- Returns the offsets table for the workspace being laid out, creating it if needed.
local function get_offsets(ctx)
    local key = ctx_workspace_key(ctx)
    if workspaces[key] == nil then
        workspaces[key] = { offsets = {} }
    end
    return workspaces[key].offsets
end

---@param ctx HL.LayoutContext
-- Resets all column offsets for the workspace, restoring equal-width columns.
local function reset_offsets(ctx)
    workspaces[ctx_workspace_key(ctx)] = nil
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

    -- The far-right window resizes against its left neighbour instead. Since there's
    -- no right neighbour to shrink into, keep the border-direction intuition (H moves
    -- the border left/grows the active column, L moves it right/shrinks it) rather than
    -- the "L always grows the active window" rule used elsewhere.
    local left_idx, right_idx
    if active_idx == n then
        left_idx  = n - 1
        right_idx = n
    else
        left_idx  = active_idx
        right_idx = active_idx + 1
    end

    -- Apply offset: grow left_idx by amount, shrink right_idx by amount
    local left_key  = ctx.targets[left_idx].window and ctx.targets[left_idx].window.address or tostring(left_idx)
    local right_key = ctx.targets[right_idx].window and ctx.targets[right_idx].window.address or tostring(right_idx)

    local offsets = get_offsets(ctx)

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
        local offsets = get_offsets(ctx)
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
            return reset_offsets(ctx)
        end

        return message .. " is not supported"
    end
})
