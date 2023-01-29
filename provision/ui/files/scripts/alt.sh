#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

xrandr --output HDMI-0 --off
nvidia-settings --assign CurrentMetaMode="DPY-1: nvidia-auto-select @3840x2160 +0+0 {ViewPortIn=3840x2160, ViewPortOut=3840x2160+0+0}"
dconf write /org/cinnamon/desktop/interface/text-scaling-factor 1.4
dconf write /org/gnome/gnome-panel/layout/toplevels/top-panel/size 30
dconf write /org/cinnamon/desktop/interface/cursor-size 38
dconf write /org/gnome/gnome-panel/layout/toplevels/top-panel/auto-hide-size 0

~/scripts/resize.sh
