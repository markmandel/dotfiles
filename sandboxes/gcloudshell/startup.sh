#!/usr/bin/env sh
set -x

groupadd --gid $HOST_GID $HOST_USER
useradd $HOST_USER --home /home/$HOST_USER --gid $HOST_GID --uid $HOST_UID --shell /usr/bin/zsh
chown $HOST_USER:$HOST_USER /home/$HOST_USER
chown -R $HOST_USER:$HOST_USER /google-cloud-sdk
chown -R $HOST_USER:$HOST_USER /go_appengine

#allow docker passthrough
groupadd --gid $DOCKER_GID docker
usermod -a -G docker $HOST_USER

set +x

su $HOST_USER

