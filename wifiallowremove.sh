#!/bin/bash

cont=`ipset list wifiallow | wc -l`
for a in $(seq 9 1 $cont)
do
	now=`ipset list wifiallow | sed -n ${a}p`
	if [ "`grep $now /etc/wifiloginserver/allowlist`" == "" ]
	then
		ipset del wifiallow $now
	fi
done
> /etc/wifiloginserver/allowlist
