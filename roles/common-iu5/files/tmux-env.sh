#!/bin/sh

usage() {
	echo "Usage: $0 [-s <session_name>] [-n <username>] [-i <hosts>] [-f] [-h]" 1>&2
	exit 1
}

kill_session() {
	echo "Kill session '$session'"
	tmux kill-session -t $session
}

create_session() {
	echo "Create new session '$session'"
	first=$(echo $inventory | tr -s ' ' | cut -f1 -d\ )
	if [ "$first" = "localhost" ]; then
		tmux new-session -d -s $session -n "$(hostname)"
	else
		tmux new-session -d -s $session -n "$first" "ssh $name@$first"
	fi
	for host in $(echo $inventory | tr -s ' ' | cut -f2- -d\ ); do
		if [ "$host" = "localhost" ]; then
			tmux new-window -t ${session}: -n "$(hostname)"
		else
			tmux new-window -t ${session}: -n "$host" "ssh $name@$host"
		fi
	done
	tmux select-window -t ${session}:0
}

# Parse arguments
while getopts "s:n:i:fh" o; do
	case "${o}" in
		s)
			session="${OPTARG}"
			;;
		n)
			name="${OPTARG}"
			;;
		i)
			inventory="${OPTARG}"
			unique_inventory=1
			;;
		f)
			force_create=1
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
if [ -z "$session" ]; then
	session="cluster"
fi
if [ -z "$name" ]; then
	name=$(whoami)
fi
if [ -z "$inventory" ]; then
	inventory="localhost"
fi

# Check if the session is already exists
tmux has-session -t $session 2>/dev/null
has_session_rc=$?

# Kill session if flag "force" is passed
if [ $has_session_rc -eq 0 ] && ! [ -z $force_create ]; then
	kill_session
	has_session_rc=1
fi

# Set up new session if not exists
if [ $has_session_rc != 0 ]; then
	create_session
	new_session_created=1
fi

# Print warning for inventory argument
if [ -z "$new_session_created" ] && ! [ -z "$unique_inventory" ]; then
	echo "The session has already running, the 'inventory' argument will be ignored!"
fi

# And attach to session
tmux attach-session -t "$session"
