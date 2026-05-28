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

-- Hostname module: cached hostname lookup and hostname-conditional execution.

local M = {}

-- Cache the hostname on first load
M.hostname = io.popen("hostname"):read("*l")

--- Executes fn() only when the current hostname matches the given name.
-- @param name string  The hostname to match against.
-- @param fn   function  The function to call if the hostname matches.
function M.on_host(name, fn)
    if M.hostname == name then
        fn()
    end
end

return M
