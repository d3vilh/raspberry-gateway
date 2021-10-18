# Raspberry Gateway

**Simple Raspberry PI internet gateway** - Docker-based environment which includes preconfigured OpenVPN (with WEB UI), Pi-hole (the network-wide ad-blocking and local DNS), Network and Raspberry-Pi monitoring bashboards based on Prometeus + Grafana and finally Portainer - lightweight *universal* management GUI for Docker enviroments included in this project.

## Features

[**Pi-hole**](https://pi-hole.net) the network-wide ad-blocking solution integrated with own local DNS and DHCP servers:

![Pi-hole on the Internet Pi](/images/pi-hole.png)

[**OpenVPN**](https://openvpn.net) server and [OpenVPN-web-ui](https://github.com/adamwalach/openvpn-web-ui) as UI administration interface:

![OpenVPN WEB UI](/images/OpenVPN-UI-Home.png)

[**Raspi Monitoring**](https://github.com/d3vilh/raspberry-gateway/tree/master/raspi-monitoring) which includes Gafana and Prometheus along with a few exporters to monitor your Raspberry server utilisation (CPU,MEM,I/O, Tempriture and Storage usage) with Internet connection statisitcs graphs based on Speedtest.net tests results, HTTP push tests for desired sites to mesure Internet connection, ping stats and overall network availability:

![Raspberry Monitoring Dashboard in Grafana picture 1](/images/raspi-monitoring_1.png) 
![Raspberry Monitoring Dashboard in Grafana picture 2](/images/raspi-monitoring_2.png) 
  > If you use the included Raspi Monitoring, it **will download a decently-large amount of data through your Internet connection on a daily basis**. You can completetly shutdown containers belongs to the `Raspi-monitoring stack` with **Portainer** or tune the `raspi-monitoring` setup to not run the speedtests as often.

[**Portainer**](https://www.portainer.io) is a lightweight ‘universal’ management interface that can be used to easily manage Docker or K8S containers and environments which included into [raspberry-gateway](https://github.com/d3vilh/raspberry-gateway) project:

![Portainer](/images/portainer.png)

## Other features:

  - **OpenVPN-UI** - Lightweight web administration interface [written by Adam Walach](https://github.com/adamwalach/openvpn-web-ui). 
  Porting for RaspberryPi as part of [this project](https://github.com/d3vilh/raspberry-gateway) is still in progress by [myself](https://github.com/d3vilh).
  - [**AirGradient Monitoring**](https://www.airgradient.com): Installs an [`airgradient-prometheus` exporter](https://github.com/geerlingguy/airgradient-prometheus) and a Grafana dashboard, which tracks and displays air quality over time via a local [AirGradient DIY monitor](https://www.airgradient.com/diy/). (Disabled by default. Enable and configure using the `airgradient_enable` var in `config.yml`. See example configuration for ability to monitor multiple AirGradient DIY stations.)
  - **Starlink Monitoring**: Installs a [`starlink` prometheus exporter](https://github.com/danopstech/starlink_exporter) and a Grafana dashboard, which tracks and displays Starlink statistics. (Disabled by default)
  - **Shelly Plug Monitoring**: Installs a [`shelly-plug-prometheus` exporter](https://github.com/geerlingguy/shelly-plug-prometheus) and a Grafana dashboard, which tracks and displays power usage on a Shelly Plug running on the local network. (Disabled by default. Enable and configure using the `shelly_plug_*` vars in `config.yml`.)

# Requirements
- [**Raspberry Pi 4**](https://www.raspberrypi.com/products/raspberry-pi-4-model-b/), [**Raspberry Pi CM4**](https://www.raspberrypi.com/products/compute-module-4/?variant=raspberry-pi-cm4001000) **and** [**CM4 I/O Board**](https://www.raspberrypi.com/products/compute-module-4-io-board/) or [**Raspberry Pi 3**](https://www.raspberrypi.com/products/raspberry-pi-3-model-b-plus/) board, all with 2-4Gb RAM minimum.
- [**Raspberry Pi Imager**](https://www.raspberrypi.com/software/) to simplify installation of Raspberry Pi OS Lite.
- **16Gb SD Card**
> You can run it on Raspberry-pi Zero-W board as well, but be ware, that it has no internal Ehernet adapter and has very limited performance resources, which limits you on the number of running containers and clients connected to your VPN server.

# Installation

  1. Install [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html):
     ```shell 
     hostname|puser> sudo apt-get install -y python3-pip
     hostname|puser> pip3 install ansible
     ```
  2. Clone this repository: 
     ```shell
     hostname|puser> git clone https://github.com/d3vilh/raspberry-gateway
     ```
  3. Then enter the repository directory: 
     ```shell 
     hostname|puser> cd raspberry-gateway
     ```
  4. Install requirements: 
     ```shell
     hostname|puser> ansible-galaxy collection install -r requirements.yml
     ```
     > If you see `ansible-galaxy: command not found`, you have to relogin (or reboot your Pi) and then try again.
  5. Make copies of the configuration files and modify them for your enviroment:
     ```shell
     hostname|puser> yes | cp -p example.inventory.ini inventory.ini 
     hostname|puser> yes | cp -p example.config.yml config.yml
     ```
  6. Modify `inventory.ini` by replace of IP address with your Pi's IP, or comment that line and uncomment the `connection=local` line if you're running it on the Pi you're setting up.
  7. Modify `config.yml` to enabe or disable desired containers to be installed on your Pi:

     **To enable** Prtainer container change `enable_portainer false` option to `enable_portainer true` and vs to disable.
  9. Run installation playbook:
     ```shell
     hostname|puser> ansible-playbook main.yml
     ```
> **If running locally on the Pi**: You may have error like `Error while fetching server API version`. You have to relogin (or reboot your Pi) and then run the playbook again.

# Usage

## Portainer

Visit the Pi's IP address (e.g. http://localhost:9000/) (change `localhost` to your docker host ip/name) it will ask to set new password during the first startup - save it.

## Pi-hole

Visit the Pi's IP address (e.g. http://localhost/) and use the `pihole_password` you configured in your `config.yml` file.

## OpenVPN 

Im still porting **OpenVPN WEB UI** for Raspberry Pi as part of [this project](https://github.com/d3vilh/raspberry-gateway). Work is still in progress, but you alreday have container with GoLang Web UI available, which can be accessed by its own address (e.g. http://localhost:8080) and default preconfigured password `AbabaGalamaga1997` (shhh. its a secret). You can already see some statistics, OpenVPN logfile in realtime and generate new Client certificates by one click.

However standard **OpenVPN server** are already accessisble for use with full functionality.

The volume container will be inicialized by using the official `openvpn_openvpn` image with included the scripts to automatically generate following on the first run:
 - Diffie-Hellman parameters
 - an EasyRSA CA key and certificate
 - a new private key
 - a self-certificate matching the private key for the OpenVPN server
 - a TLS auth key from HMAC security

This setup use `tun` mode, because it works on the widest range of devices. tap mode, for instance, does not work on Android, except if the device is rooted.

The topology used is `subnet`, because it works on the widest range of OS. p2p, for instance, does not work on Windows.

The UDP server uses `10.0.70.0/24` for dynamic clients by default, just because.

The client profile specifies `push redirect-gateway def1 bypass-dhcp`, meaning that after establishing the VPN connection, all traffic will go through the VPN. This might cause problems if you use local DNS recursors which are not directly reachable, since you will try to reach them through the VPN and they might not answer to you. If that happens, use public DNS resolvers like those of OpenDNS (`208.67.222.222` and `208.67.220.220`) or Google (`8.8.4.4` and `8.8.8.8`).

### Generating .ovpn files

Before client certificate generation you need to update the external IP address to your OpenVPN server in OVPN-UI GUI.

For this go to "Configuration > Settings":

<img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OVPN_ext_serv_ip1.png" alt="Configuration > Settings" width="350" border="1" />

And then update "Server Address (external)" field with your external Internet IP. Then go to "Certificates", enter new VPN client name in the field at the page below and press "Create" to generate new Client certificate:

<img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OVPN_ext_serv_ip2.png" alt="Server Address" width="350" border="1" />  <img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OVPN_New_Client.png" alt="Create Certificate" width="350" border="1" />

To download .OVPN client configuration file, press on the Client Name you just created:

<img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OVPN_New_Client_download.png" alt="download OVPN" width="350" border="1" />

Deliver .OVPN file to the client devilce, open it in the Official OpenVPN client and connect with new profile to enjoy your free VPN:

<img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OVPN_Palm_import.png" alt="PalmTX Import" width="350" border="1" /> <img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OVPN_Palm_connected.png" alt="PalmTX Connected" width="350" border="1" />

### Alternative CLI way to generate .ovpn files

Execute following command. Password as second argument is an optional:
```shell
sudo docker exec openvpn bash /opt/app/bin/genclient.sh <name> <?password?>
```

You can find you .ovpn file under `/openvpn/clients/<name>.ovpn`, make sure to check and modify the `remote ip-address`, `port` and `protocol`.

### Revoking .ovpn files

```shell
sudo docker exec openvpn bash /opt/app/bin/rmclient.sh <name>
```

Revoked certificates won't kill active connections, you'll have to restart the service if you want the user to immediately disconnect. It can be done via Portainer GUI or CLI:
```shell
sudo docker-compose restart openvpn
```

All the Server and client configuration locates in Dockerfile volume and can be easly tuned. Here are tree of volume content:

```shell
|-- clients
|   |-- your_client1.ovpn
|   |-- your_client2.ovpn
|-- config
|   |-- client.conf
|   |-- easy-rsa.vars
|   |-- server.conf
|-- db
|   |-- data.db
|-- log
|   |-- openvpn.log
|-- pki
|   |-- ca.crt
|   |-- certs_by_serial
|   |   |-- your_client1_serial.pem
|   |   |-- your_client2_serial.pem
|   |-- crl.pem
|   |-- dh.pem
|   |-- index.txt
|   |-- index.txt.attr
|   |-- ipp.txt
|   |-- issued
|   |   |-- server.crt
|   |   |-- client-your_client1.crt
|   |   |-- client-your_client2.crt
|   |-- openssl-easyrsa.cnf
|   |-- private
|   |   |-- ca.key
|   |   |-- client-your_client1.key
|   |   |-- client-your_client2.key
|   |   |-- server.key
|   |-- renewed
|   |   |-- certs_by_serial
|   |   |-- private_by_serial
|   |   |-- reqs_by_serial
|   |-- reqs
|   |   |-- server.req
|   |   |-- client-your_client1.req
|   |   |-- client-your_client2.req
|   |-- revoked
|   |   |-- certs_by_serial
|   |   |-- private_by_serial
|   |   |-- reqs_by_serial
|   |-- safessl-easyrsa.cnf
|   |-- serial
|   |-- ta.key
|-- staticclients
```

## Grafana

Visit the Pi's IP address with port 3030 (e.g. http://localhost:3030/), and log in with username `admin` and the password `monitoring_grafana_admin_password` you configured in your `config.yml`.

> Note: The `monitoring_grafana_admin_password` is only used the first time Grafana starts up; if you need to change it later, do it via Grafana's admin UI.

  > If you use the included Raspi Monitoring, it **will download a decently-large amount of data through your Internet connection on a daily basis**. You can completetly shutdown containers belongs to the `Raspi-monitoring stack` with **Portainer** or tune the `raspi-monitoring` setup to not run the speedtests as often.
