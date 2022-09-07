#!/usr/bin/env bash


ROOTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANSIBLEDIR="$ROOTDIR/ansible"
HOSTS="$ANSIBLEDIR/hosts"
PLAYBOOK="$ANSIBLEDIR/dotfiles.yml"

# sudo yum install -y ansible

export ANSIBLE_LOCALHOST_WARNING=False
# ansible-playbook -i "$HOSTS" "$PLAYBOOK" --ask-become-pass
ansible-playbook -i "$HOSTS" "$PLAYBOOK"

exit 0
