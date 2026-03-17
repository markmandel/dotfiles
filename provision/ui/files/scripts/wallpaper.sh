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

cd ~/Pictures/wallpapers

mkdir -p archive
mv wallpaper.png "./archive/wallpaper-$(date).png" || true

# choose a wallpaper at random in this directory
wall=$(find . -maxdepth 1 -type f -name '*.png' ! -name 'wallpaper.png' | shuf -n 1)

if [[ -z "$wall" ]]; then
    echo "No wallpapers found"
    exit 0
fi

echo "Selected wallpaper: $wall"

lutgen apply --palette rose-pine --nearest=0 --output wallpaper.png "$wall"

# open the above wallpaper in a subprocess, just so I can see the original
xdg-open "$wall" &
sleep 1 # give the viewer a chance to open it

# trash the above wallpaper
trash "$wall"

# kill hyprpaper and restart it.
killall hyprpaper || true
hyprpaper &

