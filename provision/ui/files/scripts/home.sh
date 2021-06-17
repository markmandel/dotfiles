#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

~/scripts/panel.sh 0

nvidia-settings --assign CurrentMetaMode="DPY-0: 3440x1440 @3440x1440 +0+0 {ViewPortIn=3440x1440, ViewPortOut=3440x1440+0+0}, DPY-1: nvidia-auto-select @2560x1440 +3440+0 {ViewPortIn=2560x1440, ViewPortOut=3840x2160+0+0}"
xrandr --output HDMI-0 --primary
dconf write /org/cinnamon/desktop/interface/scaling-factor "1"

killall copyq || true
killall flameshot || true

sleep 3
nohup copyq >/dev/null 2>&1 &

