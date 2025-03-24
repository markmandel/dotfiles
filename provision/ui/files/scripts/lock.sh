#!/bin/bash

# Copyright 2025 Mark Mandel All Rights Reserved.
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


### Discord

lock_discord() {
  killall -STOP Discord
}

unlock_discord() {
  killall -CONT Discord
}

### Lan Mouse

local_lan_mouse() {
  killall lan-mouse
}

unlock_lan_mouse() {
  # Kill any existing lan-mouse processes
  killall lan-mouse

  # Start lan-mouse in daemon mode, redirecting output to /tmp/lan.log
  nohup lan-mouse daemon > /tmp/lan.log 2>&1 &

  # Optional: Check if the process started successfully
  if [[ $? -eq 0 ]]; then
    echo "lan-mouse started successfully (PID: $!)"
    tail /tmp/lan.log
  else
    echo "Error starting lan-mouse"
  fi
}

### Locking

if [ "$1" == "lock" ]; then
  local_lan_mouse
  lock_discord
  echo "locked."
elif [ "$1" == "unlock" ]; then
  unlock_discord
  unlock_lan_mouse
  echo "unlocked."
else
  echo "Usage: $0 {lock|unlock}"
  exit 1
fi

exit 0