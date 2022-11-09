# OpenVPN and OpenVPN WEB UI

There is already an existing docker-image for openvpn created by [kylemanna/docker-openvpn](https://github.com/kylemanna/docker-openvpn) - With over [216](https://github.com/kylemanna/docker-openvpn/issues) issues,
[40](https://github.com/kylemanna/docker-openvpn/pulls) open PR's and last commit done in March 2020 I decided to tread this image as not maintained anymore, also It was a good way for me to make myself more familiar with building and setting up docker iamges so that's why I created my own.

Most of its documentation can be found in the [root](https://github.com/d3vilh/raspberry-gateway) directory, if you want to run it without anything else you'll have to edit the [dns-configuration](https://github.com/d3vilh/raspberry-gateway/blob/master/openvpn/config/server.conf#L20) (which currently points to the PiHole DNS Server) and
if you don't want to use a custom dns-resolve at all you may also want to comment out [this line](https://github.com/d3vilh/raspberry-gateway/blob/master/openvpn/config/server.conf#L39).

### Run this image using a `docker-compose.yml` file

```yaml
---
version: "3.5"

services:
    openvpn:
       container_name: openvpn
       build: ./openvpn-docker
       privileged: true
       ports: 
          - "1194:1194/udp"
       environment:
           - REQ_COUNTRY: UA
           - REQ_PROVINCE: Kyiv
           - REQ_CITY: Chayka
           - REQ_ORG: CopyleftCertificateCo
           - REQ_OU: ShantiShanti
           - REQ_CN: MyOpenVPN
       volumes:
           - ./pki:/etc/openvpn/pki
           - ./clients:/etc/openvpn/clients
           - ./config:/etc/openvpn/config
           - ./staticclients:/etc/openvpn/staticclients
           - ./log:/var/log/openvpn
       cap_add:
           - NET_ADMIN
       restart: always
       depends_on:
           - "openvpn-ui"

    openvpn-ui:
       container_name: openvpn-ui
       image: d3vilh/openvpn-ui-arm32v7:latest
       environment:
           - OPENVPN_ADMIN_USERNAME='admin'
           - OPENVPN_ADMIN_PASSWORD='gagaZush'
       privileged: true
       ports:
           - "8080:8080/tcp"
       volumes:
           - ./:/etc/openvpn
           - ./db:/opt/openvpn-gui/db
           - ./pki:/usr/share/easy-rsa/pki
       restart: always
```

### Run this image using the Docker itself

First, build the images:
```sh
sudo docker build -t openvpn .
```

Run the OpenVPN image:
```sh
sudo docker run openvpn \
    --expose 1194:1194/udp \
    --mount type=bind,src=./openvpn/pki,dst=/etc/openvpn/pki \
    --mount type=bind,src=./openvpn/clients,dst=/etc/openvpn/clients \
    --mount type=bind,src=./openvpn/config,dst=/etc/openvpn/config \
    --mount type=bind,src=./openvpn/staticclients,dst=/etc/openvpn/staticclients \
    --mount type=bind,src=./openvpn/log,dst=/var/log/openvpn \
    --cap-add=NET_ADMIN \
    --restart=unless-stopped
    --privileged openvpn
```

Run the OpenVPN-UI image
```
docker run \
-v /home/pi/openvpn:/etc/openvpn \
-v /home/pi/openvpn/db:/opt/openvpn-gui/db \
-v /home/pi/openvpn/pki:/usr/share/easy-rsa/pki \
-e OPENVPN_ADMIN_USERNAME='admin' \
-e OPENVPN_ADMIN_PASSWORD='gagaZush' \
-p 8080:8080/tcp \
--privileged local/openvpn-ui
```

[**OpenVPN**](https://openvpn.net) as a server and **OpenVPN-web-ui** as a WEB UI screenshots:

<img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OpenVPN-UI-Login.png" alt="OpenVPN-UI Login screen" width="1000" border="1" />

<img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OpenVPN-UI-Home.png" alt="OpenVPN-UI Home screen" width="1000" border="1" />

<img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OpenVPN-UI-Certs.png" alt="OpenVPN-UI Certificates screen" width="1000" border="1" />

<img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OpenVPN-UI-Logs.png" alt="OpenVPN-UI Logs screen" width="1000" border="1" />

<img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OpenVPN-UI-Config.png" alt="OpenVPN-UI Configuration screen" width="1000" border="1" />

<img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OpenVPN-UI-Server-config.png" alt="OpenVPN-UI Server Configuration screen" width="1000" border="1" />

<img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OpenVPN-UI-Profile.png" alt="OpenVPN-UI User Profile" width="1000" border="1" />

## Configuration

**OpenVPN WEB UI** can be accessed on own port (*e.g. http://localhost:8080 , change `localhost` to your Raspberry host ip/name*), the default user and password is `admin/gagaZush` preconfigured in `config.yml` which you supposed to [set in](https://github.com/d3vilh/raspberry-gateway/blob/master/example.config.yml#L28) `ovpnui_user` & `ovpnui_password` vars, just before the installation.

The volume container will be inicialized by using the official OpenVPN `openvpn_openvpn` image with included scripts to automatically generate everything you need  on the first run:
 - Diffie-Hellman parameters
 - an EasyRSA CA key and certificate
 - a new private key
 - a self-certificate matching the private key for the OpenVPN server
 - a TLS auth key from HMAC security

This setup use `tun` mode, because it works on the widest range of devices. tap mode, for instance, does not work on Android, except if the device is rooted.

The topology used is `subnet`, because it works on the widest range of OS. p2p, for instance, does not work on Windows.

The UDP server uses `10.0.70.0/24` for dynamic clients by default, because I have a grey cat.

The server config [specifies](https://github.com/d3vilh/raspberry-gateway/blob/master/openvpn/config/server.conf#L39) `push redirect-gateway def1 bypass-dhcp`, meaning that after establishing the VPN connection, all traffic will go through the VPN. This might cause problems if you use local DNS recursors which are not directly reachable, since you will try to reach them through the VPN and they might not answer to you. If that happens, use public DNS resolvers like those of OpenDNS (`208.67.222.222` and `208.67.220.220`) or Google (`8.8.4.4` and `8.8.8.8`).

If you wish to use your local Pi-Hole as a DNS server (the one which comes with this setup), you have to modify a [dns-configuration](https://github.com/d3vilh/raspberry-gateway/blob/master/openvpn/config/server.conf#L20) with your local Pi-Hole IP address.

### Generating .OVPN client profiles

Before client cert. generation you need to update the external IP address to your OpenVPN server in OVPN-UI GUI.

For this go to `"Configuration > Settings"`:

<img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OVPN_ext_serv_ip1.png" alt="Configuration > Settings" width="350" border="1" />

And then update `"Server Address (external)"` field with your external Internet IP. Then go to `"Certificates"`, enter new VPN client name in the field at the page below and press `"Create"` to generate new Client certificate:

<img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OVPN_ext_serv_ip2.png" alt="Server Address" width="350" border="1" />  <img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OVPN_New_Client.png" alt="Create Certificate" width="350" border="1" />

To download .OVPN client configuration file, press on the `Client Name` you just created:

<img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OVPN_New_Client_download.png" alt="download OVPN" width="350" border="1" />

If you use NAT and different port for all the external connections on your network router, you may need to change server port in .OVPN file. For that, just open it in any text editor (emax?) and update `1194` port with the desired one in this line: `remote 178.248.232.12 1194 udp`.

Install [Official OpenVPN client](https://openvpn.net/vpn-client/) to your client device.

Deliver .OVPN profile to the client device and import it as a FILE, then connect with new profile to enjoy your free VPN:

<img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OVPN_Palm_import.png" alt="PalmTX Import" width="350" border="1" /> <img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OVPN_Palm_connected.png" alt="PalmTX Connected" width="350" border="1" />

### Alternative CLI way to generate .OVPN profiles

Execute following command. Password as second argument is optional:
```shell
sudo docker exec openvpn bash /opt/app/bin/genclient.sh <name> <?password?>
```

You can find you .ovpn file under `/openvpn/clients/<name>.ovpn`, make sure to check and modify the `remote ip-address`, `port` and `protocol`.

### Revoking .OVPN profiles

If you would like to prevent client to use yor VPN connection, you have to revoke client certificate and restart the OpenVPN daemon.

Revoking of old .OVPN files is not availabe via the GUI and you have to deal with it via the CLI by running following:

```shell
sudo docker exec openvpn bash /opt/app/bin/rmclient.sh <clientname>
```

Revoked certificates won't kill active connections, you'll have to restart the service if you want the user to immediately disconnect. It can be done via Portainer GUI or CLI:
```shell
sudo docker-compose restart openvpn
```

All the Server and client configuration locates in Dockerfile volume and can be easly tuned. Here are tree of volume content:

```shell
|-- clients
|   |-- your_client1.ovpn
|-- config
|   |-- client.conf
|   |-- easy-rsa.vars
|   |-- server.conf
|-- db
|   |-- data.db //OpenVPN UI DB
|-- log
|   |-- openvpn.log
|-- pki
|   |-- ca.crt
|   |-- certs_by_serial
|   |   |-- your_client1_serial.pem
|   |-- crl.pem
|   |-- dh.pem
|   |-- index.txt
|   |-- ipp.txt
|   |-- issued
|   |   |-- server.crt
|   |   |-- your_client1.crt
|   |-- openssl-easyrsa.cnf
|   |-- private
|   |   |-- ca.key
|   |   |-- your_client1.key
|   |   |-- server.key
|   |-- renewed
|   |   |-- certs_by_serial
|   |   |-- private_by_serial
|   |   |-- reqs_by_serial
|   |-- reqs
|   |   |-- server.req
|   |   |-- your_client1.req
|   |-- revoked
|   |   |-- certs_by_serial
|   |   |-- private_by_serial
|   |   |-- reqs_by_serial
|   |-- safessl-easyrsa.cnf
|   |-- serial
|   |-- ta.key
|-- staticclients
```
