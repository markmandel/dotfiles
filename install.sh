#!/bin/sh
sudo apt-get install software-properties-common
sudo apt-add-repository ppa:ansible/ansible
sudo apt-get update
sudo apt-get install ansible git
cd ~

if [ ! -d "~/workspace/dotfiles" ]; then
    mkdir workspace
    cd workspace
    git clone git@github.com:markmandel/dotfiles.git
fi