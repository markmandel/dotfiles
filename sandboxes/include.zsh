#!/usr/bin/env zsh

#Source all the shells
for p in $SANDBOXES/*; do
    if [[ -d $p ]]; then
        source $p/include.zsh
    fi
done

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
        "-P=true" \
        "-e TERM=$TERM " \
        "-e HOST_GID=`id -g`" \
        "-e HOST_UID=`id -u`" \
        "-e HOST_USER=$USER" \
        "-v ~/.oh-my-zsh:/home/$USER/.oh-my-zsh" \
        "-v ~/.dircolors:/home/$USER/.dircolors " \
        "-v ~/.zsh_history:/home/$USER/.zsh_history" \
        "-v $SANDBOXES/$shell/zshrc:/home/$USER/.zshrc" \
        "-v $SANDBOXES/core.zsh:/home/$USER/.core.zsh" \
        "-v `pwd`:$src" \
        ${argv:3} \
        "-it markmandel/$shell /root/startup.sh"
}

_get_docker_ssh_port() {
    local name=$1

    typeset -a port

    port=(${(@s/:/)$(docker port $name 22)})

    echo $port[2]
}

#ssh mount a docker container
function docker-ssh-mount() {
    local name=$1
    local mountpoint=/tmp/$name
    local port=$(_get_docker_ssh_port $name)

    mkdir -p $mountpoint
    echo "Mounting on $port"
    sshfs $USER@0.0.0.0:/ $mountpoint -p $port -o follow_symlinks
}

compdef __list_docker_containers docker-ssh-mount

#attach a new zsh termainl to an already running shell
shell-attach() {
    docker exec -it -u=$USER $1 /usr/bin/zsh
}

compdef __list_docker_containers shell-attach

#Credit: _docker .oh-my-zsh plugin
__list_docker_containers() {
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

docker-known-hosts-clear() {
    cp ~/.ssh/known_hosts ~/.ssh/known_hosts.old
    grep -v 0.0.0.0 ~/.ssh/known_hosts.old > ~/.ssh/known_hosts
}