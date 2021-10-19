#!/bin/bash

splitinspace()
{
	for a in $(cat $1)
	do
		echo $a
	done
}

workdir="/etc/wifiloginserver"

sip=`echo "$1" | splitinspace | grep SRC | cut -c 5-`
mac=`echo "$1" | splitinspace | grep MAC | cut -c 23-39 | tr [:lower:] [:upper:]`
if [ "`grep $sip,$mac $workdir/allowlist`" == "" ]
then
	echo "$sip,$mac" >> $workdir/allowlist
fi
