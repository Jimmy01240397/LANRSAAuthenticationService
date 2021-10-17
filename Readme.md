# WifiRSAAuthenticationService

It is a web site for Wifi Authentication with RSA signature make by Debian 11. wifi hotspot is make by hostapt

## Demo

![image](https://user-images.githubusercontent.com/57281249/137624849-e8b3e06a-6c62-4eeb-adc9-6447e11f2be4.png)

## Install

1. clone this repo and cd into WifiRSAAuthenticationService.

```bash
git clone https://github.com/Jimmy01240397/WifiRSAAuthenticationService
cd WifiRSAAuthenticationService
```

1. move wifilogn dir to /var/www.

```bash
mv wifilogin /var/www
```

1. make private and public key with openssl.

```bash
openssl genrsa -out client-private.key 2048
openssl rsa -in client-private.key -pubout -out client.pem
```

1. copy your public key to allowkey and send your private key to your mobile.

```bash
cp client.pem allowkey/
```

1. set up iptables rules according to the file "rules.v4" 

```bash
# or you can just 
iptables-restore rules.v4
# to set up the rules
```

1. set up iptables log config **remember fix your work dir in config (for me is /etc/WifiRSAAuthenticationService**

```bash
mv iptableswlanlog.conf /etc/rsyslog.d/iptableswlanlog.conf
```

1. request your certificate from ca (or you can just use self signed certificate
2. put your server certificate and server private in dir name to server.crt and server.key

```bash
cp cert.crt server.crt
cp key.key server.key
```

1. **fix your work dir in wifiallowlist.sh and wifiallowremove.sh  (for me is /etc/WifiRSAAuthenticationService**
2. move wifiallowweb.service to /lib/systemd/system/wifiallowweb.service **remember fix your work dir in wifiallowweb.service (for me is /etc/WifiRSAAuthenticationService**

```bash
mv wifiallowweb.service /lib/systemd/system/wifiallowweb.service
```

1. enable and start your server

```bash
systemctl enable wifiallowweb.service
systemctl start wifiallowweb.service

#when you have add public key in allowkey remember to restart the server
systemctl restart wifiallowweb.service
```
