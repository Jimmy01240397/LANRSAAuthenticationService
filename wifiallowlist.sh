#!/bin/bash

splitinspace()
{
	for a in $(cat $1)
	do
		echo $a
	done
}

allline=`grep "THIS IS IPTABLE WLAN0"\!\!\! /var/log/kern.log`
nowline=`echo "$allline" | tail -n 1`
nowcont=`echo "$allline" | wc -l`
maxcont=$nowcont
while :
do
	allline=`grep "THIS IS IPTABLE WLAN0"\!\!\! /var/log/kern.log`
	maxcont=`echo "$allline" | wc -l`

	if [ "$(($maxcont - $nowcont))" -lt 0 ] 
	then
		for a in $(seq 1 1 $($maxcont))
		do
			sip=`echo "$allline" | tac | sed -n ${a}p | splitinspace | grep SRC | cut -c 5-`
			mac=`echo "$allline" | tac | sed -n ${a}p | splitinspace | grep MAC | cut -c 23-39 | tr [:lower:] [:upper:]`
			if [ "`grep $sip,$mac /etc/wifiloginserver/allowlist`" == "" ]
			then
				echo "$sip,$mac" >> /etc/wifiloginserver/allowlist
			fi
		done
		#echo dead
	else
		for a in $(seq $(($maxcont - $nowcont)) -1 1)
		do
			sip=`echo "$allline" | tac | sed -n ${a}p | splitinspace | grep SRC | cut -c 5-`
			mac=`echo "$allline" | tac | sed -n ${a}p | splitinspace | grep MAC | cut -c 23-39 | tr [:lower:] [:upper:]`
			if [ "`grep $sip,$mac /etc/wifiloginserver/allowlist`" == "" ]
			then
				echo "$sip,$mac" >> /etc/wifiloginserver/allowlist
			fi
		done
	fi
	nowcont=$maxcont
	sleep 0.1
done	
