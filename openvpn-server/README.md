# OpenVPN and OpenVPN WEB UI

Most of documentation can be found in the [main README.md](https://github.com/d3vilh/raspberry-gateway) file, if you want to run it without anything else you'll have to edit the [dns-configuration](https://github.com/d3vilh/raspberry-gateway/blob/master/openvpn-server/config/server.conf#L20) (which currently points to the PiHole DNS Server) and
if you don't want to use a custom dns-resolve at all you may also want to comment out [this line](https://github.com/d3vilh/raspberry-gateway/blob/master/openvpn-server/config/server.conf#L39).

## Docker and Docker compose
[**HERE**](https://github.com/d3vilh/raspberry-gateway/blob/master/openvpn-server/README.md) you can find all the the **Docker** and **Docker-compose** instructions, volumes and enviroment variables defifintion.

## Configuration
**OpenVPN WEB UI** can be accessed on own port (*e.g. `http://localhost:8080` , change `localhost` to your Raspberry host ip/name*), the default user and password is `admin/gagaZush` preconfigured in `config.yml` which you supposed to [set in](https://github.com/d3vilh/raspberry-gateway/blob/master/example.config.yml#L25) `ovpnui_user` & `ovpnui_password` vars, just before the installation.

The volume container will be inicialized by using the official OpenVPN `openvpn_openvpn` image with included scripts to automatically generate everything you need  on the first run:
 - Diffie-Hellman parameters
 - an EasyRSA CA key and certificate
 - a new private key
 - a self-certificate matching the private key for the OpenVPN server
 - a TLS auth key from HMAC security

This setup use `tun` mode, because it works on the widest range of devices. tap mode, for instance, does not work on Android, except if the device is rooted.

The topology used is `subnet`, because it works on the widest range of OS. p2p, for instance, does not work on Windows.

The server config [specifies](https://github.com/d3vilh/raspberry-gateway/blob/master/openvpn-server/config/server.conf#L34) `push redirect-gateway def1 bypass-dhcp`, meaning that after establishing the VPN connection, all traffic will go through the VPN. This might cause problems if you use local DNS recursors which are not directly reachable, since you will try to reach them through the VPN and they might not answer to you. If that happens, use public DNS resolvers like those of OpenDNS (`208.67.222.222` and `208.67.220.220`) or Google (`8.8.4.4` and `8.8.8.8`).

If you wish to use your local Pi-Hole as a DNS server (the one which comes with this setup), you have to modify a [dns-configuration](https://github.com/d3vilh/raspberry-gateway/blob/master/openvpn-server/config/server.conf#L20) with your local Pi-Hole IP address.

### OpenVPN client subnets. Guest and Home users
[Raspberry-Gateway](https://github.com/d3vilh/raspberry-gateway/) OpenVPN server uses `10.0.70.0/24` **"Trusted"** subnet for dynamic clients by default and all the clients connected by default will have full access to your Home network, as well as your home Internet.
However you can be desired to share VPN access with your friends and restrict access to your **"Home network"** for them, but allow to use Internet connection over your VPN. This type of guest clients needs to live in special **"Guest users"** subnet - `10.0.71.0/24`:

<p align="center">
<img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OVPN_VLANs.png" alt="OpenVPN Subnets" width="700" border="1" />
</p>

* **"Trusted"** subnet is `ovpn_trusted_subnet` in [config.yml](https://github.com/d3vilh/raspberry-gateway/blob/master/example.config.yml#L80) and `TRUST_SUB` var in [docker-compose](https://github.com/d3vilh/raspberry-gateway/tree/master/openvpn-server/openvpn-docker#run-this-image-using-a-docker-composeyml-file) file.
* **"Guest"** subnet is `ovpn_guest_subnet` in [config.yml](https://github.com/d3vilh/raspberry-gateway/blob/master/example.config.yml#L81) and `GUEST_SUB` var in [docker-compose](https://github.com/d3vilh/raspberry-gateway/tree/master/openvpn-server/openvpn-docker#run-this-image-using-a-docker-composeyml-file) file.
* **"Home"** subnet is `ovpn_home_subnet` in [config.yml](https://github.com/d3vilh/raspberry-gateway/blob/master/example.config.yml#L82) and `HOME_SUB` vsr in [docker-compose](https://github.com/d3vilh/raspberry-gateway/tree/master/openvpn-server/openvpn-docker#run-this-image-using-a-docker-composeyml-file) file.

To assign desired subnet policy to the specific client, you have to define static IP address for this client when you'll be generate new .OVPN profile.
To do that, just enter `"Static IP (optional)"` field in `"Certificates"` page and press `"Create"` button.

You can apply optional Firewall rules for the OpenVPN server container in `~/openvpn-server/fw-rules.sh` file, which will be executed on the container start. Here is example to blocking traffic between 2 "Trusted" subnet clients:
```shell
~/openvpn-server $ cat fw-rules.sh
iptables -A FORWARD -s 10.0.70.88 -d 10.0.70.77 -j DROP
iptables -A FORWARD -d 10.0.70.77 -s 10.0.70.88 -j DROP
```

> Keep in mind, by default, all the clients got **"Trusted"** subnet and have full access, so you don't need to specifically configure static IP for your own devices. 


### OpenVPN Pstree structure
All the Server and Client configuration located in Docker volume and can be easely tuned. Here are tree of volume content:

```shell
|-- clients
|   |-- your_client1.ovpn
|-- config
|   |-- client.conf
|   |-- easy-rsa.vars
|   |-- server.conf
|-- db
|   |-- data.db //Optional OpenVPN UI DB
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
|-- staticclients //Directory where stored all the satic clients configuration
```

### Generating .OVPN client profiles with Openvpn-ui
Before client cert. generation you need to update the external IP address to your OpenVPN server in OVPN-UI GUI.

For this go to `"Configuration > Settings"`:

<img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OVPN_ext_serv_ip1.png" alt="Configuration > Settings" width="350" border="1" />

And then update `"Server Address (external)"` and `"Server Connection Port (external)"` fields with your external Internet IP and external Port. Then go to `"Certificates"` menu, enter new VPN Client **Name**,  **Passphrase**(optional) and **Static IP**(optional) in the field at the page below and press `"Create"` to generate new Client certificate:

<img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OVPN_ext_serv_ip2.png" alt="Server Address" width="350" border="1" />  <img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OVPN_New_Client.png" alt="Create Certificate" width="350" border="1" />

To download .OVPN client configuration file, press on the `Client Name` you just created:

<img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OVPN_New_Client_download.png" alt="download OVPN" width="350" border="1" />

You may need to change server port in .OVPN file. For that, just open it in any text editor (emax?) and update IP and port with the desired one in this line: `remote 178.248.232.12 1194 udp`.
This parameters also can be [preconfigured in](https://github.com/d3vilh/raspberry-gateway/blob/master/example.config.yml#L23) `config.yml` file in var `ovpn_remote`.

### Using .OVPN client profile with OpenVPN client
Install [Official OpenVPN client](https://openvpn.net/vpn-client/) to your client device.

Deliver .OVPN profile to the client device and import it as a FILE, then connect with new profile to enjoy your free VPN:

<img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OVPN_Palm_import.png" alt="PalmTX Import" width="350" border="1" /> <img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OVPN_Palm_connected.png" alt="PalmTX Connected" width="350" border="1" />

### Revoking and deleting .OVPN profiles and Clients certificates
If you would like to prevent client to use yor VPN connection, you have to revoke client certificate and restart the OpenVPN daemon.
You can do it via OpenVPN WEB UI `"Certificates"` menue, by pressing **Revoke** amber button:

<img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OpenVPN-UI-Revoke.png" alt="Revoke Certificate" width="600" border="1" />

Revoked certificates won't kill active connections, you'll have to restart the service if you want the user to immediately disconnect. It can be done via Portainer or OpenVPN WEB UI from the same `"Certificates"` page, by pressing Restart red button:

<img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OpenVPN-UI-Restart.png" alt="OpenVPN Restart" width="600" border="1" />

After Revoking and Restarting the service, the client will be disconnected and will not be able to connect again with the same certificate. To delete the certificate from the server, you have to press **Remove** red button.

### Alternative, CLI ways to deal with OpenVPN configuration
To generate new .OVPN profile execute following command. Password as second argument is optional:
```shell
sudo docker exec openvpn bash /opt/app/bin/genclient.sh <name> <?password?>
```

You can find you .ovpn file under `/openvpn/clients/<name>.ovpn`, make sure to check and modify the `remote ip-address`, `port` and `protocol`. It also will appear in `"Certificates"` menue of OpenVPN WEB UI.

Revoking of old .OVPN files can be done via CLI by running following:

```shell
sudo docker exec openvpn bash /opt/app/bin/rmclient.sh <clientname>
```

Restart of OpenVPN container can be done via the CLI by running following:
```shell
sudo docker-compose restart openvpn
```

To assign desired subnet policy to the specific client, you have to define static IP address for this client after you generate .OVPN profile.
To define static IP, go to `~/openvpn/staticclients` directory and create text file with the name of your client and insert into this file ifrconfig-push option with the desired static IP and mask: `ifconfig-push 10.0.71.2 255.255.255.0`.

For example, if you would like to restrict Home subnet access to your best friend Slava, you should do this:

```shell
slava@Ukraini:~/openvpn/staticclients $ pwd
/home/slava/openvpn/staticclients
slava@Ukraini:~/openvpn/staticclients $ ls -lrt | grep Slava
-rw-r--r-- 1 slava heroi 38 Nov  9 20:53 Slava
slava@Ukraini:~/openvpn/staticclients $ cat Slava
ifconfig-push 10.0.71.2 255.255.255.0
```

### OpenVPN activity dashboard
[Raspberry-Gateway](https://github.com/d3vilh/raspberry-gateway/) setup includes Prometheus [OpenVPN-exporter](https://github.com/d3vilh/openvpn_exporter) and OpenVPN [Grafana dashboard](https://github.com/d3vilh/raspberry-gateway/blob/master/templates/openvpn_exporter.json.j2) which you can [enable in](https://github.com/d3vilh/raspberry-gateway/blob/master/example.config.yml#L39) by setting `openvpn_monitoring_enable` option to `true`.

![OpenVPN Grafana Dashboard](/images/OVPN_Dashboard.png)

### OpenVPN WEB UI screenshots

<img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OpenVPN-UI-Login.png" alt="OpenVPN-UI Login screen" width="1000" border="1" />

<img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OpenVPN-UI-Home.png" alt="OpenVPN-UI Home screen" width="1000" border="1" />

<img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OpenVPN-UI-Certs.png" alt="OpenVPN-UI Certificates screen" width="1000" border="1" />

<img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OpenVPN-UI-Logs.png" alt="OpenVPN-UI Logs screen" width="1000" border="1" />

<img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OpenVPN-UI-Config.png" alt="OpenVPN-UI Configuration screen" width="1000" border="1" />

<img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OpenVPN-UI-Server-config.png" alt="OpenVPN-UI Server Configuration screen" width="1000" border="1" />

<img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OpenVPN-UI-Profile.png" alt="OpenVPN-UI User Profile" width="1000" border="1" />