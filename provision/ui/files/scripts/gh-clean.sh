#!/usr/bin/env bash

set -eo pipefail
set -x

gh pr list --author markmandel --state merged --limit 10 --json headRefName --jq '.[] | .headRefName' | xargs -I{} git push origin :{} || true

git checkout main
git remote update -p

git branch -vvv | grep gone | awk '{ print $1 }' | xargs git branch -D || true

git pull --rebase
