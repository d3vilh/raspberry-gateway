# Raspberry Gateway
**Simple Raspberry Pi based home Internet gateway**. Which includes 
  * [**OpenVPN container**](https://github.com/d3vilh/raspberry-gateway/tree/master/openvpn/openvpn-docker) with simple [**WEB UI**](https://github.com/d3vilh/openvpn-ui) and VPN subnets support. 
  * [**WireGuard**](https://github.com/d3vilh/raspberry-gateway/tree/master/wireguard) container with own UI. 
  * [**Pi-hole**](https://pi-hole.net) - the network-wide ad-blocking local DNS solution. 
  * [**qBittorrent**](https://www.qbittorrent.org) -  an open-source software alternative to µTorrent. 
  * [**Portainer**](https://www.portainer.io) a lightweight *universal* management GUI for all Docker enviroments which included into this project. 
  * [**Grafana Dashboards**](https://github.com/d3vilh/raspberry-gateway/tree/master/raspi-monitoring) for Internet speed, OpenVPN, Raspberry Pi hardware and running Docker containers status monitoring. 
  * **Various Prometheus exporters**: cAdviser, **AirGradient**, **StarLink**, **ShellyPlug** and others. 

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

# Features
[**Pi-hole**](https://pi-hole.net) the network-wide ad-blocking solution integrated with own local DNS and DHCP servers:

![Pi-hole on the Internet Pi](/images/pi-hole.png)

[**OpenVPN**](https://openvpn.net) server with subnets support and **OpenVPN-web-ui** as lightweight web administration interface or
[**WireGuard**](https://www.wireguard.com) server - an extremely simple yet fast and modern VPN with own **web-ui** as lightweight web administration interface:

<img src="/images/OpenVPN-UI-Home.1.png" alt="OpenVPN WEB UI" width="500"> <img src="/images/WireGuard-UI-Home.1.png" alt="WireGuard WEB UI" width="500">

<p align="center">
<img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OVPN_VLANs.png" alt="OpenVPN Subnets" width="600" border="1" />
</p>

[**qBittorrent**](https://www.qbittorrent.org) an open-source software alternative to µTorrent, with lightweight web administration interface:

![qBittorrent WEB UI](/images/qBittorrent-web-ui.png)

[**Portainer**](https://www.portainer.io) is a lightweight *universal* management interface that can be used to easily manage Docker or K8S containers and environments which included in this setup:

![Portainer](/images/portainer.png)

[**Raspi Monitoring**](https://github.com/d3vilh/raspberry-gateway/tree/master/raspi-monitoring) to monitor your Raspberry server utilisation (CPU,MEM,I/O, Tempriture, storage usage) and Internet connection. Internet connection statistics is based on [Speedtest.net exporter](https://github.com/MiguelNdeCarvalho/speedtest-exporter) results, ping stats and overall Internet availability tests based on HTTP push methods running by [Blackbox exporter](https://github.com/prometheus/blackbox_exporter) to the desired internet sites:

![Raspberry Monitoring Dashboard in Grafana picture 1](/images/raspi-monitoring_1.png) 
![Raspberry Monitoring Dashboard in Grafana picture 2](/images/raspi-monitoring_2.png) 
![Raspberry Monitoring Dashboard in Grafana picture 3](/images/raspi-monitoring_3.png) 
![Raspberry Monitoring Dashboard in Grafana picture 4](/images/raspi-monitoring_4.png) 
![Raspberry Monitoring Dashboard in Grafana picture 5](/images/raspi-monitoring_5.png) 
![Raspberry Monitoring Dashboard in Grafana picture 6](/images/raspi-monitoring_6.png) 

[**AirGradient Monitoring**](https://www.airgradient.com): Configures [`Prometheus`](https://github.com/d3vilh/raspberry-gateway/blob/master/templates/prometheus.yml.j2#L49) to get all necessary data directly from your [AirGradient](https://www.airgradient.com/diy/) device and installs a [Grafana dashboard](https://github.com/d3vilh/raspberry-gateway/blob/master/templates/airgradient-air-quality.json.j2), which tracks and displays air quality over time. 

> Your AirGradient device **must** have alternative [airgradient-improved](https://github.com/d3vilh/airgradient-improved) firmware flashed into EEPROM to support this feature.

![AirGradient Monitoring Dashboard in Grafana picture 1](/images/air-gradient_1.png) 
![AirGradient Monitoring Dashboard in Grafana picture 2](/images/air-gradient_2.png)

[**OpenVPN activity dashboard**](https://github.com/d3vilh/raspberry-gateway/blob/master/templates/openvpn_exporter.json.j2) and [OpenVPN-exporter](https://github.com/d3vilh/openvpn_exporter) which you can be [enable in](https://github.com/d3vilh/raspberry-gateway/blob/master/example.config.yml#L82) by setting `openvpn_monitoring_enable` option to `true`.

![OpenVPN Grafana Dashboard](/images/OVPN_Dashboard.png)

## Other features:
  - **Starlink Monitoring**: Installs a [`starlink` prometheus exporter](https://github.com/danopstech/starlink_exporter) and a Grafana dashboard, which tracks and displays Starlink statistics. (Disabled by default)
  - **Shelly Plug Monitoring**: Installs a [`shelly-plug-prometheus` exporter](https://github.com/geerlingguy/shelly-plug-prometheus) and a Grafana dashboard, which tracks and displays power usage on a Shelly Plug running on the local network. (Disabled by default. Enable and configure using the `shelly_plug_*` vars in `config.yml`.)

# Usage
  ## Portainer
  Visit the Pi's IP address (*e.g. `http://localhost:9000/` , change `localhost` to your Raspberry host ip/name*) it will ask to set new password during the first startup - save the password.

  ## Pi-hole
  Visit the Pi's IP address (*e.g. `http://localhost/` , change `localhost` to your Raspberry host ip/name*) the default password is `gagaZush` it is [preconfigured in](https://github.com/d3vilh/raspberry-gateway/blob/master/example.config.yml#L14) `config.yml` file in var `pihole_password`. Consider to change it before the installation as security must be secure.

  ## qBittorrent
  To access qBittorrent Web-ui, visit the Pi's IP address (*e.g. `http://localhost:8090/` , change `localhost` to your Raspberry host ip/name*) with **default credentials** - `admin/adminadmin`, which **must** be changed via web interface on first login. All the downloaded files will be stored in the `~/qbittorrent/downloads` directory.

  ## WireGuard
  To access WireGuard Web-ui, visit the Pi's IP address (*e.g. `http://localhost:5000/` , change `localhost` to your Raspberry host ip/name*) with default credentials - `admin/gagaZush`, it is [preconfigured in](https://github.com/d3vilh/raspberry-gateway/blob/master/example.config.yml#L39) `config.yml` file in var `wireguard_password`. Consider to change it before the installation as security must be secure.

  ## OpenVPN 
  **OpenVPN and WEB UI** can be accessed on own port (*e.g. `http://localhost:8080` , change `localhost` to your Raspberry host ip/name*), the default user and password is `admin/gagaZush` preconfigured in `config.yml` which you supposed to [set in](https://github.com/d3vilh/raspberry-gateway/blob/master/example.config.yml#L25) `ovpnui_user` & `ovpnui_password` vars, just before the installation.

  All the [**documentation**](https://github.com/d3vilh/raspberry-gateway/blob/master/openvpn/README.md) and How-to can be found [**here**](https://github.com/d3vilh/raspberry-gateway/blob/master/openvpn/README.md)

  ## Raspi-monitoring
  The DataSources and Dashboards for are automatically provisioned.

   ### Grafana dashboards
   To access Grafana, visit the Pi's IP address (*e.g. `http://localhost:3030/` , change `localhost` to your Raspberry host ip/name*) with default credentials - `admin/admin`, it is [preconfigured in](https://github.com/d3vilh/raspberry-gateway/blob/master/example.config.yml#L68) `config.yml` file in var `monitoring_grafana_admin_password`. The `monitoring_grafana_admin_password` is only used the first time Grafana starts up; if you need to change it later, do it via Grafana's admin UI.

   #### Here is list of available dashboards:
   * **Raspberry Pi Monitoring**: Shows CPU, memory, and disk usage, as well as network traffic, temperature and Docker containers utilisation. `http://localhost:3030/d/rvk35ERRz/raspberry-monitoring`
   * **OpenVPN Monitoring**: - OpenVPN activity dashboard. `http://localhost:3030/d/58l7kyvVz/openvpn`
   * **AirGradient Monitoring** - Air quality dashboard. `http://localhost:3030/d/aglivingroom/airquality-airgradient`
   * **Starlink Monitoring**: Starlink monitoring dashboard. `http://localhost:3030/d/GG3mnflGz/starlink-overview`
   * **Shelly Plug Monitoring**: Shelly Plug dashboard. `http://localhost:3030/d/i_aeo-uMz/power-consumption`
   >**Note**: Change `localhost` to your Raspberry ip/hostname.

  If you don't see any data on dashboard - try to change the time duration to something smaller. If this does not helps - check via **Portainer UI** that all the exporters and containers are running:

  <img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/portainer-run.png" alt="Running containers" width="350" border="1" />

  Then debug **Prometheus targets** described in next partagraph.

### Prometheus
Prometheus is available on `http://localhost:9090` (*e.g. `http://localhost:9090/` , change `localhost` to your Raspberry host ip/name*). It is used to collect metrics from exporters and provide them to Grafana.
Targets status can be checked on `http://localhost:9090/targets`.

#### Here is list of available exporters/targets:

* **Node exporter** - Standard Linux server monitoring (CPU,RAM,I/O,FS,PROC). `http://nodeexp:9100/metrics`
* **cAdvisor exporter** - Docker containers monitoring. `http://cadvisor:8080/metrics`
* **rpi_exporter** - RaspberryPI HW monitoring. `http://rpi_exporter:9110/metrics`
* **Speedtest exporter** - Up/down speed and latency. `http://speedtest:9798/metrics` 
* **Blackbox exporter** - Desired sites avilability. `http://ping:9115/probe`
* **OpenVPN exporter** - OpenVPN activity monitoring. `http://openvpn:9176/metrics`
* **AirGradient exporter** - AirQuality monitoring. `http://remote-AirGradient-ip:9926/metrics`
* **PiKVM exporter** - PiKVM utilisation and temp monitoring. `https://remote-PiKVM-ip/api/export/prometheus/metrics`
* **Starlink exporter** - Starlink monitoring. `http://starlink:9817/metrics`
* **Shelly exporter** - Shelly Plug power consumption monitoring. `http://shelly:9924/metrics`

## Дякую and Kudos to all the envolved peole

Kudos to @vegasbrianc for [super easy docker](https://github.com/vegasbrianc/github-monitoring) stack used to build this project.

Kudos to @adamwalach for development of original [OpenVPN-WEB-UI](https://github.com/adamwalach/openvpn-web-ui) interface of x86 computers which was ported for arm32v7 and arm64V8 with expanded functionality as part of this project.

Kudos to @maxandersen for making the [Internet Monitoring](https://github.com/maxandersen/internet-monitoring) project, which forked and expanded with functionality to build Rasbpi-Monitoring.

**Grand Kudos** to Jeff Geerling aka [@geerlingguy](https://github.com/geerlingguy) for all his efforts to make us interesting in Raspberry Pi compiters and for [all his propaganda on youtube](https://www.youtube.com/c/JeffGeerling). Consider to like and subscribe ;)

