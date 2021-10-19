# WifiRSAAuthenticationService

It is a web site for Wifi Authentication with RSA signature make by Debian 11. Wifi hotspot is make by hostapt.

## Demo

![image](https://user-images.githubusercontent.com/57281249/137624898-3a2d96b5-78d3-486d-a2ae-c88e2642bc50.png)

## Install

1. clone this repo and cd into WifiRSAAuthenticationService.

```bash
git clone https://github.com/Jimmy01240397/WifiRSAAuthenticationService
cd WifiRSAAuthenticationService
```

2. run install.sh

```bash
./install.sh
```

3. request your certificate from ca (or you can just use self signed certificate
4. put your server certificate and server private key in /etc/wifiloginserver name to server.crt and server.key
```bash
cp cert.crt /etc/wifiloginserver/server.crt
cp key.key /etc/wifiloginserver/server.key
```

5. make private and public key with addnewuserkey.sh.

```bash
/etc/wifiloginserver/addnewuserkey.sh <username>
```

6. send your private key from /etc/wifiloginserver/private to your mobile.

7. enable and start your server

```bash
systemctl enable wifiallowweb@<wifiinterfacename>.service
systemctl start wifiallowweb@<wifiinterfacename>.service

#when you have add public key in allowkey remember to restart the server
systemctl restart wifiallowweb@<wifiinterfacename>.service
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.
