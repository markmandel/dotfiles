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
# Cycles through master, scrolling, and dwindle layouts for the current workspace.
# Each call switches to the next layout in the sequence: master → scrolling → dwindle → master
#
# Requirements: hyprctl

err() { echo "[cycle-workspace] $*" >&2; }

# Check dependencies
if ! command -v hyprctl >/dev/null 2>&1; then
  err "Missing dependency: hyprctl"
  exit 1
fi

# Get current workspace ID and layout
active_workspace=$(hyprctl activeworkspace -j)
current_workspace_id=$(echo "${active_workspace}" | jq -r '.id')
current_layout=$(echo "${active_workspace}" | jq -r '.tiledLayout' 2>/dev/null || echo "")

if [[ -z "${current_layout}" ]]; then
  err "Failed to get current layout."
  exit 1
fi

# Determine next layout in cycle: master → scrolling → dwindle → master
case "${current_layout}" in
  master)
    next_layout="scrolling"
    ;;
  scrolling)
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

# Set the new layout for the current workspace using workspace rules
hyprctl keyword workspace "${current_workspace_id},layout:${next_layout}" >/dev/null 2>&1
notify-send --urgency low --expire-time 2000 --icon ~/.local/share/icons/rose-pine-icons/16x16/actions/draw-cuboid.svg --app-name "Hyprland" "Layout: ${next_layout}"

echo "Layout cycled: ${current_layout} → ${next_layout}"

exit 0
