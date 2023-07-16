#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

~/scripts/panel.sh 0

nvidia-settings --assign CurrentMetaMode="DPY-1: nvidia-auto-select @2560x1440 +3840+0 {ViewPortIn=2560x1440, ViewPortOut=3840x2160+0+0}, DPY-0: 3840x1600_85 @3840x1600 +0+0 {ViewPortIn=3840x1600, ViewPortOut=3840x1600+0+0}"

xrandr --output HDMI-0 --primary

dconf write /org/cinnamon/desktop/interface/text-scaling-factor 0.8
dconf write /org/gnome/gnome-panel/layout/toplevels/top-panel/size 16
dconf write /org/cinnamon/desktop/interface/cursor-size 24

~/scripts/resize.sh

