# OpenVPN and OpenVPN WEB UI

Simple OpenVPN Server setup compatible with AMD64 and ARM64v8 servers. 
It does include 2 different Docker containers:
 - OpenVPN Back-End container (openvpn) and 
 - OpenVPN WEB UI Front-End container (openvpn-ui) for managing OpenVPN server.

### Run this image using a `docker-compose.yml` file

```yaml
---
version: "3.5"

services:
    openvpn:
       container_name: openvpn
       build: ./openvpn-docker
       # image: d3vilh/openvpn-server:latest
       privileged: true
       ports: 
          - "1194:1194/udp"
       environment:
           REQ_COUNTRY: UA
           REQ_PROVINCE: Kyiv
           REQ_CITY: Chayka
           REQ_ORG: CopyleftCertificateCo
           REQ_OU: ShantiShanti
           REQ_CN: MyOpenVPN
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
``` 
Alternatevly you can add OpenVPN-UI container for WEB UI:
```yaml
    openvpn-ui:
       container_name: openvpn-ui
       image: d3vilh/openvpn-ui:latest
       environment:
           - OPENVPN_ADMIN_USERNAME={{ ovpnui_user }}
           - OPENVPN_ADMIN_PASSWORD={{ ovpnui_password }}
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
    --mount type=bind,src=./openvpn-server/pki,dst=/etc/openvpn/pki \
    --mount type=bind,src=./openvpn-server/clients,dst=/etc/openvpn/clients \
    --mount type=bind,src=./openvpn-server/config,dst=/etc/openvpn/config \
    --mount type=bind,src=./openvpn-server/staticclients,dst=/etc/openvpn/staticclients \
    --mount type=bind,src=./openvpn-server/log,dst=/var/log/openvpn \
    --cap-add=NET_ADMIN \
    --restart=unless-stopped
    --privileged openvpn
```

Run the OpenVPN-UI image
```
docker run \
-v /home/pi/openvpn-server:/etc/openvpn \
-v /home/pi/openvpn-server/db:/opt/openvpn-gui/db \
-v /home/pi/openvpn-server/pki:/usr/share/easy-rsa/pki \
-e OPENVPN_ADMIN_USERNAME='admin' \
-e OPENVPN_ADMIN_PASSWORD='gagaZush' \
-p 8080:8080/tcp \
--privileged local/openvpn-ui
```

Most of documentation can be found in the [main README.md](https://github.com/d3vilh/raspberry-gateway) file, if you want to run it without anything else you'll have to edit the [dns-configuration](https://github.com/d3vilh/raspberry-gateway/blob/master/openvpn-server/config/server.conf#L20) (which currently points to the PiHole DNS Server) and
if you don't want to use a custom dns-resolve at all you may also want to comment out [this line](https://github.com/d3vilh/raspberry-gateway/blob/master/openvpn-server/config/server.conf#L39).