# Raspberry Gateway
**Simple Raspberry Pi based home Internet gateway**. Which includes 
  * [**Portainer**](https://www.portainer.io) a lightweight *universal* management GUI for all Docker containers which included into this project. 
  * [**OpenVPN Server**](https://github.com/d3vilh/raspberry-gateway/tree/master/openvpn-server/openvpn-docker) container with OpenVPN, simple [**WEB UI**](https://github.com/d3vilh/openvpn-ui) and VPN subnets support. 
  * [**OpenVPN Client**](https://github.com/d3vilh/raspberry-gateway/tree/master/openvpn-client) container for qBittorrent connection to the external VPN server.
  * [**qBittorrent**](https://www.qbittorrent.org) -  an open-source software alternative to µTorrent. 
  * [**Pi-hole**](https://pi-hole.net) container with network-wide ad-blocking, local DNS & DHCP solution. Can be paried with Unbound DNS.
  * [**Unbound DNS**](https://nlnetlabs.nl/projects/unbound/about/) container with the validating, recursive, caching DNS resolver. It is designed to be fast and lean.
  * [**Grafana Dashboards**](https://github.com/d3vilh/raspberry-gateway/tree/master/monitoring) for Internet speed, OpenVPN, Raspberry Pi hardware and Docker containers status monitoring. 
  * [**Technitium-dns**](https://technitium.com/dns/) container with self host DNS server. Block ads & malware at DNS level for your entire network.
  * [**WireGuard Server**](https://github.com/d3vilh/raspberry-gateway/tree/master/wireguard) container with own WEB UI. 
  * **Various Prometheus exporters**: cAdviser, AirGradient, StarLink, ShellyPlug and others. 

# Requirements
  - [**Raspberry Pi 4**](https://www.raspberrypi.com/products/raspberry-pi-4-model-b/), [**Raspberry Pi CM4**](https://www.raspberrypi.com/products/compute-module-4/?variant=raspberry-pi-cm4001000) **and** [**CM4 I/O Board**](https://www.raspberrypi.com/products/compute-module-4-io-board/) or [**Raspberry Pi 3**](https://www.raspberrypi.com/products/raspberry-pi-3-model-b-plus/) board, all with 2-4Gb RAM minimum.
  - [**Raspberry Pi Imager**](https://www.raspberrypi.com/software/) to simplify installation of Raspberry Pi OS Lite (x64 or i686 bit).
  - [**Raspios Lite (64bit)**](https://downloads.raspberrypi.org/raspios_lite_arm64/images/) however is recommended for this setup.
  - **16Gb SD Card**
    > **Note**: You can run it on CM4 board with 8Gb eMMC card. Full installation on top of latest [Raspios lite (64bit)](https://downloads.raspberrypi.org/raspios_lite_arm64/images/) will use 4,5Gb of your eMMC card. Raspberry Pi **Zero-W** or **W2** boards can also be used, but it's important to note that they lack an internal Ethernet adapter and have limited CPU and RAM resources. This can restrict the number of containers that can be run and the number of clients that can connect to the VPN server.

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
     > **Note**: If you see `ansible-galaxy: command not found`, you have to relogin (or reboot your Pi) and then try again.
  5. Make copies of the configuration files and modify them for your enviroment:
      ```shell
      yes | cp -p example.inventory.ini inventory.ini 
      yes | cp -p example.config.yml config.yml
      ```
  6. Modify `inventory.ini` by replace of IP address with your Pi's IP, or comment that line and uncomment the `connection=local` line if you're running it on the Pi you're setting up. **Double check** that the `ansible_user` is correct for your setup.
  7. Modify `config.yml` to **enabe or disable desired containers** to be installed on your Pi:
     **To enable** Prtainer - change `enable_portainer: false` option to `enable_portainer: true` and vs to disable.
      > **Note**: To make all necesary changes: `nano config.yml`, save the file - `Ctrl+O` and `Ctrl+X` to exit.

      <details>
      <summary>List of available configuration options</summary>

      * **Pi-Hole** 
         * `pihole_enable: true` or `false` - **enabled** or disabled Pi-Hole installation
         * `pihole_inside_vpn: false` or `true` - configure Pi-Hole to use your [OpenVPN Client](https://github.com/d3vilh/raspberry-gateway/tree/master/openvpn-client) subnet instead of public Internet.

      * **Technitium DNS** 
         * `tech_dns_enable: false` or `true` - **disabled** or enabled Technitium DNS installation. 
         * `tech_dns_inside_vpn: false` or `true` - configure Technitium DNS to use your [OpenVPN Client](https://github.com/d3vilh/raspberry-gateway/tree/master/openvpn-client) subnet instead of public Internet.

      * **OpenVPN Server** 
         * `ovpn_server_enable: false` or `true` - **disabled** or enabled OpenVPN Server installation.

      * **OpenVPN Client** 
         * `ovpn_client_enable: false` or `true` - **disabled** or enabled OpenVPN Client installation.
         * Put your OpenVPN connection profile `*.ovpn` into `openvpn-client` directory before installation and update its name in `ovpn_client_cert: "example-client.opvn"` option before installation.
         * `ovpn_client_secret: ""` - filename with your OpenVPN connection profile user and password if you have any.
         * `ovpn_client_allowed_subnet: "192.168.0.0/24" ` - Your local subnet from which you want to access qBitTorrent web-ui when VPN Client connection is active.

      * **WireGuard Server** 
         * `wireguard_server_enable: false` or `true` - **disabled** or enabled WireGuard Server installation.

      * **Portainer** 
         * `portainer_enable: true` or `false` - **enabled** or disabled Portainer containers management web-ui installation.

      * **qBitTorrent** 
         * `qbittorrent_enable: false` or `true` - **disabled** or enabled qBittorrent installation.
         * `qbittorrent_inside_vpn: false` or `true` - configure qBittorrent to use your [OpenVPN Client](https://github.com/d3vilh/raspberry-gateway/tree/master/openvpn-client) subnet instead of public Internet.

      * **Raspberry Monitoring** 
         * `monitoring_enable: true` or `false` - **enabled** or disabled general Raspberry Monitoring feature.
         * `openvpn_monitoring_enable: true` or `false` - **disabled** or enabled OpenVPN monitoring.
         * `pikvm_monitoring_enable: true` or `false` - **disabled** or enabled Pi-KVM monitoring.
         * `airgradient_monitoring_enable: true` or `false` - **disabled** or enabled AirGradient monitoring.
         * `starlink_monitoring_enable: true` or `false` - **disabled** or enabled StarLink monitoring.
         * `shellyplug_monitoring_enable: true` or `false` - **disabled** or enabled ShellyPlug monitoring.
      </details>

      > **Note**: Default configuration options are bold.
  8. Modify advanced configuration options in `advanced.config.yml` if needed.
     > **Note**: Default configuration options are bold.
  9. Run installation playbook:
     ```shell
     ansible-playbook main.yml
     ```
     > **Note**: **If running locally on the Pi**: You may have error like `Error while fetching server API version`. You have to relogin (or reboot your Pi) and then run the playbook again.

# Features
[**Pi-hole**](https://pi-hole.net) or [**Technitium-dns**](https://technitium.com/dns/) as the network-wide ad-blocking solution integrated with own local DNS and DHCP servers:

<p align="center">
<img src="/images/Pi-hole.1.png" alt="Pi-hole" width="410"> <img src="/images/Technitium-dns.1.png" alt="Technitium" width="410">
</p>

[**OpenVPN Server**](https://openvpn.net) with subnets support and [**openvpn-ui**](https://github.com/d3vilh/openvpn-ui) as fast and lightweight web administration interface or
[**WireGuard**](https://www.wireguard.com) server - an extremely simple yet fast and modern VPN with own web administration interface:
<p align="center">
<img src="/images/OpenVPN-UI-Home.1.png" alt="OpenVPN WEB UI" width="410"> <img src="/images/WireGuard-UI-Home.1.png" alt="WireGuard WEB UI" width="410">
</p>
<p align="center">
<img src="/images/OVPN_VLANs.png" alt="OpenVPN Subnets" width="600">
</p>

[**OpenVPN Client**](https://github.com/d3vilh/raspberry-gateway/tree/master/openvpn-client) container for using external OpenVPN server connection for selected containers of this project. 
> **Note**: qBitTorrent can be configured to use OpenVPN Client as a proxy to download torrents via VPN!

[**qBittorrent**](https://www.qbittorrent.org) an open-source software alternative to µTorrent, with lightweight web administration interface:

![qBittorrent WEB UI](/images/qBittorrent-web-ui.png)

[**Portainer**](https://www.portainer.io) is a lightweight *universal* management interface that can be used to easily manage Docker or K8S containers and environments which included in this setup:

![Portainer](/images/portainer.png)

[**Raspi Monitoring**](https://github.com/d3vilh/raspberry-gateway/tree/master/monitoring) to monitor your Raspberry server utilisation (CPU,MEM,I/O, Tempriture, storage usage) and Internet connection. Internet connection statistics is based on [Speedtest.net exporter](https://github.com/MiguelNdeCarvalho/speedtest-exporter) results, ping stats and overall Internet availability tests based on HTTP push methods running by [Blackbox exporter](https://github.com/prometheus/blackbox_exporter) to the desired internet sites:

![Raspberry Monitoring Dashboard in Grafana picture 1](/images/raspi-monitoring_1.png) 
![Raspberry Monitoring Dashboard in Grafana picture 2](/images/raspi-monitoring_2.png) 
![Raspberry Monitoring Dashboard in Grafana picture 3](/images/raspi-monitoring_3.png) 
![Raspberry Monitoring Dashboard in Grafana picture 4](/images/raspi-monitoring_4.png) 
![Raspberry Monitoring Dashboard in Grafana picture 5](/images/raspi-monitoring_5.png) 
![Raspberry Monitoring Dashboard in Grafana picture 6](/images/raspi-monitoring_6.png) 

[**AirGradient Monitoring**](https://www.airgradient.com): Configures [`Prometheus`](https://github.com/d3vilh/raspberry-gateway/blob/master/templates/prometheus.yml.j2#L49) to get all necessary data directly from your [AirGradient](https://www.airgradient.com/diy/) device and installs a [Grafana dashboard](https://github.com/d3vilh/raspberry-gateway/blob/master/templates/airgradient-air-quality.json.j2), which tracks and displays air quality over time. 

> **Note**: Your AirGradient device **must** have alternative [airgradient-improved](https://github.com/d3vilh/airgradient-improved) firmware flashed into EEPROM to support this feature.

![AirGradient Monitoring Dashboard in Grafana picture 1](/images/air-gradient_1.png) 
![AirGradient Monitoring Dashboard in Grafana picture 2](/images/air-gradient_2.png)

[**OpenVPN activity dashboard**](https://github.com/d3vilh/raspberry-gateway/blob/master/templates/openvpn_exporter.json.j2) and [OpenVPN-exporter](https://github.com/d3vilh/openvpn_exporter) which you can be [enable in](https://github.com/d3vilh/raspberry-gateway/blob/master/example.config.yml#L96) by setting `openvpn_monitoring_enable` option to `true`.

![OpenVPN Grafana Dashboard](/images/OVPN_Dashboard.png)

## Other features:
  - **Starlink Monitoring**: Installs a [`starlink` prometheus exporter](https://github.com/danopstech/starlink_exporter) and a Grafana dashboard, which tracks and displays Starlink statistics. (Disabled by default)
  - **Shelly Plug Monitoring**: Installs a [`shelly-plug-prometheus` exporter](https://github.com/geerlingguy/shelly-plug-prometheus) and a Grafana dashboard, which tracks and displays power usage on a Shelly Plug running on the local network. (Disabled by default. Enable and configure using the `shelly_plug_*` vars in `config.yml`.)

# Usage
  ## Portainer
   #### Portainer facts:
   * **UI access port** `http://localhost:9000/` (*change `localhost` to your Raspberry host ip/name*)
   * **Default password** will be set during the first login
   * **External ports** used by container: `8000`, `9000`

  ## Pi-hole
   #### Pi-hole facts:
   * **UI access port** `http://localhost:80/` (*change `localhost` to your Raspberry host ip/name*)
   * **Default password** is `gagaZush` it is [preconfigured in](https://github.com/d3vilh/raspberry-gateway/blob/master/example.config.yml#L14) `config.yml` file in var `pihole_password`
   * **Unbound DNS passthroe** is enabled [here](https://github.com/d3vilh/raspberry-gateway/blob/master/example.config.yml#L14) by default in `config.yml`, the option - `pihole_with_unbound: true`
   * **External ports** used by container: `53`, `67`, `80`, `443`

  > **Note**: If you would like to add Unbound functionality to Pi-Hole, you have to stop and remove old Pi-Hole setup and re-install it again.

  ## Unbound DNS Server
   #### Unbound-DNS facts:
   * **UI access port** no UI available, running in Back-End.
   * **Default password** password is not required.
   * **Pi-Hole pair** to enable, [you have to set](https://github.com/d3vilh/raspberry-gateway/blob/master/example.config.yml#L14) `pihole_with_unbound: true` in `config.yml` before the installation.
   * **External ports** used by container: `5335`
   * **Configuration file** is available after the installation and located in `~/unbound-dns/etc-unbound/unbound.conf`
   * **Advanced Configuration** can be predefined in [`advanced.config.yml`](https://github.com/d3vilh/raspberry-gateway/blob/master/advanced.config.yml#L14) before the installation

  > **Note**: If you would like to add Unbound functionality to Pi-Hole, you have to stop and remove old Pi-Hole setup and re-install it again.

  ## Technitium DNS Server
   #### Tech-DNS facts:
   * **UI access port** `http://localhost:5380/`, (*change `localhost` to your Raspberry host ip/name*)
   * **Default password** is `gagaZush` it is [preconfigured in](https://github.com/d3vilh/raspberry-gateway/blob/master/example.config.yml#L14) `config.yml` file in var `tech_dns_password`
   * **External ports** used by container: `53`, `5380`
   * **Configuration files** are available after the installation and located in `~/tech-dns/config/` directory
   * **Advanced Configuration** can be predefined in [`advanced.config.yml`](https://github.com/d3vilh/raspberry-gateway/blob/master/advanced.config.yml#L14) before the installation

  ## qBittorrent
   #### qBittorrent facts:
   * **UI access port** `http://localhost:8090/`, (*change `localhost` to your Raspberry host ip/name*)
   * **Default password** is `admin/adminadmin`, which **must** be changed via web interface on first login.
   * **External ports** used by container: `8090`, `6881:tcp`, `6881:udp`
   * **Configuration files** are available after the installation and located in `~/tech-dns/config/` directory
   * **Downloaded files** will be stored in the `~/qbittorrent/downloads` directory.
   * **Advanced Configuration** can be predefined in [`advanced.config.yml`](https://github.com/d3vilh/raspberry-gateway/blob/master/advanced.config.yml#L14) before the installation

  ## OpenVPN Server
   #### OpenVPN Server facts:
   * **UI access port** `http://localhost:8080/`, (*change `localhost` to your Raspberry host ip/name*)
   * **Default password** is `gagaZush` it is [preconfigured in](https://github.com/d3vilh/raspberry-gateway/blob/master/example.config.yml#L14) `config.yml` file in var `ovpnui_password`
   * **External ports** used by container, by default: `8080`, `1194:tcp`, `1194:udp`
   * **Configuration files** are available after the installation and located in `~/tech-dns/config/` directory
   * **Advanced Configuration** can be predefined in [`advanced.config.yml`](https://github.com/d3vilh/raspberry-gateway/blob/master/advanced.config.yml#L14) before the installation

  All the [**OpenVPN Server documentation**](https://github.com/d3vilh/raspberry-gateway/blob/master/openvpn-server/README.md) and HOW-TOs can be found [**here**](https://github.com/d3vilh/raspberry-gateway/blob/master/openvpn-server/README.md)
   > **Note**: If you are looking for x86_64 version of OpenVPN and openvpn-ui containers, please check [**openvpn-aws**](https://github.com/d3vilh/openvpn-aws)

  ## OpenVPN Client
  It is configured as a container which will automatically connect to the external OpenVPN server on startup. 
  * The OpenVPN configuration file must be located in the `~/openvpn-client` directory. You can use the [**example-client.ovpn**](https://github.com/d3vilh/raspberry-gateway/blob/master/openvpn-client/example-client.ovpn#L1) as a refference of all necessary options.
  * For authentification with user and password on top of *.ovpn, you have to put text file in `~/openvpn-client/example-credentials.txt` which must contain two lines: the first line is the username, the second line is the password, like in [refference file](https://github.com/d3vilh/raspberry-gateway/blob/master/openvpn-client/example-credentials.txt#L1). Then update `ovpn_client_secret` option of [config.yml](https://github.com/d3vilh/raspberry-gateway/blob/master/example.config.yml#L55) file with the filename containg credentials.
  * `ovpn_client_allowed_subnet: "192.168.0.0/24" ` - Your local subnet from which you want to access qBitTorrent, Pi-Hole or TechDNS WEB-UIs when VPN Client connection is active.
  * `ovpn_client_killswitch: true` - If set to `true`, it will block all the traffic when VPN is connected, except the one from the `ovpn_client_allowed_subnet` subnet.

  For more documentation and How-to, please check [**openvpn-client**](https://github.com/d3vilh/raspberry-gateway/tree/master/openvpn-client) manual.

   > **Note**: If you just looking for OpenVPN client on Raspberry-Pi or x86 PC, please check [**vpntv**](https://github.com/d3vilh/vpntv) project.

  ## WireGuard Server
  To access WireGuard Web-ui, visit the `http://localhost:5000/`, (*change `localhost` to your Raspberry host ip/name*) with default credentials - `admin/gagaZush`, it is [preconfigured in](https://github.com/d3vilh/raspberry-gateway/blob/master/example.config.yml#L53) `config.yml` file in var `wireguard_password`. Consider to change it before the installation.

  ## Raspi-monitoring
  All the Data sources, Dashboards and exporters are automatically provisioned. Below you can find the list of available dashboards and their URLs.

   ### Grafana dashboards
   To access Grafana, visit the Pi's IP address `http://localhost:3030/` (*change `localhost` to your Raspberry host ip/name*) with default credentials - `admin/admin`, it is [preconfigured in](https://github.com/d3vilh/raspberry-gateway/blob/master/example.config.yml#L82) `config.yml` file in var `monitoring_grafana_admin_password`. The `monitoring_grafana_admin_password` is only used the first time Grafana starts up; if you need to change it later, do it via Grafana's admin UI.

   #### Here is list of available dashboards:
   * **Raspberry Pi Monitoring**: Shows CPU, memory, and disk usage, as well as network traffic, temperature and Docker containers utilisation. `http://localhost:3030/d/rvk35ERRz/raspberry-monitoring`
   * **OpenVPN Monitoring**: - OpenVPN activity dashboard. `http://localhost:3030/d/58l7kyvVz/openvpn`
   * **AirGradient Monitoring** - Air quality dashboard. `http://localhost:3030/d/aglivingroom/airquality-airgradient`
   * **Starlink Monitoring**: Starlink monitoring dashboard. `http://localhost:3030/d/GG3mnflGz/starlink-overview`
   * **Shelly Plug Monitoring**: Shelly Plug dashboard. `http://localhost:3030/d/i_aeo-uMz/power-consumption`
   > **Note**: Change `localhost` to your Raspberry ip/hostname.

  If you don't see any data on dashboard - try to change the time duration to something smaller. If this does not helps - check via **Portainer UI** that all the exporters and containers are running:

  <img src="/images/portainer-run.png" alt="Running containers" width="350" border="1" />

  Then debug **Prometheus targets** described in next partagraph.

  ### Prometheus
  Prometheus is available on `http://localhost:9090/` (*change `localhost` to your Raspberry host ip/name*). It is used to collect metrics from exporters and provide them to Grafana.
  Targets status can be checked on `http://localhost:9090/targets`.

   #### Here is list of available exporters/targets:

   * **Node exporter** - Standard Linux server monitoring (CPU,RAM,I/O,FS,PROC). `http://nodeexp:9100/metrics`
   * **cAdvisor exporter** - Docker containers monitoring. `http://cadvisor:8080/metrics`
   * **rpi_exporter** - RaspberryPI HW monitoring. `http://rpi_exporter:9110/metrics`
   * **Speedtest exporter** - Up/down speed and latency. `http://speedtest:9798/metrics` 
   * **Blackbox exporter** - Desired sites avilability. `http://ping:9115/probe`
   * **OpenVPN exporter** - OpenVPN activity monitoring. `http://ovpn_exporter:9176/metrics`
   * **AirGradient exporter** - AirQuality monitoring. `http://remote-AirGradient-ip:9926/metrics`
   * **PiKVM exporter** - PiKVM utilisation and temp monitoring. `https://remote-PiKVM-ip/api/export/prometheus/metrics`
   * **Starlink exporter** - Starlink monitoring. `http://starlink:9817/metrics`
   * **Shelly exporter** - Shelly Plug power consumption monitoring. `http://shelly:9924/metrics`

## Дякую and Kudos to all the envolved peole

Kudos to @vegasbrianc for [super easy docker](https://github.com/vegasbrianc/github-monitoring) stack used to build this project.
Kudos to @maxandersen for making the [Internet Monitoring](https://github.com/maxandersen/internet-monitoring) project, which was forked to extend its functionality and now part of **Raspi-monitoring**.
Kudos to folks maintaining [**Pi-hole**](https://pi-hole.net), [**Technitium-dns**](https://technitium.com/dns/), [**qBittorrent**](https://www.qbittorrent.org), [**Portainer**](https://www.portainer.io), [**wireguard-ui**](https://github.com/ngoduykhanh/wireguard-ui), [**cAdviser**](https://github.com/d3vilh/cadvisor) and other pieces of software used in this project.

**Grand Kudos** to Jeff Geerling aka [@geerlingguy](https://github.com/geerlingguy) for all his efforts to keep us interesting in Raspberry Pi compiters and for [all his videos on youtube](https://www.youtube.com/c/JeffGeerling). Like and subscribe.