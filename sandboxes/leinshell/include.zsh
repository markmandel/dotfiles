#!/usr/bin/env zsh

function leinshell() {
    mkdir -p ~/.m2
    _docker_zsh "leinshell" "/project" \
                "-v $SANDBOXES/leinshell/profiles.clj:/home/$USER/.lein/profiles.clj" \
                "-v ~/.m2:/home/$USER/.m2" \
                "-p 22"
}