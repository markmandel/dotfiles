#!/bin/bash
#set -x verbose #echo on

#only add the bare necessities to get started. Everything else should be ansible.
workspace="$HOME/workspace"
ansible="$workspace/ansible"
ansible_git="https://github.com/ansible/ansible.git"
dot_files="$workspace/dotfiles"

if [ -d $workspace ]; then

	#provision ansible itself
	if [ ! -d $ansible ]; then
		echo "Cloning Ansible..."
		git clone $ansible_git $ansible
	else
		echo "Updating Ansible..."
		cd $ansible
		git pull --rebase
	fi

	echo "Setting up Ansible in $ansible"
	#for some reason have to go one level in. Don't ask, it works.	
	cd $ansible/hacking
	source env-setup

	ansible --version

	#self update
	echo "Updating Dotfiles..."
	cd $dot_files
	git pull --rebase

	#control which playbook is run from which machine by a .playbook file
	cd $dot_files
	playbook=`cat .playbook`.yml
	echo "Playbook is: ${playbook}"

	cd $dot_files/provision

	ansible-playbook -vvv -K -i hosts $playbook

else
	echo "$workspace does not exist. WTF?"
fi
