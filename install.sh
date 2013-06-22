#!/bin/sh
sudo apt-get install git python python-yaml python-jinja2
cd ~
mkdir workspace
cd workspace
git clone git@github.com:markmandel/dotfiles.git