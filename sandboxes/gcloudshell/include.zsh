#!/usr/bin/env zsh

#includes for go zsh config
function gcloudshell() {

    docker run --rm \
	    -v ~/.oh-my-zsh:/root/.oh-my-zsh \
	    -v ~/.dircolors:/root/.dircolors \
	    -v ~/.zsh_history:/root/.zsh_history \
	    -v $SANDBOXES/gcloudshell/zshrc:/root/.zshrc \
	    -v ~/.config:/root/.config \
	    -v `pwd`:/go \
	    -it markmandel/gcloudshell zsh
}