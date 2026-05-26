--[[
Copyright 2025 Mark Mandel All Rights Reserved.

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

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/

-- Built-in laptop display (only on host "oss")
local hostname = io.popen("hostname"):read("*l")
if hostname == "oss" then
    hl.monitor({ output = "desc:Samsung Display Corp. ATNA40HQ02-0", mode = "2880x1800@60", position = "0x0", scale = 1.5 })
end

-- Alienware external monitor
hl.monitor({ output = "desc:Dell Inc. Dell AW3821DW ##GjMYMxgwAAwA", mode = "3840x1600@30", position = "-3840x-400", scale = 1 })

-- Widescreen Samsung external monitor
hl.monitor({ output = "desc:Samsung Electric Company Odyssey G95SC H1AK500000", mode = "5120x1440@60", position = "-3840x1200", scale = 1 })

-- Nexigo external monitor (Horizontal)
hl.monitor({ output = "desc:BLK NexiGo FHD 0x00000001", mode = "1920x1080@300", position = "-1920x0", scale = 1, transform = 0 })

-- Nexigo external monitor (Vertical) -- uncomment to use
-- hl.monitor({ output = "desc:BLK NexiGo FHD 0x00000001", mode = "1920x1080@300", position = "-1080x0", scale = 1, transform = 1 })

-- Fallback: any unconfigured monitor
hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = "auto",
})