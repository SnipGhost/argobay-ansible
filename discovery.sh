#!/bin/sh

usage() {
	echo "Usage: $0 [-a | -p <regexp_pattern>] [-o <arp_options>] [-c] [-h]" 1>&2
	exit 1
}

# Parse arguments
while getopts "ap:o:ch" o; do
	case "${o}" in
		a)
			OUI=".+"
			ALL_FLAG="yes"
			;;
		p)
			if [ -z "$ALL_FLAG" ]; then
				OUI="${OPTARG}"
			fi
			PATTERN_FLAG="yes"
			;;
		o)
			OPTIONS="${OPTARG}"
			;;
		c)
			check_candidates="yes"
			;;
		h)
			usage
			;;
		*)
			usage
			;;
	esac
done

# Default values
if [ -z "$OUI" ]; then
	# Raspberry Pi OUIs pattern
	OUI="\bb8:27:eb|\bdc:a6:32|\be4:5f:01"
fi

if [ ! -z "$ALL_FLAG" ] && [ ! -z "$PATTERN_FLAG" ]; then
	echo "Warning: -a flag passed, key -p ignored" 1>&2
fi

if [ -z "$OPTIONS" ]; then
	# Arp-scanner arguments
	OPTIONS="--localnet --retry=3"
fi

echo "Run ARP-scanner..." 1>&2
scanned=$(arp-scan $OPTIONS |  tail -n +3 | tail -r | tail -n +3 | tail -r | grep -E "$OUI")
#scanned=$(cat test.file) # Debug

echo "Found devices:" 1>&2
#printf "$scanned" # Debug

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'       # No color (reset color)
MAXSIZE='20'       # Max whitespace padding to display hostname

# Only for -c key
default_user='pi'
default_pass='raspberry'

candidates=''
all_ips=''
while IFS= read -r line
do
	ip=$(echo $line | cut -f1 -d\ )
	if echo "$all_ips" | grep -q "$ip"
	then
		printf "${YELLOW}%-${MAXSIZE}s\t${line}${NC}\n" "Duplicate IP" 1>&2
	else 
		hostname=$(dig +short -x $ip)    # Resolve via PTR-records
		if [ -z "$hostname" ]
		then
			printf "${RED}%-${MAXSIZE}s\t${line}${NC}\n" "No PTR-record" 1>&2
			candidates+="$ip "
		else
			printf "${GREEN}%-${MAXSIZE}s\t${line}${NC}\n" "$hostname" 1>&2
		fi
		all_ips+="$ip "
	fi
done <<< "$scanned"

if [ ! -z "$check_candidates" ]; then
	printf '\n' 1>&2
	valid_candidates=''
	for candidate in $candidates
	do
		# Connect to host and try to log in
		timeout 3 nc -z $candidate 22 > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			sshpass -p "$default_pass" ssh -o "StrictHostKeyChecking=no" \
										-o "ServerAliveInterval=10" \
										-o "ConnectTimeout=3" \
										-o "ConnectionAttempts=3" \
										pi@${candidate} "uname -a" > /dev/null 2>&1
			if [ $? -eq 0 ]; then
				printf "Logged in successfully with default creds ($default_user:$default_pass) on ${GREEN}${candidate}${NC}\n" 1>&2
				valid_candidates+="$candidate "
			else
				printf "Failed to log in with default creds ($default_user:$default_pass) on ${RED}${candidate}${NC}\n" 1>&2
			fi
		else
			printf "Failed to connect 22 port on ${RED}${candidate}${NC}\n" 1>&2
		fi
	done

	if [ "$valid_candidates" != "" ]; then
		printf "\nPossible candidates for a new host found:\n" 1>&2
		echo $valid_candidates && echo
	else
		printf "\nNo possible candidates for a new host\n\n" 1>&2
	fi
fi
