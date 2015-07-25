#!/usr/bin/env sh
set -x

groupadd --gid $HOST_GID $HOST_USER
useradd $HOST_USER --home /home/$HOST_USER --gid $HOST_GID --uid $HOST_UID --shell /usr/bin/zsh

set +x

/usr/sbin/sshd
su $HOST_USER
