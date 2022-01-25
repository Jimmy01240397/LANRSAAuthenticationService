#!/bin/bash

workdir="/etc/lanloginserver"

bash $workdir/mkiptablesscript.sh down $workdir/iptablesstoplist.conf /tmp/iptablesstopdown.sh
bash $workdir/mkiptablesscript.sh up $workdir/iptablessetuplist.conf /tmp/iptablessetupup.sh

authlayer="hash:ip"
if [ "$(yq e '.Layer2auth' $workdir/config.yaml)" == "true" ]
then
	authlayer="hash:ip,mac"
fi

ipset create lanallow $authlayer
ipset create lanallow6 $authlayer family inet6

sudo bash /tmp/iptablesstopdown.sh
sudo bash /tmp/iptablessetupup.sh
rm /tmp/iptablesstopdown.sh
rm /tmp/iptablessetupup.sh

. ./venv/bin/activate
gunicorn --certfile=server.crt --keyfile=server.key --bind [::]:443 lanloginserver:app
#python3 lanloginserver.py
