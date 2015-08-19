#!/usr/bin/env zsh

#docker run -d \
#		-v /tmp/.X11-unix:/tmp/.X11-unix \
#		-e DISPLAY=unix$DISPLAY \
#		-v /etc/machine-id:/etc/machine-id:ro \
#		-v /var/run/dbus:/var/run/dbus \
#		-v /var/run/user/$(id -u):/var/run/user/$(id -u) \
#		-e TERM \
#		-e XAUTHORITY \
#		-e DBUS_SESSION_BUS_ADDRESS \
#		-e HOME \
#		-e QT_DEVICE_PIXEL_RATIO \
#		-v /etc/passwd:/etc/passwd:ro \
#		-v /etc/group:/etc/group:ro \
#		-u $(whoami) -w "$HOME" \
#		-v $HOME/.Xauthority:$HOME/.Xauthority \
#		-v /etc/machine-id:/etc/machine-id:ro \
#		-v $HOME/.scudcloud:/home/jessie/.config/scudcloud \
#		--device /dev/snd \
#		--name slack \
#		jess/slack

#includes for go zsh config
function slack() {
    mkdir -p ~/.config/scudcloud
    docker run --rm -it \
            --privileged \
            --name scudcloud \
            --device /dev/snd \
            --privileged \
            -e DISPLAY \
            -e XAUTHORITY \
            -e DBUS_SESSION_BUS_ADDRESS \
            -u $USER \
            -v /etc/localtime:/etc/localtime:ro \
            -v /tmp/.X11-unix:/tmp/.X11-unix \
            -v /etc/passwd:/etc/passwd:ro \
            -v /etc/group:/etc/group:ro \
            -v $HOME/.Xauthority:$HOME/.Xauthority \
            -v $HOME/.config/scudcloud:/home/$USER/.config/scudcloud \
            -v /var/run/dbus:/var/run/dbus \
            -v /var/run/user/$(id -u):/var/run/user/$(id -u) \
            markmandel/scudcloud
}