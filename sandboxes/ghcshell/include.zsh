#!/usr/bin/env zsh

ghcshell() {
    mkdir -p ~/.cabal
    mkdir -p ~/.ghc

    if [ ! -d /opt/ghc ]; then
        sudo mkdir -p /opt/ghc
        sudo chown -R $USER:`id -g -n` /opt/ghc
    fi

    _docker_zsh "ghcshell" "/project" \
                "-v ~/.cabal:/home/$USER/.cabal" \
                "-v ~/.ghc:/home/$USER/.ghc"
}

clean-ghcshell() {
    rm -r ~/.cabal
    rm -r ~/.ghc
}

ghc-idea() {
    ghc-mount
    ghc-env
    nohup idea.sh > /tmp/idea.log &
}

ghc-env() {
    export PATH=~/.cabal/bin/:$PATH
}

ghc-mount() {
    local name=$1
    local port=$(_get_docker_ssh_port $1)

    echo "Mounting /opt/ghc"

    sshfs $USER@0.0.0.0:/opt/ghc /opt/ghc -p $port -o follow_symlinks
}

compdef __list_docker_containers mount-ghc