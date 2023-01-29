#!/usr/bin/env bash

# Run this after you have dne all the work resizing screens.

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

#killall copyq || true
#killall flameshot || true

#sleep 3
#gnome-panel --replace >/dev/null 2>&1 &
#nohup copyq >/dev/null 2>&1 &
systemctl restart --user dunst.service
notify-send RESIZED!
