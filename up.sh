#!/bin/bash
#set -x verbose #echo on

#only add the bare necessities to get started. Everything else should be ansible.
workspace="$HOME/workspace"
ansible="$workspace/ansible"
ansible_git="git@github.com:markmandel/ansible.git"
dot_files="$workspace/dotfiles"

sudo apt-get install python python-yaml python-jinja2

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

	cd $dot_files/provision
	echo "Which machine are you?"
	select sp in "Primary" "Secondary"; do
		case $sp in
			Primary ) 
				ansible-playbook -vvv -K -i hosts primary.yml
				break				
				;;
			Secondary ) 
				ansible-playbook -vvv -K -i hosts secondary.yml
				break
				;;
		esac
	done

else
	echo "$workspace does not exist. WTF?"
fi
