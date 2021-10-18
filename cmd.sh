#!/bin/sh

if [ "$#" -lt 1 ] ||  [ "$#" -gt 2 ]; then
    echo "Usage: $0 COMMAND [HOSTS]";
	exit 1;
fi

if [ "$#" -eq 2 ]; then
	HOSTS=$3
else
	HOSTS="all"
fi

ansible -m raw -a "$1" "$HOSTS" --diff
