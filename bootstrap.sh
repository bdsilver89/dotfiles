#!/usr/bin/env bash

DOTFILES_ROOT=$(cd -P "$(dirname "$0")" && pwd -P)

# Install ansible
# sudo apt-add-repository -y ppa:ansible/ansible
# sudo apt-get update -y
# sudo apt-get install -y curl git software-properties-common ansible
sudo apt install ansible

export ANSIBLE_LOCALHOST_WARNING=False

cd $DOTFILES_ROOT
ansible-playbook -t core ansible/local.yml -K
