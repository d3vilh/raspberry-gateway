# Raspberry Gateway

**Simple Raspberry Pi based home Internet gateway**. Which includes 
[**OpenVPN container**](https://github.com/d3vilh/raspberry-gateway/tree/master/openvpn/openvpn-docker) with simple [**WEB UI**](https://github.com/d3vilh/openvpn-web-ui) and VPN subnets support. [**Pi-hole**](https://pi-hole.net) - the network-wide ad-blocking local DNS solution. [**Grafana Dashboards**](https://github.com/d3vilh/raspberry-gateway/tree/master/raspi-monitoring) for Internet speed, OpenVPN and Raspberry Pi hardware status monitoring. [**Portainer**](https://www.portainer.io) a lightweight *universal* management GUI for all Docker enviroments which included into this project. It also includes **AirGradient**, **StarLink** and **ShellyPlug** Grafana dashboards and necessary exporters to get data.

# Requirements
- [**Raspberry Pi 4**](https://www.raspberrypi.com/products/raspberry-pi-4-model-b/), [**Raspberry Pi CM4**](https://www.raspberrypi.com/products/compute-module-4/?variant=raspberry-pi-cm4001000) **and** [**CM4 I/O Board**](https://www.raspberrypi.com/products/compute-module-4-io-board/) or [**Raspberry Pi 3**](https://www.raspberrypi.com/products/raspberry-pi-3-model-b-plus/) board, all with 2-4Gb RAM minimum.
- [**Raspberry Pi Imager**](https://www.raspberrypi.com/software/) to simplify installation of Raspberry Pi OS Lite (x64 or i686 bit).
- [**Raspios Lite (64bit)**](https://downloads.raspberrypi.org/raspios_lite_arm64/images/) however is recommended for this setup.
- **16Gb SD Card**
> You can run it on CM4 board with 8Gb eMMC card. Full installation on top of latest [Raspios lite (64bit)](https://downloads.raspberrypi.org/raspios_lite_arm64/images/) will use 4,5Gb of your eMMC card. Raspberry-pi Zero-W, or W2 boards supported as well, but be aware, that it has no internal Ehernet adapter and very limited by avilable CPU & RAM resources, what limits the number of running containers and clients connected to VPN server.

# Installation

  1. Install [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html):
     ```shell 
     sudo apt-get install -y python3-pip
     pip3 install ansible
     ```
  2. Clone this repository: 
     ```shell
     git clone https://github.com/d3vilh/raspberry-gateway
     ```
  3. Then enter the repository directory: 
     ```shell 
     cd raspberry-gateway
     ```
  4. Install requirements: 
     ```shell
     ansible-galaxy collection install -r requirements.yml
     ```
     > If you see `ansible-galaxy: command not found`, you have to relogin (or reboot your Pi) and then try again.
  5. Make copies of the configuration files and modify them for your enviroment:
     ```shell
     yes | cp -p example.inventory.ini inventory.ini 
     yes | cp -p example.config.yml config.yml
     ```
  6. Modify `inventory.ini` by replace of IP address with your Pi's IP, or comment that line and uncomment the `connection=local` line if you're running it on the Pi you're setting up.
  7. Modify `config.yml` to enabe or disable desired containers to be installed on your Pi:

     **To enable** Prtainer container change `enable_portainer false` option to `enable_portainer true` and vs to disable.
  9. Run installation playbook:
     ```shell
     ansible-playbook main.yml
     ```
> **If running locally on the Pi**: You may have error like `Error while fetching server API version`. You have to relogin (or reboot your Pi) and then run the playbook again.

## Features

[**Pi-hole**](https://pi-hole.net) the network-wide ad-blocking solution integrated with own local DNS and DHCP servers:

![Pi-hole on the Internet Pi](/images/pi-hole.png)

[**OpenVPN**](https://openvpn.net) server with subnets support and **OpenVPN-web-ui** as lightweight web administration interface:

![OpenVPN WEB UI](/images/OpenVPN-UI-Home.png)

<p align="center">
<img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OVPN_VLANs.png" alt="OpenVPN Subnets" width="600" border="1" />
</p>

[**Portainer**](https://www.portainer.io) is a lightweight *universal* management interface that can be used to easily manage Docker or K8S containers and environments which included in this setup:

![Portainer](/images/portainer.png)

[**Raspi Monitoring**](https://github.com/d3vilh/raspberry-gateway/tree/master/raspi-monitoring) to monitor your Raspberry server utilisation (CPU,MEM,I/O, Tempriture, storage usage) and Internet connection. Internet connection statistics is based on [Speedtest.net exporter](https://github.com/MiguelNdeCarvalho/speedtest-exporter) results, ping stats and overall Internet availability tests based on HTTP push methods running by [Blackbox exporter](https://github.com/prometheus/blackbox_exporter) to the desired internet sites:

![Raspberry Monitoring Dashboard in Grafana picture 1](/images/raspi-monitoring_1.png) 
![Raspberry Monitoring Dashboard in Grafana picture 2](/images/raspi-monitoring_2.png) 

[**AirGradient Monitoring**](https://www.airgradient.com): Configures [`Prometheus`](https://github.com/d3vilh/raspberry-gateway/blob/master/templates/prometheus.yml.j2#L49) to get all necessary data directly from your [AirGradient](https://www.airgradient.com/diy/) device and installs a [Grafana dashboard](https://github.com/d3vilh/raspberry-gateway/blob/master/templates/airgradient-air-quality.json.j2), which tracks and displays air quality over time. 

> Your AirGradient device **must** have alternative [airgradient-improved](https://github.com/d3vilh/airgradient-improved) firmware flashed into EEPROM to support this feature.

![AirGradient Monitoring Dashboard in Grafana picture 1](/images/air-gradient_1.png) 
![AirGradient Monitoring Dashboard in Grafana picture 2](/images/air-gradient_2.png)

## Other features:
  - **Starlink Monitoring**: Installs a [`starlink` prometheus exporter](https://github.com/danopstech/starlink_exporter) and a Grafana dashboard, which tracks and displays Starlink statistics. (Disabled by default)
  - **Shelly Plug Monitoring**: Installs a [`shelly-plug-prometheus` exporter](https://github.com/geerlingguy/shelly-plug-prometheus) and a Grafana dashboard, which tracks and displays power usage on a Shelly Plug running on the local network. (Disabled by default. Enable and configure using the `shelly_plug_*` vars in `config.yml`.)

# Usage

## Portainer

Visit the Pi's IP address (*e.g. http://localhost:9000/ , change `localhost` to your Raspberry host ip/name*) it will ask to set new password during the first startup - save the password.

## Pi-hole

Visit the Pi's IP address (*e.g. http://localhost/ , change `localhost` to your Raspberry host ip/name*) the default password is `gagaZush` it is [preconfigured in](https://github.com/d3vilh/raspberry-gateway/blob/master/example.config.yml#L13) `config.yml` file in var `pihole_password`. Consider to change it before the installation as security must be secure.

## OpenVPN 

**OpenVPN WEB UI** can be accessed on own port (*e.g. http://localhost:8080 , change `localhost` to your Raspberry host ip/name*), the default user and password is `admin/gagaZush` preconfigured in `config.yml` which you supposed to [set in](https://github.com/d3vilh/raspberry-gateway/blob/master/example.config.yml#L18) `ovpnui_user` & `ovpnui_password` vars, just before the installation.

The volume container will be inicialized by using the official OpenVPN `openvpn_openvpn` image with included scripts to automatically generate everything you need  on the first run:
 - Diffie-Hellman parameters
 - an EasyRSA CA key and certificate
 - a new private key
 - a self-certificate matching the private key for the OpenVPN server
 - a TLS auth key from HMAC security

This setup use `tun` mode, because it works on the widest range of devices. tap mode, for instance, does not work on Android, except if the device is rooted.

The topology used is `subnet`, because it works on the widest range of OS. p2p, for instance, does not work on Windows.

The server config [specifies](https://github.com/d3vilh/raspberry-gateway/blob/master/openvpn/config/server.conf#L40) `push redirect-gateway def1 bypass-dhcp`, meaning that after establishing the VPN connection, all traffic will go through the VPN. This might cause problems if you use local DNS recursors which are not directly reachable, since you will try to reach them through the VPN and they might not answer to you. If that happens, use public DNS resolvers like those of OpenDNS (`208.67.222.222` and `208.67.220.220`) or Google (`8.8.4.4` and `8.8.8.8`).

If you wish to use your local Pi-Hole as a DNS server (the one which comes with this setup), you have to modify a [dns-configuration](https://github.com/d3vilh/raspberry-gateway/blob/master/openvpn/config/server.conf#L21) with your local Pi-Hole IP address.

### Generating .OVPN client profiles

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

### Revoking .OVPN profiles

If you would like to prevent client to use yor VPN connection, you have to revoke client certificate and restart the OpenVPN daemon.
You can do it via OpenVPN WEB UI `"Certificates"` menue, by pressing **Revoke** amber button:

<img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OpenVPN-UI-Revoke.png" alt="Revoke Certificate" width="600" border="1" />

Revoked certificates won't kill active connections, you'll have to restart the service if you want the user to immediately disconnect. It can be done via Portainer or OpenVPN WEB UI from the same `"Certificates"` page, by pressing Restart red button:

<img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OpenVPN-UI-Restart.png" alt="OpenVPN Restart" width="600" border="1" />

After Revoking and Restarting the service, the client will be disconnected and will not be able to connect again with the same certificate. To delete the certificate from the server, you have to press **Remove** red button.

### OpenVPN client subnets. Guest and Home users

[Raspberry-Gateway](https://github.com/d3vilh/raspberry-gateway/) OpenVPN server uses `10.0.70.0/24` **"Trusted"** subnet for dynamic clients by default and all the clients connected by default will have full access to your Home network, as well as your home Internet.
However you can be desired to share VPN access with your friends and restrict access to your Home network for them, but allow to use Internet connection over your VPN. This type of guest clients needs to live in special **"Guest users"** subnet - `10.0.71.0/24`:

<p align="center">
<img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OVPN_VLANs.png" alt="OpenVPN Subnets" width="700" border="1" />
</p>

To assign desired subnet policy to the specific client, you have to define static IP address for this client when you'll be generate new .OVPN profile.
To do that, just enter `"Static IP (optional)"` field in `"Certificates"` page and press `"Create"` button.

> Keep in mind, by default, all the clients have full access, so you don't need to specifically configure static IP for your own devices, your home devices always will land to **"Trusted"** subnet by default. 

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
|-- staticclients //Directory where stored all the satic clients configuration
```

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
[Raspberry-Gateway](https://github.com/d3vilh/raspberry-gateway/) setup includes Prometheus [OpenVPN-exporter](https://github.com/d3vilh/openvpn_exporter) and OpenVPN [Grafana dashboard](https://github.com/d3vilh/raspberry-gateway/blob/master/templates/openvpn_exporter.json.j2) which you can [enable in](https://github.com/d3vilh/raspberry-gateway/blob/master/example.config.yml#L39) by setting `openvpn_exporter_enable` option to `true`.

![OpenVPN Grafana Dashboard](/images/OVPN_Dashboard.png)

## Raspi-monitoring

The DataSource and Dashboard for Raspi-monitoring are automatically provisioned.

### Grafana dashboard

is available at http://localhost:3030/d/o9mIe_Aik/Raspi-monitoring 

Login with `admin` and the password `monitoring_grafana_admin_password` you preconfigured in `config.yml`.

> Note: The `monitoring_grafana_admin_password` is only used the first time Grafana starts up; if you need to change it later, do it via Grafana's admin UI.

If you don't see any data on dashboard - try to change the time duration to something smaller. If this does not helps - check via **Portainer UI** that all the exporters containers are running:

<img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/portainer-run.png" alt="Running containers" width="350" border="1" />

Then debug **Prometheus targets** described in next partagraph.

### Prometheus

http://localhost:9090/targets shows status of monitored targets as seen from prometheus - in this case which hosts being pinged and speedtest. note: speedtest will take a while before it shows as UP as it takes about 30s to respond.

http://localhost:9090/graph?g0.expr=probe_http_status_code&g0.tab=1 shows prometheus value for `probe_http_status_code` for each host. You can edit/play with additional values. Useful to check everything is okey in prometheus (in case Grafana is not showing the data you expect).

http://localhost:9115 blackbox exporter endpoint. Lets you see what have failed/succeded.

http://localhost:9798/metrics speedtest exporter endpoint. Does take about 30 seconds to show its result as it runs an actual speedtest when requested.

## Дякую and Kudos to the original authorts

Kudos to @vegasbrianc for [super easy docker](https://github.com/vegasbrianc/github-monitoring) stack used to build this project.

Kudos to @adamwalach for development of original [OpenVPN-WEB-UI](https://github.com/adamwalach/openvpn-web-ui) interface of x86 computers which was ported for arm32v7 and arm64V8 with expanded functionality as part of this project.

Kudos to @maxandersen for making the [Internet Monitoring](https://github.com/maxandersen/internet-monitoring) project, which forked and expanded with functionality to build Rasbpi-Monitoring.

**Grand Kudos** to Jeff Geerling aka [@geerlingguy](https://github.com/geerlingguy) for all his efforts to make us interesting in Raspberry Pi compiters and for [all his propaganda on youtube](https://www.youtube.com/c/JeffGeerling). Consider to like and subscribe ;)

