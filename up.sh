#!/bin/bash
#set -x verbose #echo on

#only add the bare necessities to get started. Everything else should be ansible.
workspace="$HOME/workspace"
ansible="$workspace/ansible"
ansible_git="https://github.com/ansible/ansible.git"
dot_files="$workspace/dotfiles"

if [ -d $workspace ]; then

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
