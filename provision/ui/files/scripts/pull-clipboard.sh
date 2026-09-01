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

# Pull the clipboard contents from a remote machine onto this one.

set -euo pipefail

host="${1:-discord}"

if [[ "$host" == "-h" || "$host" == "--help" ]]; then
    echo "Usage: $0 [hostname]   (default: discord)"
    exit 0
fi

# clipcopy/clippaste are zsh functions from oh-my-zsh, so they need a zsh that
# has sourced them. Fall back to wl-copy/wl-paste if oh-my-zsh isn't around.
clipboard_lib='$HOME/.oh-my-zsh/lib/clipboard.zsh'

remote_paste=$(cat <<EOF
set -eu

runtime="\${XDG_RUNTIME_DIR:-/run/user/\$(id -u)}"

socket=""
for candidate in "\$runtime"/wayland-*; do
    case "\$candidate" in *.lock) continue ;; esac
    [ -S "\$candidate" ] || continue
    socket="\${candidate##*/}"
    break
done

if [ -z "\$socket" ]; then
    echo "no wayland socket found under \$runtime" >&2
    exit 1
fi

export WAYLAND_DISPLAY="\$socket"

if [ -r "$clipboard_lib" ] && command -v zsh >/dev/null 2>&1; then
    zsh -c 'source "$clipboard_lib"; clippaste'
else
    wl-paste
fi
EOF
)

contents=$(ssh "$host" bash -s <<<"$remote_paste")

if [[ -z "$contents" ]]; then
    echo "Clipboard on $host is empty."
    exit 0
fi

if [[ -r "$HOME/.oh-my-zsh/lib/clipboard.zsh" ]] && command -v zsh >/dev/null 2>&1; then
    printf '%s' "$contents" | zsh -c 'source "$HOME/.oh-my-zsh/lib/clipboard.zsh"; clipcopy'
else
    printf '%s' "$contents" | wl-copy
fi

echo "Copied $(printf '%s' "$contents" | wc -c) bytes from $host:"
printf '%s\n' "$contents" | head -5
