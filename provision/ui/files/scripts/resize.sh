#!/usr/bin/env bash

# Run this after you have dne all the work resizing screens.

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

systemctl restart --user dunst.service
dconf write /org/gnome/desktop/interface/clock-show-date true
notify-send RESIZED!
