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

set -eo pipefail
set -x

gh pr list --author markmandel --state merged --limit 10 --json headRefName --jq '.[] | .headRefName' | xargs -I{} git push origin :{} || true

git checkout main
git remote update -p

git branch -vvv | grep gone | awk '{ print $1 }' | xargs git branch -D || true
git pull --rebase
