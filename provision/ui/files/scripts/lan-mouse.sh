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

# TOXO: turn this into a "lock/unlock" script, that pauses Discord on lock and continues on the other side.

# Kill any existing lan-mouse processes
killall lan-mouse

# Start lan-mouse in daemon mode, redirecting output to /tmp/lan.log
nohup lan-mouse --daemon > /tmp/lan.log 2>&1 &

# Optional: Check if the process started successfully
if [[ $? -eq 0 ]]; then
  echo "lan-mouse started successfully (PID: $!)"
  tail /tmp/lan.log
else
  echo "Error starting lan-mouse"
fi

