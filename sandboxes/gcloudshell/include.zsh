#!/usr/bin/env zsh

#includes for go zsh config
function gcloudshell() {
    mkdir -p ~/.config/gcloud
    touch ~/.appcfg_oauth2_tokens
    typeset -a dockerGroup
    dockerGroup=(${(@s/:/)$(getent group docker)})

    _docker_zsh 'gcloudshell' '/go' \
                "-e DOCKER_GID=$dockerGroup[3]" \
                "-v ~/.appcfg_oauth2_tokens:/home/$USER/.appcfg_oauth2_tokens" \
                "-v ~/.config/gcloud:/home/$USER/.config/gcloud" \
                "-v /usr/bin/docker:/usr/bin/docker" \
                "-v /var/run/docker.sock:/var/run/docker.sock"
}