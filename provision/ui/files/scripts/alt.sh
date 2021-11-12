#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

xrandr --output HDMI-0 --off
nvidia-settings --assign CurrentMetaMode="DPY-1: 3840x2160 @3840x2160 +0+0 {ViewPortIn=3840x2160, ViewPortOut=3840x2160+0+0}"

sleep 3
gnome-panel --replace >/dev/null 2>&1 &
# ~/scripts/panel.sh 1

