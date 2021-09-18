#!/bin/bash

splitinspace()
{
	for a in $(cat $1)
	do
		echo $a
	done
}
 
nowcont="`wc -l < /var/log/iptableswlan0`"
while :
do
	allline=`cat /var/log/iptableswlan0`
	maxcont=`echo "$allline" | wc -l`
	
	if [ "$(($maxcont - $nowcont))" -lt 0 ] 
	then
		for a in $(seq 1 1 $($maxcont))
		do
			sip=`echo "$allline" | sed -n ${a}p | splitinspace | grep SRC | cut -c 5-`
			mac=`echo "$allline" | sed -n ${a}p | splitinspace | grep MAC | cut -c 23-39 | tr [:lower:] [:upper:]`
			if [ "`grep $sip,$mac /etc/wifiloginserver/allowlist`" == "" ]
			then
				echo "$sip,$mac" >> /etc/wifiloginserver/allowlist
			fi
		done
	else
		(( nowcont++ ))

		for a in $(seq $nowcont 1 $maxcont)
		do
			sip=`echo "$allline" | sed -n ${a}p | splitinspace | grep SRC | cut -c 5-`
			mac=`echo "$allline" | sed -n ${a}p | splitinspace | grep MAC | cut -c 23-39 | tr [:lower:] [:upper:]`
			if [ "`grep $sip,$mac /etc/wifiloginserver/allowlist`" == "" ]
			then
				echo "$sip,$mac" >> /etc/wifiloginserver/allowlist
			fi
		done
	fi
	nowcont=$maxcont
	sleep 0.1
done	
