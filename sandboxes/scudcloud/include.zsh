#!/usr/bin/env zsh

#includes for go zsh config
function slack() {
	mkdir -p /tmp/scudhome/.config/scudcloud
    mkdir -p ~/.config/scudcloud
    docker run -d \
	    --privileged \
	    --net=host \
	    --device=/dev/snd \
		-e DISPLAY \
		-e QT_GRAPHICSSYSTEM=native \
		-e XAUTHORITY \
		-e DBUS_SESSION_BUS_ADDRESS \
		-u $USER \
        -v /etc/passwd:/etc/passwd:ro \
        -v /etc/group:/etc/group:ro \
        -v $HOME/.Xauthority:$HOME/.Xauthority \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-v /var/run/dbus:/var/run/dbus \
        -v /var/lib/dbus/machine-id:/var/lib/dbus/machine-id \
        -v /tmp/scudhome:$HOME \
		-v $HOME/.config/scudcloud:/home/$USER/.config/scudcloud \
		-v /usr/share/themes:/usr/share/themes \
		markmandel/scudcloud
}