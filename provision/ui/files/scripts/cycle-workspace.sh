#!/usr/bin/env bash

# Copyright 2025 Mark Mandel All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -euo pipefail

# cycle-workspace.sh
# Cycles through master, nstack, and dwindle layouts for hyprWorkspaceLayouts plugin.
# Each call switches to the next layout in the sequence: master → nstack → dwindle → master
#
# Requirements: hyprctl

err() { echo "[cycle-workspace] $*" >&2; }

# Check dependencies
if ! command -v hyprctl >/dev/null 2>&1; then
  err "Missing dependency: hyprctl"
  exit 1
fi

# Get current layout from wslayout plugin
current_layout=$(hyprctl getoption plugin:wslayout:layouts -j | jq -r '.str' 2>/dev/null || echo "")

# If layouts is blank, fall back to default_layout
if [[ -z "${current_layout}" ]]; then
  current_layout=$(hyprctl getoption plugin:wslayout:default_layout -j | jq -r '.str' 2>/dev/null || echo "")
fi

if [[ -z "${current_layout}" ]]; then
  err "Failed to get current layout. Is hyprWorkspaceLayouts plugin loaded?"
  exit 1
fi

# Determine next layout in cycle: master → nstack → dwindle → master
case "${current_layout}" in
  master)
    next_layout="nstack"
    ;;
  nstack)
    next_layout="dwindle"
    ;;
  dwindle)
    next_layout="master"
    ;;
  *)
    # If current layout is unknown, default to master
    next_layout="master"
    ;;
esac

# Set the new layout
hyprctl dispatch layoutmsg "setlayout ${next_layout}" >/dev/null 2>&1
hyprctl keyword plugin:wslayout:layouts "${next_layout}" >/dev/null 2>&1
notify-send --urgency low --expire-time 2000 --icon ~/.local/share/icons/rose-pine-icons/16x16/actions/draw-cuboid.svg --app-name "Hyprland" "Layout: ${next_layout}"

echo "Layout cycled: ${current_layout} → ${next_layout}"

exit 0
