#!/bin/bash

workdir="/etc/lanloginserver"

cont=`ipset list lanallow | wc -l`
for a in $(seq 9 1 $cont)
do
	now=`ipset list lanallow | sed -n ${a}p`
	if [ "`grep $now $workdir/allowlist`" == "" ]
	then
		ipset del lanallow $now
	fi
done
> $workdir/allowlist
