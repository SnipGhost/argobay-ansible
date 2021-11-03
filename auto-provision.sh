#!/bin/sh

usage() {
	echo "Usage: $0 NAME DISABLE_WIRELESS(yes|no) [-e <eth_address>] [-w <wlan_address>]" 1>&2
	exit 1
}

if [ "$#" -lt 2 ]; then
    echo "NAME & DISABLE_WIRELESS arguments required!" 1>&2
	usage
fi

SERVICE_HOST="asuna"

name="$1"
shift
DISABLE_WIRELESS="$1"
shift
opts="$@"

read -s -p "Vault password: " password

printf '\n' 1>&2
candidate=$(./discovery.sh -c | cut -f1 -d\ )
if [ "$candidate" = "" ]; then
	echo "Error: no candidates!" 1>&2
	exit 2
fi
echo "Select $candidate to provision" 1>&2

echo "Update DNS records" 1>&2
cmd_delete=$(./add-dns.sh "$name" -pd)
cmd_create=$(./add-dns.sh "$name" -p $opts)
sshpass -p "$password" ansible -mraw -a "$cmd_delete" $SERVICE_HOST
if [ "$?" -ne "0" ]; then echo "Failed to delete dns-records for $candidate" 1>&2; exit 2; fi
sshpass -p "$password" ansible -mraw -a "$cmd_create" $SERVICE_HOST
if [ "$?" -ne "0" ]; then echo "Failed to create dns-records for $candidate" 1>&2; exit 2; fi
sshpass -p "$password" ansible-playbook playbooks/service.yml --diff --tags dns
if [ "$?" -ne "0" ]; then echo "Failed to run playbooks/service.yml" 1>&2; exit 2; fi

echo "Run provision script on $candidate" 1>&2
export ANSIBLE_HOST_KEY_CHECKING=False
sshpass -p "$password" ansible-playbook playbooks/provision.yml -e "HOSTNAME=${name} rpi_disable_wireless=${DISABLE_WIRELESS}" -i ${candidate}, -i inventory/ -l ${candidate}
if [ "$?" -ne "0" ]; then echo "Failed to run playbooks/provision.yml for $candidate" 1>&2; exit 3; fi
unset ANSIBLE_HOST_KEY_CHECKING

printf "Waiting for ${name}.i "
while ! ping -c 1 -W 1 ${name}.i &> /dev/null
do
    printf "%c" "."
	sleep 1
done
printf "\nServer $name is back online\n"

ssh-keyscan -H $name >> ~/.ssh/known_hosts

echo "Run default all-hosts playbooks on $name" 1>&2
sshpass -p "$password" ansible-playbook playbooks/all_hosts.yml -e "set_passwords=yes" -l "$name"
if [ "$?" -ne "0" ]; then echo "Failed to run playbooks/all_hosts.yml for $name" 1>&2; exit 4; fi
sshpass -p "$password" ansible-playbook playbooks/raspberry.yml -l "$name"
if [ "$?" -ne "0" ]; then echo "Failed to run playbooks/raspberry.yml for $name" 1>&2; exit 4; fi

echo "Update monitoring for $name" 1>&2
sshpass -p "$password" ansible-playbook playbooks/monitroing.yml --diff --tags prometheus
if [ "$?" -ne "0" ]; then echo "Failed to run playbooks/monitroing.yml" 1>&2; exit 5; fi

unset $password
