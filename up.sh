#!/bin/bash

# Copyright 2021 Google LLC All Rights Reserved.
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

#set -x verbose #echo on

#only add the bare necessities to get started. Everything else should be ansible.
workspace="$HOME/workspace"
dot_files="$workspace/dotfiles"

## Grab the Debian version information as env vars
#set -o allexport
#source /etc/os-release
#set +o allexport
#
#echo "Debian Version: ${VERSION_CODENAME}"

playbook="${1:-ui}"

cd $dot_files/provision
echo "Playbook: $playbook.yaml"

ansible-playbook -vvv -K -i hosts "$playbook.yaml" -e ansible_python_interpreter=/usr/bin/python3
