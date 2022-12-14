#!/usr/bin/env bash

DOTFILES_ROOT=$(cd -P "$(dirname "$0")" && pwd -P)

if ! [ -x "$(command -v ansible)" ]; then
  if [ -f /etc/lsb-release ]; then
    echo "Installing ansible for debian"
    # sudo apt-add-repository -y ppa:ansible/ansible
    # sudo apt-get update -y
    # sudo apt-get install -y curl git software-properties-common ansible
    sudo apt install ansible -y

  elif [ -f /etc/redhat-release ]; then
    echo "Installing ansible for redhat"
    sudo yum install ansible -y
  else
    echo "Unsupported platform!"
    exit 1
  fi
fi

tags="$@"
if [ "$#" -eq 0 ]; then
  tags="all"
else
  # sed -e '/s\s\+/,/g' $tags
  tags="${tags// /,}"
fi

echo "Boostrapping [$tags]"
cd $DOTFILES_ROOT && ansible-playbook -i ansible/hosts ansible/dotfiles.yml -K --tags ${tags}
