#!/usr/bin/env zsh

#includes
source $SANDBOXES/goshell/include.zsh
source $SANDBOXES/gcloudshell/include.zsh
source $SANDBOXES/leinshell/include.zsh

#Takes each argument and applies it to a docker run command
function _docker_run() {
    eval "docker run $argv"
}

#standard default docker zsh function
function _docker_zsh() {
    local shell=$1
    local src=$2
    local name=$shell${${PWD//\//.}:-200} #make sure we stay under 255 chars

    echo "Starting Container: $name (${#name})"

    _docker_run "--rm" \
        "--name $name" \
        "-e HOST_GID=`id -g`" \
        "-e HOST_UID=`id -u`" \
        "-e HOST_USER=$USER" \
        "-v ~/.oh-my-zsh:/root/.oh-my-zsh" \
        "-v ~/.dircolors:/root/.dircolors " \
        "-v ~/.zsh_history:/root/.zsh_history" \
        "-e TERM=$TERM " \
        "-v $SANDBOXES/$shell/zshrc:/root/.zshrc" \
        "-v `pwd`:$src" \
        ${argv:3} \
        "-it markmandel/$shell /root/startup.sh"
}

#ssh mount a docker container
function docker-ssh-mount() {
    local name=$1
    local mountpoint=/tmp/$name

    port=(${(@s/:/)$(docker port $name)})
    echo "Found: $(docker port $name)"
    mkdir -p $mountpoint
    echo "Mounting on $port[2]"
    sshfs root@0.0.0.0:/ $mountpoint -p $port[2]
}

compdef __docker_ssh_mount docker-ssh-mount

#Credit: _docker .oh-my-zsh plugin
__docker_ssh_mount() {
    declare -a cont_cmd
    cont_cmd=($(docker ps | awk 'NR>1{print $NF":[CON("$1")"$2"("$3")]"}'))
    if [[  'X$cont_cmd' != 'X' ]]
        _describe 'containers' cont_cmd
}

alias dsm=docker-ssh-mount

#Credit: https://github.com/jbbarth/dotfiles/blob/master/.zsh/docker.zsh
function docker-cleanup() {
    echo "* Removing old containers"
    docker ps -qa | xargs --no-run-if-empty -n 1 docker rm
    echo "* Removing <none> images"
    docker images --filter dangling=true -q | xargs --no-run-if-empty -n 1 docker rmi
}

alias dc=docker-cleanup
