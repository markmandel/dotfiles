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
        "-e TERM=$TERM " \
        "-e HOST_GID=`id -g`" \
        "-e HOST_UID=`id -u`" \
        "-e HOST_USER=$USER" \
        "-v ~/.oh-my-zsh:/home/$USER/.oh-my-zsh" \
        "-v ~/.dircolors:/home/$USER/.dircolors " \
        "-v ~/.zsh_history:/home/$USER/.zsh_history" \
        "-v $SANDBOXES/$shell/zshrc:/home/$USER/.zshrc" \
        "-v `pwd`:$src" \
        ${argv:3} \
        "-it markmandel/$shell /root/startup.sh"
}

#ssh mount a docker container
function docker-ssh-mount() {
    local name=$1
    local mountpoint=/tmp/$name
    typeset -a port

    port=(${(@s/:/)$(docker port $name 22)})
    echo "Found: $(docker port $name 22)"
    mkdir -p $mountpoint
    echo "Mounting on $port[2]"
    sshfs $USER@0.0.0.0:/ $mountpoint -p $port[2] -o follow_symlinks
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
