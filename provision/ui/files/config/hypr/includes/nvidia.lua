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

-- NVIDIA module: hardware/driver detection and conditional execution.

local M = {}

--- Detects if an NVIDIA GPU or driver is present.
local function detect_nvidia()
    local f = io.open("/proc/driver/nvidia/version", "r")
    if f then
        f:close()
        return true
    end
    local dev = io.open("/dev/nvidia0", "r")
    if dev then
        dev:close()
        return true
    end
    return false
end

-- Cache whether NVIDIA is available on first load
M.has_nvidia = detect_nvidia()

--- Executes fn() only when an NVIDIA GPU / driver is present.
-- @param fn   function  The function to call if on an NVIDIA machine.
function M.on_nvidia(fn)
    if M.has_nvidia then
        fn()
    end
end

return M
