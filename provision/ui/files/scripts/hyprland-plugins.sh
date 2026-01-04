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

# hyprland-plugins.sh
# Installs and enables Hyprland plugins using hyprpm.
# This script requests sudo password upfront to cache credentials,
# but hyprpm commands run as the regular user (not under sudo).
#
# Requirements: hyprpm

err() { echo "[install-hyprland-plugins] $*" >&2; }

# Check dependencies
if ! command -v hyprpm >/dev/null 2>&1; then
  err "Missing dependency: hyprpm"
  exit 1
fi

echo "Updating hyprpm..."
hyprpm -v update

echo "Adding hyprNStack plugin..."
yes | hyprpm -v add https://github.com/zakk4223/hyprNStack || true

echo "Adding hyprWorkspaceLayouts plugin..."
yes | hyprpm -v add https://github.com/zakk4223/hyprWorkspaceLayouts || true

echo "Enabling hyprNStack..."
hyprpm enable hyprNStack

echo "Enabling hyprWorkspaceLayouts..."
hyprpm enable hyprWorkspaceLayouts

echo "Updating hyprpm again..."
hyprpm -v update

echo "Reloading Hyprland plugins..."
hyprpm reload || true

echo "Hyprland plugins installation complete!"

exit 0
