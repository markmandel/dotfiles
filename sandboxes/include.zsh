#!/usr/bin/env zsh

#includes
source $SANDBOXES/goshell/include.zsh
source $SANDBOXES/gcloudshell/include.zsh

function _run_docker_zsh() {
    #TODO: pass in /where to mount as a parameter
    local shell=$1
    local dir=$shell
    local src

    #if here is a second value, use that as the dir
    if [ -z "$3" ]
        then
            src=$2
        else
            dir=$2
            src=$3
    fi

    docker run --rm \
	    -v ~/.oh-my-zsh:/root/.oh-my-zsh \
	    -v ~/.dircolors:/root/.dircolors \
	    -v ~/.zsh_history:/root/.zsh_history \
	    -e TERM=$TERM \
	    -v $SANDBOXES/$dir/zshrc:/root/.zshrc \
	    -v `pwd`:$src \
	    -it markmandel/$shell zsh
}

#Credit: https://github.com/jbbarth/dotfiles/blob/master/.zsh/docker.zsh
function docker-cleanup() {
    echo "* Removing old containers"
    docker ps -qa | xargs --no-run-if-empty -n 1 docker rm
    echo "* Removing <none> images"
    docker images --filter dangling=true -q | xargs --no-run-if-empty -n 1 docker rmi
}