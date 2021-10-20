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

ipset create lanallow hash:ip,mac
iptables -A INPUT -i $interface -p tcp -m tcp -m multiport --dports 443 -j ACCEPT
iptables -A INPUT -i $interface -p udp -m udp -m multiport --dports 53 -j ACCEPT
iptables -A INPUT -i $interface -m set ! --match-set lanallow src,src -j DROP
iptables -A FORWARD -i $interface -m set ! --match-set lanallow src,src -j DROP
iptables -A FORWARD -i $interface -m set --match-set lanallow src,src -j LOG --log-prefix "THIS IS IPTABLE LANRSA ALLOW!!!"
iptables -t nat -A PREROUTING -i $interface -p tcp -m tcp -m multiport --dports 443 -m set ! --match-set lanallow src,src -j DNAT --to $myip:443

. ./venv/bin/activate
python3 lanloginserver.py

iptables -D INPUT -i $interface -p tcp -m tcp -m multiport --dports 443 -j ACCEPT
iptables -D INPUT -i $interface -p udp -m udp -m multiport --dports 53 -j ACCEPT
iptables -D INPUT -i $interface -m set ! --match-set lanallow src,src -j DROP
iptables -D FORWARD -i $interface -m set ! --match-set lanallow src,src -j DROP
iptables -D FORWARD -i $interface -m set --match-set lanallow src,src -j LOG --log-prefix "THIS IS IPTABLE LANRSA ALLOW!!!"
iptables -t nat -D PREROUTING -i $interface -p tcp -m tcp -m multiport --dports 443 -m set ! --match-set lanallow src,src -j DNAT --to $myip:443
ipset destroy lanallow

> allowlist