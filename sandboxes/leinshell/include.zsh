#!/usr/bin/env zsh

function leinshell() {
    _docker_zsh "leinshell" "/project" \
                "-v $SANDBOXES/leinshell/profiles.clj:/root/.lein/profiles.clj" \
                "-v ~/.m2:/root/.m2" \
                "-p 22"
}

##includes for go zsh config
#function goshell() {
#    set -x
#
#    local home=/home/$USER
#
#    docker run --rm \
#	    -v ~/.oh-my-zsh:$home/.oh-my-zsh \
#	    -v ~/.dircolors:$home/.dircolors \
#	    -v ~/.zsh_history:$home/.zsh_history \
#	    -v $SANDBOXES/goshell/zshrc:$home/.zshrc \
#	    -v `pwd`:/go \
#	    -it markmandel/goshell \
#	    sh -c "groupadd --gid `id -g` default \
#	           && useradd $USER --home $home --gid `id -g` --uid `id -u` \
#	           && chown -R $USER /go \
#	           && su $USER -c zsh"
#r
#   set +x
#-}