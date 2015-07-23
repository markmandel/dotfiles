#!/usr/bin/env zsh

#includes
source $SANDBOXES/goshell/include.zsh
source $SANDBOXES/gcloudshell/include.zsh

#Credit: https://github.com/jbbarth/dotfiles/blob/master/.zsh/docker.zsh
function docker-cleanup() {
  echo "* Removing old containers"
  docker ps -qa | xargs --no-run-if-empty -n 1 docker rm
  echo "* Removing <none> images"
  docker images --filter dangling=true -q | xargs --no-run-if-empty -n 1 docker rmi
}
