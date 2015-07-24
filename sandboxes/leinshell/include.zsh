#!/usr/bin/env zsh

function leinshell() {
    _docker_zsh "leinshell" "/root/project" \
                "-v $SANDBOXES/leinshell/profiles.clj:/root/.lein/profiles.clj" \
                "-v ~/.m2:/root/.m2" \
                "-p 22"
}