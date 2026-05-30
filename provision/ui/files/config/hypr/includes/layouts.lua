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

local state = {
    -- store the width offsets per target/window
    offsets = {}
}

---@param ctx HL.LayoutContext
---@param amount number
-- Resize the active window by the given amount, and adjust the offsets for window on the right.
-- The far right window will need to adjust the window on the left.
local function resize(ctx, amount)
    hl.notification.create({ text = "Resizing: " .. amount, duration = 10000 })
    -- TODO: Implement resize logic
end

hl.layout.register("columns", {
    recalculate = function (ctx)
        hl.notification.create({ text = "recalculating", duration = 1000 })
        local n = #ctx.targets
        if n == 0 then
            return
        end

        for i, target in ipairs(ctx.targets) do
            -- get the default column box for this index, for this number of columns
            local box = ctx:column(i, n)
            target:place(box)
        end
    end,
    layout_msg = function (ctx, message)
        hl.notification.create({ text = message, duration = 10000 })

        if message == "swapwithmaster" then
            return swap_with_master(ctx)
        end

        if message == "resize-" then
            return resize(ctx, -50)
        end

        if message == "resize+" then
            return resize(ctx, 50)
        end

        return message .. " is not supported"
    end
})
