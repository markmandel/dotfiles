#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

rclone mount Drive:/ ~/GoogleDrive --daemon

