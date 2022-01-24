#!/bin/bash

workdir="/etc/lanloginserver"

echo '#!/bin/bash' > /tmp/iptablessetupdown.sh
echo '#!/bin/bash' > /tmp/iptablessetupup.sh

bash $workdir/mkiptablesscript.sh down $workdir/iptablessetuplist.conf /tmp/iptablessetupdown.sh
bash $workdir/mkiptablesscript.sh up $workdir/iptablessetuplist.conf /tmp/iptablessetupup.sh

sudo sh /tmp/iptablessetupdown.sh
sudo sh /tmp/iptablessetupup.sh
rm /tmp/iptablessetupdown.sh
rm /tmp/iptablessetupup.sh
