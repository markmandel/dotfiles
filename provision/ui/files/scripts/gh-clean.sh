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

git fetch --all --prune

# Delete remote branches of my merged PRs that still exist on origin.
# Pushing the delete also removes the remote-tracking ref, so the local branch shows as gone.
gh pr list --author @me --state merged --limit 20 --json headRefName --jq '.[].headRefName' |
    while read -r branch; do
        if git show-ref --verify --quiet "refs/remotes/origin/${branch}"; then
            git push origin --delete "${branch}" || true
        fi
    done

default_branch=$(git rev-parse --abbrev-ref origin/HEAD 2> /dev/null || echo origin/main)
git switch "${default_branch#origin/}"

# Remove workmux worktrees (and their tmux windows) whose upstream branch is gone,
# before deleting branches, as git won't delete a branch checked out in a worktree.
if command -v workmux &> /dev/null; then
    workmux remove --gone || true
fi
git worktree prune

# Delete local branches whose upstream is gone. Uses -D, as squash merges aren't seen as merged.
git for-each-ref --format '%(refname:short) %(upstream:track)' refs/heads |
    awk '$2 == "[gone]" { print $1 }' |
    xargs -r git branch -D

git pull --rebase
