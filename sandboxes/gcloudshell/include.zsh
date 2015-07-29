#!/usr/bin/env zsh

#includes for go zsh config
function gcloudshell() {
    mkdir -p ~/.config/gcloud
	_docker_zsh 'gcloudshell' '/go' \
				"-v ~/.config/gcloud:/home/$USER/.config/gcloud"
}

