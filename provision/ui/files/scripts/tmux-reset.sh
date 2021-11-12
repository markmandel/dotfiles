#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

tmux kill-server || true

agent=/tmp/agent
if [[ ! -f "$agent" ]]; then
	ssh-agent > "$agent"
fi

source "$agent"
ssh-add

tmux
