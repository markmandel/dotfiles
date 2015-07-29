#!/usr/bin/env zsh

#includes for go zsh config
function scudcloud() {
    mkdir -p ~/.config/scudcloud
    docker run \
            -e HOST_GID=`id -g` \
            -e HOST_UID=`id -u` \
            -e HOST_USER=$USER \
            -v ~/.config/scudcloud:/home/$USER/.config/scudcloud \
            markmandel/scudcloud
}