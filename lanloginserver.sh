#!/bin/bash

argnum=$#
if [ $argnum -eq 0 ]
then
	echo "Missing arg..."
	exit 0
fi


interface=""
for a in $(seq 1 1 $argnum)
do
	nowarg=$1
	case "$nowarg" in
		-h)
			echo "lanloginserver.sh -i <LANInterface>"
			exit 0
			;;
		-i)
			shift
			interface=$1
			;;
		*)
			if [ "$nowarg" = "" ]
			then
					break
			fi
			echo "bad arg..."
			exit 0
			;;
	esac
	shift
done

if [ "$interface" = "" ]
then
        echo "Missing arg..."
        exit 0
fi

workdir="/etc/lanloginserver"
myip=`ip a | grep $interface | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | tail -n 1`

echo "interface=$interface" > /tmp/iptableslan${interface}up.sh
echo "myip=$myip" >> /tmp/iptableslan${interface}up.sh

count=1
table=""
chain=""
for a in $(seq 1 1 $(wc -l < $workdir/iptablessetuplist))
do
	nowa=$(sed -n ${a}p $workdir/iptablessetuplist | awk '$1=$1')
        if [ "$nowa" != "" ]
        then
            case "$(echo "$nowa" | cut -c -1)" in
				\*)
					table="$(echo "$nowa" | cut -c 2-)"
					count=1
					;;
				:)
					chain="$(echo "$nowa" | cut -c 2-)"
					count=1
					;;
				\#)
					;;
				*)
					if [ "$table" != "" ] && [ "chain" != "" ]
					then
						echo "iptables -t $table -I $chain $count $nowa" >> /tmp/iptableslan${interface}up.sh
						((count++))
					fi
					;;
			esac
        fi
done

ipset create lanallow hash:ip,mac
sudo sh /tmp/iptableslan${interface}up.sh
rm /tmp/iptableslan${interface}up.sh

. ./venv/bin/activate
python3 lanloginserver.py
