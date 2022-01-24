#!/bin/bash


workdir="/etc/lanloginserver"

echo '#!/bin/bash' > /tmp/iptablessetupdown.sh
echo '#!/bin/bash' > /tmp/iptablesstopup.sh

bash $workdir/mkiptablesscript.sh down $workdir/iptablessetuplist.conf /tmp/iptablessetupdown.sh
bash $workdir/mkiptablesscript.sh up $workdir/iptablesstoplist.conf /tmp/iptablesstopup.sh

sudo sh /tmp/iptablessetupdown.sh
sudo sh /tmp/iptablesstopup.sh
rm /tmp/iptablessetupdown.sh
rm /tmp/iptablesstopup.sh

sleep 1

ipset destroy lanallow

> allowlist