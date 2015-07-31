#!/usr/bin/env zsh

#includes for go zsh config
function slack() {
    mkdir -p ~/.config/scudcloud
    docker run --rm \
            --name scudcloud \
            -e HOST_GID=`id -g` \
            -e HOST_UID=`id -u` \
            -e HOST_USER=$USER \
            -e DISPLAY \
            -e DBUS_SESSION_BUS_ADDRESS \
            -e XAUTHORITY \
            -v /tmp/.X11-unix:/tmp/.X11-unix \
            -v ~/.config/scudcloud:/home/$USER/.config/scudcloud \
            -v ~/.Xauthority:/home/$USER/.Xauthority \
            -v /var/lib/dbus/machine-id:/var/lib/dbus/machine-id:ro \
            -v /var/run/dbus:/var/run/dbus \
            markmandel/scudcloud
}