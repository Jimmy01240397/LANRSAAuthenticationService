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
		-n)
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

workdir="/etc/lanloginserver"

if [ ! -d $workdir/private ]
then
	sudo mkdir $workdir/private
fi

sudo openssl genrsa -out $workdir/private/$name.key 2048
sudo openssl rsa -in $workdir/private/$name.key -pubout -out $workdir/allowkey/$name.pem

echo ""
echo ""
echo "Your private key is export to $workdir/private/$name.key, please send your private key to your mobile."
echo "Please type 'systemctl restart wifiallowweb@<wifiinterfacename>.service' to restart your service."
