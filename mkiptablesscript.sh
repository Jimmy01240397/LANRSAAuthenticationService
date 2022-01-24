#!/bin/bash

if [ $argnum -lt 3 ]
then
	echo "mkiptablesscript.sh <up|down> <iptables conf file> <iptables script location>"
	exit 0
fi

workdir="/etc/lanloginserver"

upordown=$1
confdata=$2
iptablescript=$3

echo '#!/bin/bash' > $iptablescript
echo ". $workdir/iptablescripthead.sh" >> $iptablescript

count=1
ipv="ip"
table=""
chain=""
for a in $(seq 1 1 $(wc -l < $confdata))
do
	nowa=$(sed -n ${a}p $confdata | awk '$1=$1')
	if [ "$nowa" != "" ]
	then
		case "$(echo "$nowa" | cut -c -1)" in
			\*)
				table="$(echo "$nowa" | cut -c 2-)"
				count=1
				;;
			@)
				ipv="$(echo "$nowa" | cut -c 2-)"
				count=1
				;;
			:)
				chain="$(echo "$nowa" | cut -c 2-)"
				count=1
				;;
			=)
				count="$(echo "$nowa" | cut -c 2-)"
				;;
			+)
				count="$(($count + $(echo "$nowa" | cut -c 2-)))"
				;;
			_)
				count="$(($count - $(echo "$nowa" | cut -c 2-)))"
				;;
			\#)
				;;
			*)
				if [ "$table" != "" ] && [ "chain" != "" ]
				then
					if [ "$upordown" == "up" ]
					then
						echo "${ipv}tables -t $table -I $chain $count $nowa" >> $iptablescript
					elif [ "$upordown" == "down" ]
						echo "${ipv}tables -t $table -D $chain $nowa" >> $iptablescript
					fi
					((count++))
				fi
				;;
		esac
	fi
done
