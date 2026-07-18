#!/usr/bin/env bash

# Copyright 2026 Mark Mandel All Rights Reserved.
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

# Removes everything installed by the source-compiled Hyprland stack that
# provision/ui/tasks/hyprland-install.yaml builds out of /opt/hyprland, so
# the Debian-packaged hyprland can take over cleanly.
#
# Two sources of truth are combined:
#
# 1. Each CMake project's build/install_manifest.txt (regenerated fresh on
#    every `cmake --install`, so it matches whatever that project's *current*
#    build actually put on disk) plus Meson's install-plan JSON for the one
#    Meson subproject (hyprland-protocols). Read live from /opt/hyprland, not
#    stored in this repo - they're tied to whatever version was last
#    installed on this machine and would go stale the moment a component's
#    tag bumps.
#
# 2. A broad filesystem sweep for anything under /usr matching *hypr* or
#    *aquamarine*. This is the safety net for the manifests' main blind spot:
#    cmake install only ever adds/overwrites the files in the *current*
#    build - it never removes a file that existed in a previously installed
#    version but isn't part of the current one (a header that got moved, a
#    default config that stopped being installed, a stray leftover from a
#    version that was tried and then rolled back). It also covers the case
#    where /opt/hyprland is gone entirely and there's no manifest to read at
#    all.
#
# Because the sweep is name-based rather than exact, every candidate from
# both sources is cross-checked with `dpkg -S` and dropped if it belongs to
# an installed package - e.g. waybar ships man pages named
# waybar-hyprland-*.5.gz and quickshell ships a QML plugin at
# .../qt6/qml/Quickshell/Hyprland/, neither of which this script should ever
# touch.
#
# Usage:
#   hyprland-uninstall-source.sh                 # dry run - lists what would be removed
#   hyprland-uninstall-source.sh --yes            # actually removes the files
#   hyprland-uninstall-source.sh --yes --purge-source  # also deletes /opt/hyprland

set -euo pipefail

HYPR_OPT_DIR="/opt/hyprland"
APPLY=false
PURGE_SOURCE=false

for arg in "$@"; do
  case "$arg" in
    --yes|-y) APPLY=true ;;
    --purge-source) PURGE_SOURCE=true ;;
    *) echo "Unknown argument: $arg" >&2; exit 1 ;;
  esac
done

tmpfile=$(mktemp)
trap 'rm -f "$tmpfile"' EXIT

manifest_count=0
if [[ -d "$HYPR_OPT_DIR" ]]; then
  for manifest in "$HYPR_OPT_DIR"/*/build/install_manifest.txt; do
    [[ -f "$manifest" ]] || continue
    # cmake's install_manifest.txt files are never newline-terminated, so a
    # plain `cat` would glue the last path of one manifest onto the first
    # path of the next. Force a newline after each file's contents.
    (cat "$manifest"; echo) >> "$tmpfile"
    manifest_count=$((manifest_count + 1))
  done

  protocols_json="$HYPR_OPT_DIR/Hyprland/subprojects/hyprland-protocols/build/meson-info/intro-installed.json"
  if [[ -f "$protocols_json" ]]; then
    jq -r '.[]' "$protocols_json" >> "$tmpfile"
  fi
fi

echo "Collected $(sort -u "$tmpfile" | wc -l) paths from $manifest_count install manifest(s)."
echo "Sweeping /usr for anything else matching hypr*/aquamarine*..."
find /usr -iname "*hypr*" -o -iname "*aquamarine*" 2>/dev/null >> "$tmpfile"

echo "Cross-checking against dpkg to avoid touching files owned by installed packages..."
mapfile -t CANDIDATES < <(sort -u "$tmpfile")
FILES=()
for f in "${CANDIDATES[@]}"; do
  [[ -n "$f" ]] || continue
  if dpkg -S "$f" >/dev/null 2>&1; then
    continue
  fi
  FILES+=("$f")
done

echo "Found ${#FILES[@]} paths to remove:"
printf '  %s\n' "${FILES[@]}"

if [[ "$APPLY" != true ]]; then
  echo
  echo "Dry run only. Re-run with --yes to actually remove these paths."
  exit 0
fi

echo
echo "Removing..."
printf '%s\n' "${FILES[@]}" | sudo xargs -r rm -rvf --

echo "Refreshing linker cache..."
sudo ldconfig

if [[ "$PURGE_SOURCE" == true ]]; then
  echo "Removing $HYPR_OPT_DIR..."
  sudo rm -rf "$HYPR_OPT_DIR"
else
  echo "Leaving $HYPR_OPT_DIR in place (re-run with --purge-source to delete it)."
fi

echo "Done. Install hyprland via apt now: sudo apt install hyprland"
