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
			echo "wifiloginserver.sh -i <WifiInterface>"
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

iptables -D INPUT -i $interface -p tcp -m tcp -m multiport --dports 443 -j ACCEPT
iptables -D INPUT -i $interface -p udp -m udp -m multiport --dports 53 -j ACCEPT
iptables -D INPUT -i $interface -m set ! --match-set wifiallow src,src -j DROP
iptables -D FORWARD -i $interface -m set ! --match-set wifiallow src,src -j DROP
iptables -D FORWARD -i $interface -m set --match-set wifiallow src,src -j LOG --log-prefix "THIS IS IPTABLE WLAN0!!!"
ipset destroy wifiallow
