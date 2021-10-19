#!/bin/bash

argnum=$#
if [ $argnum -eq 0 ]
then
	echo "Missing arg..."
	exit 0
fi

name=""
for a in $(seq 1 1 $argnum)
do
	nowarg=$1
	case "$nowarg" in
		-h)
			echo "addnewuserkey.sh -n <userkeyname>"
			exit 0
			;;
		-i)
			shift
			name=$1
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

if [ "$name" = "" ]
then
        echo "Missing arg..."
        exit 0
fi

sudo mkdir /etc/wifiloginserver/private 2> /dev/null

sudo openssl genrsa -out /etc/wifiloginserver/private/$name.key 2048
sudo openssl rsa -in /etc/wifiloginserver/private/$name.key -pubout -out /etc/wifiloginserver/allowkey/$name.pem

echo "Your private key is export to /etc/wifiloginserver/private/$name.key, please send your private key to your mobile."
echo "Please type 'systemctl restart wifiallowweb@<wifiinterfacename>.service' to restart your service."
