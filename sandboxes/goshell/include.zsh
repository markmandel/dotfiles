#!/usr/bin/env zsh

function check() {
    echo $0
	echo `realpath $0`
}

#includes for go zsh config
function goshell() {

    docker run --rm \
	    -v ~/.oh-my-zsh:/root/.oh-my-zsh \
	    -v ~/.dircolors:/root/.dircolors \
	    -v ~/.zsh_history:/root/.zsh_history \
	    -v $SANDBOXES/goshell/zshrc:/root/.zshrc \
	    -v `pwd`:/go \
	    -it markmandel/goshell zsh
}