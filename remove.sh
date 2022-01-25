#!/bin/bash

sudo systemctl stop lanallowweb.service
sudo systemctl disable lanallowweb.service

sudo rm /etc/rsyslog.d/iptableslanlog.conf
sudo rm /etc/cron.d/iptableslancron
sudo rm /lib/systemd/system/lanallowweb.service
sudo rm /lib/systemd/system/lanallowweb-failure.service

sudo /etc/init.d/rsyslog restart
sudo /etc/init.d/cron reload
sudo /etc/init.d/cron restart


for filename in $(ls lanlogin)
do
	sudo rm -r /var/www/lanlogin/$filename
done

for filename in allowlist addnewuserkey.sh lanallowlist.sh lanallowremove.sh updatelanloginiptables.sh stoplanloginserver.sh lanloginserver.sh lanloginserver.py iptablescripthead.sh mkiptablesscript.sh requirements.txt doonloginandlogout.py iptablessetuplist.conf iptablesstoplist.conf config.yaml venv __pycache__
do
	sudo rm -r /etc/lanloginserver/$filename
done

sudo mv /etc/lanloginserver/server.key .
sudo mv /etc/lanloginserver/server.crt .
sudo mv /etc/lanloginserver/allowkey .
sudo mv /etc/lanloginserver/private .

if [ "`ls /var/www/lanlogin`" = "" ]
then
	rm -r /var/www/lanlogin
fi

if [ "`ls /etc/lanloginserver`" = "" ]
then
	rm -r /etc/lanloginserver
fi

echo ""
echo ""
echo "LAN RSA Authentication Service remove.sh complete."

for filename in server.key server.crt allowkey private
do
	echo "Your ${filename} is at $(pwd)/${filename}."
done

echo "If you don't need then, please delete then."
