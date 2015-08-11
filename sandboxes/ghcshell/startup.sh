#!/usr/bin/env sh
groupadd --gid $HOST_GID $HOST_USER
useradd $HOST_USER --home /home/$HOST_USER --gid $HOST_GID --uid $HOST_UID --shell /usr/bin/zsh
chown $HOST_USER:$HOST_USER /home/$HOST_USER

#setup cabal for this user
cp -r /root/.cabal/* /home/$HOST_USER/.cabal/
cp -r /root/.ghc/* /home/$HOST_USER/.ghc/
chown -R $HOST_USER:$HOST_USER /home/$HOST_USER

su $HOST_USER