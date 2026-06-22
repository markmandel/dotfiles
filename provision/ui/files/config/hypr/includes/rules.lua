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

------------------------------
--- WINDOWS AND WORKSPACES ---
------------------------------

-- See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
-- See https://wiki.hyprland.org/Configuring/Workspace-Rules/ for workspace rules

hl.config({
    binds = {
        hide_special_on_workspace_change = true,
    },
    misc = {
        initial_workspace_tracking = 1
    }
})

-- Ignore maximize requests from apps. You'll probably like this.
hl.window_rule({
    name           = "ignore-maximize-requests",
    suppress_event = "maximize",
    match          = { class = ".*" },
})

-- Fix some dragging issues with XWayland
hl.window_rule({
    name  = "fix-xwayland-dragging",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

-- Terminal scratchpad
hl.window_rule({
    name      = "terminal-scratchpad",
    workspace = "special:terminal",
    match     = { class = "^(com.markmandel.scratchpad)$" },
})

-- KeepassXC
hl.window_rule({
    name      = "keepassxc",
    float     = true,
    center    = true,
    size      = "(monitor_w*0.5) (monitor_h*0.75)",
    workspace = "special:keepass",
    match     = { class = "^(org.keepassxc.KeePassXC)$" },
})

-- CopyQ
hl.window_rule({
    name  = "copyq",
    float = true,
    size  = "(monitor_w*0.5) (monitor_h*0.75)",
    match = { class = "^(com.github.hluk.copyq)$" },
})

-- XDG desktop portal (GTK) file picker, etc.
hl.window_rule({
    name   = "xdg-desktop-portal-gtk",
    float  = true,
    center = true,
    size   = "(monitor_w*0.6) (monitor_h*0.8)",
    match  = { class = "^(xdg-desktop-portal-gtk)$" },
})
