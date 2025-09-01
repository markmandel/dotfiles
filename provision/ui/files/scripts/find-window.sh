#!/usr/bin/env bash

# Copyright 2025 Mark Mandel All Rights Reserved..
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

# find-window.sh
# Shows a list of Hyprland windows in wofi, then focuses the selected window's workspace
# on the current monitor and focuses the window itself.
#
# Requirements: hyprctl, jq, wofi
#
# The list format embeds the workspace ID and the window address for reliable parsing.

err() { echo "[find-window] $*" >&2; }

# Check dependencies
for cmd in hyprctl jq wofi; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    err "Missing dependency: $cmd"
    exit 1
  fi
done

# Get list of clients as a selectable menu.
# We include:
# - Workspace ID as ws
# - Class and Title for readability
# - Address (unique stable identifier) for targeting focuswindow
#
# Output line example:
# [ws:3] Firefox — GitHub - Issues :: 0x1c7d9d0

menu_lines=$(hyprctl -j clients | jq -r '
  map(select(.workspace.id != null))
  | sort_by(.workspace.id, .class, .title)
  | .[]
  | "[ws:\(.workspace.id)] \(.class // "?") — \(.title // "?") :: \(.address)"')

# If there are no windows, exit gracefully
if [[ -z "${menu_lines//[[:space:]]/}" ]]; then
  err "No windows to show."
  exit 0
fi

# Show the menu in wofi and capture the selection
selection=$(printf "%s\n" "$menu_lines" | wofi --dmenu --prompt "Find window" || true)

# If the user cancelled selection
if [[ -z "${selection:-}" ]]; then
  exit 0
fi

# Extract workspace id and address from the selected line
# Expected format: [ws:<id>] ... :: <address>
wsid=$(sed -n 's/^\[ws:\([0-9]\+\)\].*/\1/p' <<< "$selection")
address=$(sed -n 's/.* :: \(0x[0-9a-fA-F]\+\)$/\1/p' <<< "$selection")

if [[ -z "${wsid:-}" || -z "${address:-}" ]]; then
  err "Failed to parse selection: $selection"
  exit 1
fi

# Focus the workspace on the current monitor, then the specific window
# Using Hyprland dispatchers:
# - focusworkspaceoncurrentmonitor <id>
# - focuswindow address:<address>

hyprctl dispatch focusworkspaceoncurrentmonitor "$wsid" >/dev/null 2>&1 || true
hyprctl dispatch focuswindow "address:$address" >/dev/null 2>&1 || true

exit 0
