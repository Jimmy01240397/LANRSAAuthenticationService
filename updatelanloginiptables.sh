#!/bin/bash

workdir="/etc/lanloginserver"

bash $workdir/mkiptablesscript.sh down $workdir/iptablessetuplist.conf /tmp/iptablessetupdown.sh
bash $workdir/mkiptablesscript.sh up $workdir/iptablessetuplist.conf /tmp/iptablessetupup.sh

sudo bash /tmp/iptablessetupdown.sh
sudo bash /tmp/iptablessetupup.sh
rm /tmp/iptablessetupdown.sh
rm /tmp/iptablessetupup.sh
