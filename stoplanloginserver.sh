#!/bin/bash

workdir="/etc/lanloginserver"

bash $workdir/mkiptablesscript.sh down $workdir/iptablessetuplist.conf /tmp/iptablessetupdown.sh
bash $workdir/mkiptablesscript.sh up $workdir/iptablesstoplist.conf /tmp/iptablesstopup.sh

sudo bash /tmp/iptablessetupdown.sh
sudo bash /tmp/iptablesstopup.sh
rm /tmp/iptablessetupdown.sh
rm /tmp/iptablesstopup.sh

sleep 1

ipset destroy lanallow
ipset destroy lanallow6

> allowlist