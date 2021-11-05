#!/bin/sh

usage() {
	echo "Usage: $0 [-i <ip_address>] [-a <arch>]" 1>&2
	exit 1
}

# Parse arguments
while getopts "i:a:h" o; do
	case "${o}" in
		i)
			IP_ADDRESS="${OPTARG}"
			;;
		a)
			ARCH="${OPTARG}"
			;;
		h)
			usage
			;;
		*)
			usage
			;;
	esac
done

if [ -z "$IP_ADDRESS" ]; then
	IP_ADDRESS="192.168.8.80"
fi

if [ -z "$ARCH" ]; then
	ARCH="armv6"
fi

export ANSIBLE_HOST_KEY_CHECKING=False
export ANSIBLE_CONFIG=omegastation-ansible.cfg
ansible-playbook playbooks/omegastation.yml --ask-pass -i "${IP_ADDRESS}," -e "proc_version=${ARCH}"
unset ANSIBLE_HOST_KEY_CHECKING
unset ANSIBLE_CONFIG
