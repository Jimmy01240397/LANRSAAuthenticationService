#!/bin/bash

set -e
UBUNTU=false
DEBIAN=false
if [ "$(uname)" = "Linux" ]
then
	#LINUX=1
	if type apt-get
	then
		OS_ID=$(lsb_release -is)
		if [ "$OS_ID" = "Debian" ]; then
			DEBIAN=true
		else
			UBUNTU=true
		fi
	fi
fi

UBUNTU_PRE_2004=false
if $UBUNTU
then
	LSB_RELEASE=$(lsb_release -rs)
	# Mint 20.04 repsonds with 20 here so 20 instead of 20.04
	UBUNTU_PRE_2004=$(( $LSB_RELEASE<20 ))
	UBUNTU_2100=$(( $LSB_RELEASE>=21 ))
fi

if [ "$(uname)" = "Linux" ]
then
	#LINUX=1
	if [ "$UBUNTU" = "true" ] && [ "$UBUNTU_PRE_2004" = "1" ]
	then
		# Ubuntu
		echo "Installing on Ubuntu pre 20.04 LTS."
		sudo apt-get update
		sudo apt-get install -y python3.7-venv python3.7-distutils
	elif [ "$UBUNTU" = "true" ] && [ "$UBUNTU_PRE_2004" = "0" ] && [ "$UBUNTU_2100" = "0" ]
	then
		echo "Installing on Ubuntu 20.04 LTS."
		sudo apt-get update
		sudo apt-get install -y python3.8-venv python3-distutils
	elif [ "$UBUNTU" = "true" ] && [ "$UBUNTU_2100" = "1" ]
	then
		echo "Installing on Ubuntu 21.04 or newer."
		sudo apt-get update
		sudo apt-get install -y python3.9-venv python3-distutils
	elif [ "$DEBIAN" = "true" ]
	then
		echo "Installing on Debian."
		sudo apt-get update
		sudo apt-get install -y python3-venv
	else
		echo "os not support"
		exit 0
	fi
else
	echo "os not support"
    exit 0
fi

find_python() {
	set +e
	unset BEST_VERSION
	for V in 39 3.9 38 3.8 37 3.7 3; do
		if which python$V >/dev/null; then
			if [ "$BEST_VERSION" = "" ]; then
				BEST_VERSION=$V
			fi
		fi
	done
	echo $BEST_VERSION
	set -e
}

if [ "$INSTALL_PYTHON_VERSION" = "" ]; then
	INSTALL_PYTHON_VERSION=$(find_python)
fi

INSTALL_PYTHON_PATH=python${INSTALL_PYTHON_VERSION:-3.7}

echo "Python version is $INSTALL_PYTHON_VERSION"


sudo mkdir /etc/wifiloginserver 2> /dev/null
sudo mkdir /etc/wifiloginserver/allowkey 2> /dev/null

sudo cp -r {allowlist,addnewuserkey.sh,wifiallowlist.sh,wifiallowremove.sh,stopwifiloginserver.sh,wifiloginserver.sh,wifiloginserver.py} /etc/wifiloginserver/
sudo chmod +x /etc/wifiloginserver/{addnewuserkey.sh,wifiallowlist.sh,wifiallowremove.sh,stopwifiloginserver.sh,wifiloginserver.sh}
sudo cp /etc/ssl/private/ssl-cert-snakeoil.key /etc/wifiloginserver/server.key
sudo cp /etc/ssl/certs/ssl-cert-snakeoil.pem /etc/wifiloginserver/server.crt
sudo cp iptableswlanlog.conf /etc/rsyslog.d/iptableswlanlog.conf
sudo cp wifiallowweb@.service /lib/systemd/system/wifiallowweb@.service

sudo mkdir /var
sudo mkdir /var/www
sudo mkdir /var/www/wifilogin

sudo cp -r wifilogin/* /var/www/wifilogin/

cd /etc/wifiloginserver

$INSTALL_PYTHON_PATH -m venv venv
. ./venv/bin/activate
python -m pip install -r requirements.txt
deactivate


sudo apt-get install -y iptables ipset

echo "please request your certificate from ca (or you can just use self signed certificate and put certificate to /etc/wifiloginserver/server.crt private to /etc/wifiloginserver/server.key ."
echo "Then you can use systemctl start wifiallowweb@<wifiinterfacename>.service"
echo "If you want to auto run on boot please type 'systemctl enable wifiallowweb@<wifiinterfacename>.service'"
