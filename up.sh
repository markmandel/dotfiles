#!/bin/sh

set -x verbose #echo on

#only add the bare necessities to get started. Everything else should be ansible.
workspace=~/workspace/
ansible="$workspace/ansible"
ansible_git="git@github.com:markmandel/ansible.git"
dot_files="$workspace/dotfiles"

if [ -f $workspace ]; then

	#provision ansible itself
	if [ ! -f $ansible ]; then
		echo "Cloning Ansible..."
		git clone $ansible_git $ansible
	else
		echo "Updating Ansible..."
		cd $ansible
		git pull --rebase
	fi

	cd $ansible
	source hacking/env-setup

	#self update
	echo "Updating Dotfiles..."
	cd $dot_files
	git pull --rebase

	echo "Which machine are you?"
	select sp in "Primary" "Secondary"; do
		case $sp in
			Primary ) ansible-playbook ./provision/primary.yml;;
			Secondary ) ansible-playbook ./provision/secondary.yml;;
		esac
	done

else
	echo "$workspace does not exist. WTF?"
fi