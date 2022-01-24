#!/bin/bash

splitinspace()
{
	for a in $(cat $1)
	do
		echo $a
	done
}

workdir="/etc/lanloginserver"

sip=`echo "$1" | splitinspace | grep SRC | cut -c 5-`
data="$sip"
if [ "$(yq e '.Layer2auth' $workdir/config.yaml)" == "true" ]
then
	mac=`echo "$1" | splitinspace | grep MAC | cut -c 23-39 | tr [:lower:] [:upper:]`
	data="$sip,$mac"
fi

if [ "`grep $data $workdir/allowlist`" == "" ]
then
	echo "$data" >> $workdir/allowlist
fi
