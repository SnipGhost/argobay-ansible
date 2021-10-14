#!/bin/sh

if [ "$#" -lt 2 ] ||  [ "$#" -gt 3 ]; then
    echo "Usage: $0 HOSTNAME IP_ADDRESS [DISABLE_WIRELESS]";
	echo "DISABLE_WIRELESS: yes|no, default = yes";
	exit 1;
fi

HOSTNAME=$1
IP_ADDRESS=$2

if [ "$#" -eq 3 ]; then
	DISABLE_WIRELESS=$3
else
	DISABLE_WIRELESS="yes"
fi

export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook playbooks/provision.yml -e "HOSTNAME=${HOSTNAME} rpi_disable_wireless=${DISABLE_WIRELESS}" -i ${IP_ADDRESS}, -i inventory/ -l ${IP_ADDRESS}
unset ANSIBLE_HOST_KEY_CHECKING
