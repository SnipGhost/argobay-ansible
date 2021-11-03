#!/bin/sh

usage() {
	echo "Usage: $0 NAME [-e <eth_ip>] [-w <wlan_ip>] [-s <service_host>] [-r] [-d] [-p] [-h]" 1>&2
	echo "-s to set dns server name (ansible inventory name)" 1>&2
	echo "-r to set wireless (.w) address as main (.i)" 1>&2
	echo "-d to delete ALL records for NAME" 1>&2
	echo "-p just print and shutup mode" 1>&2
	exit 1
}

if [ "$#" -lt 1 ]; then
    echo "NAME argument required!" 1>&2
	usage
fi
hostname=$1
shift

# Parse arguments
while getopts "e:w:s:rdph" o; do
	case "${o}" in
		e)
			e_ip_addr="${OPTARG}"
			;;
		w)
			w_ip_addr="${OPTARG}"
			;;
		s)
			service_host="${OPTARG}"
			service_flag="yes"
			;;
		r)
			reverse_flag="yes"
			;;
		d)
			delete_flag="yes"
			;;
		p)
			print_flag="yes"
			;;
		h)
			usage
			;;
		*)
			usage
			;;
	esac
done

if [ -z "$service_host" ]; then
	service_host="asuna"
fi

if [ -z "$delete_flag" ]; then
	# Check flags
	if [ -z "$reverse_flag" ]; then
		if [ -z "$e_ip_addr" ]; then
			echo "No eth ip address!" 1>&2
			exit 1
		fi
		i_ip_addr="$e_ip_addr"
	else
		if [ -z "$w_ip_addr" ]; then
			echo "No wlan ip address!" 1>&2
			exit 1
		fi
		i_ip_addr="$w_ip_addr"
	fi
	# Generate CREATE record commands
	cmd="/usr/bin/pdnsutil add-record i \"$hostname\" A 300 \"$i_ip_addr\""
	if [ ! -z "$e_ip_addr" ]; then
		cmd+=" && /usr/bin/pdnsutil add-record e \"$hostname\" A 300 \"$e_ip_addr\""
	fi
	if [ ! -z "$w_ip_addr" ]; then
		cmd+=" && /usr/bin/pdnsutil add-record w \"$hostname\" A 300 \"$w_ip_addr\""
	fi
	cmd+=" && /usr/bin/pdnsutil add-record argobay.ml \"haproxy_${hostname}\" CNAME 300 \"${hostname}.i.\""
else
	if [ ! -z "$e_ip_addr" ] || [ ! -z "$w_ip_addr" ] || [ ! -z "$reverse_flag" ]; then
		echo "Warning: Key -d passed so -e,-w,-r keys ignored" 1>&2
	fi
	# Generate DELETE record command
	cmd="/usr/bin/pdnsutil delete-rrset i \"$hostname\" A"
	cmd+=" && /usr/bin/pdnsutil delete-rrset e \"$hostname\" A"
	cmd+=" && /usr/bin/pdnsutil delete-rrset w \"$hostname\" A"
	cmd+=" && /usr/bin/pdnsutil delete-rrset argobay.ml \"haproxy_$hostname\" CNAME"
fi

if [ -z "$print_flag" ]; then
	ansible -mraw -a "$cmd" $service_host
else
	# "Just print and shutup" flag set
	if [ ! -z "$service_flag" ]; then
		echo "Warning: Key -p passed so -s key ignored" 1>&2
	fi
	echo $cmd
fi
