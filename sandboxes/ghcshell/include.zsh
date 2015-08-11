#!/usr/bin/env zsh

function ghcshell() {
    mkdir -p ~/.ghcshell/cabal
    mkdir -p ~/.ghcshell/ghc
    _docker_zsh "ghcshell" "/project" \
                "-v ~/.ghcshell/cabal:/home/$USER/.cabal" \
                "-v ~/.ghcshell/ghc:/home/$USER/.ghc"
}