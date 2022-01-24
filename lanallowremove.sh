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

cont=`ipset list lanallow6 | wc -l`
for a in $(seq 9 1 $cont)
do
	now=`ipset list lanallow6 | sed -n ${a}p`
	if [ "`grep $now $workdir/allowlist`" == "" ]
	then
		ipset del lanallow6 $now
	fi
done

> $workdir/allowlist
