# LANRSAAuthenticationService

It is a web site for router's LAN Network Authentication with RSA signature make by Debian 11. 

## Demo

![image](https://user-images.githubusercontent.com/57281249/137624898-3a2d96b5-78d3-486d-a2ae-c88e2642bc50.png)

## Install

Please make sure your server and client time is correct.

***Warning!!! This program will install iptables and ipset, and it will change your firewall rules.***

1. clone this repo and cd into LANRSAAuthenticationService.

```bash
git clone https://github.com/Jimmy01240397/LANRSAAuthenticationService
cd LANRSAAuthenticationService
```

2. run ``install.sh``

```bash
sh install.sh
```

3. request your certificate from ca (or you can just use self signed certificate.
4. put your server certificate and server private key in ``/etc/lanloginserver`` name to ``server.crt`` and ``server.key``.
```bash
cp cert.crt /etc/lanloginserver/server.crt
cp key.key /etc/lanloginserver/server.key
```

5. make private and public key with addnewuserkey.sh.

```bash
/etc/lanloginserver/addnewuserkey.sh -n <username>
```

6. send your private key from ``/etc/lanloginserver/private`` to your mobile.
7. change your interfaces in ``/etc/lanloginserver/config.yaml``.
8. you can change your iptables rules on setup in ``/etc/lanloginserver/iptablessetuplist.conf`` and iptables rules on stop in ``/etc/lanloginserver/iptablesstoplist.conf``.
9. enable and start your server

```bash
systemctl enable lanallowweb.service
systemctl start lanallowweb.service

#when you have add public key in allowkey or change config.yaml remember to restart the server
systemctl restart lanallowweb.service
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.
