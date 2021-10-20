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

myip=`ip a | grep wlan0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | tail -n 1`

iptables -D INPUT -i $interface -p tcp -m tcp -m multiport --dports 443 -j ACCEPT
iptables -D INPUT -i $interface -p udp -m udp -m multiport --dports 53 -j ACCEPT
iptables -D INPUT -i $interface -m set ! --match-set wifiallow src,src -j DROP
iptables -D FORWARD -i $interface -m set ! --match-set wifiallow src,src -j DROP
iptables -D FORWARD -i $interface -m set --match-set wifiallow src,src -j LOG --log-prefix "THIS IS IPTABLE WLAN0!!!"
iptables -t nat -D PREROUTING -i $interface -p tcp -m tcp -m multiport --dports 443 -m set ! --match-set wifiallow src,src -j DNAT --to $myip:443
ipset destroy wifiallow

> allowlist