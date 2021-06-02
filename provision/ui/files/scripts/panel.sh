#!/usr/bin/env bash

set -e

dconf write /org/gnome/gnome-panel/layout/toplevels/top-panel/monitor "${1}"