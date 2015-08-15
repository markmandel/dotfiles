#!/usr/bin/env zsh

function ghcshell() {
    mkdir -p ~/.cabal
    mkdir -p ~/.ghc
    _docker_zsh "ghcshell" "/project" \
                "-v ~/.cabal:/home/$USER/.cabal" \
                "-v ~/.ghc:/home/$USER/.ghc"
}

function clean-ghcshell {
    rm -r ~/.cabal
    rm -r ~/.ghc
}