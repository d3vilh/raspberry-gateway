![Raspberry Monitoring Dashboard in Grafana picture 1](/images/Raspberry-Gateway-logo.png) 
This project provides a simple yet powerful solution for managing your home internet gateway using a Raspberry Pi. The gateway includes a range of Docker containers, each serving a specific purpose to enhance your internet experience:

  * [**Portainer**](https://www.portainer.io) a lightweight *universal* management GUI for all Docker containers which included into this project. 
  * [**OpenVPN Server**](https://github.com/d3vilh/raspberry-gateway/tree/master/openvpn-server/openvpn-docker) container with OpenVPN, simple [**WEB UI**](https://github.com/d3vilh/openvpn-ui) and VPN subnets support. 
  * [**OpenVPN Client**](https://github.com/d3vilh/raspberry-gateway/tree/master/openvpn-client) container for qBittorrent connection to the external VPN server.
  * [**qBittorrent**](https://www.qbittorrent.org) -  an open-source software alternative to µTorrent. 
  * [**Pi-hole**](https://pi-hole.net) container with network-wide ad-blocking&local DNS solution. Can be paried with Unbound.
  * [**Unbound DNS**](https://nlnetlabs.nl/projects/unbound/about/) container with the validating, recursive, caching DNS resolver. Designed to be fast and lean.
  * [**Grafana Dashboards**](https://github.com/d3vilh/raspberry-gateway/tree/master/monitoring) for Internet speed, VPN, Raspberry Pi hardware and Docker containers monitoring. 
  * [**Technitium-dns**](https://technitium.com/dns/) container. Self host DNS server to block ads & malware at DNS level for your network.
  * [**WireGuard Server**](https://github.com/d3vilh/raspberry-gateway/tree/master/wireguard) container with own WEB UI. 
  * **Various Prometheus exporters**: cAdviser, AirGradient, StarLink, ShellyPlug and others. 

Overall, this Raspberry Pi Home Internet Gateway provides a comprehensive solution for managing and monitoring your home internet experience with ease.

[![latest version](https://img.shields.io/github/v/release/d3vilh/raspberry-gateway?color=%2344cc11&label=Latest%20release&style=for-the-badge)](https://github.com/d3vilh/raspberry-gateway/releases/tag/latest)
# Requirements
  - [**Raspberry Pi 4**](https://www.raspberrypi.com/products/raspberry-pi-4-model-b/), [**Raspberry Pi CM4**](https://www.raspberrypi.com/products/compute-module-4/?variant=raspberry-pi-cm4001000) **and** [**CM4 I/O Board**](https://www.raspberrypi.com/products/compute-module-4-io-board/) or [**Raspberry Pi 3**](https://www.raspberrypi.com/products/raspberry-pi-3-model-b-plus/) board, with 1-2Gb RAM.
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
  <details>
    <summary>Continue Installation with WebUI</summary>
   
   **This is still under testing!** If you afraid of it - just skip to CLI installation.

  5. Run [Webinstall](https://github.com/d3vilh/raspberry-gtw-webconfig) binary:
     ```shell
     secret@rpgw:~/raspberry-gateway $ ./webinstall
     2023/07/07 18:01:03 Welcome! The web interface will guide you on installation process.
     Installation logs: webinstall.log
     2023/07/07 18:01:03 Starting web server on http://10.10.10.18:8088
     ```
  6. Copy server address (`http://10.10.10.18:8088` as above example) from the console and paste into your browser, then press Enter. Raspberry-Gateway webinstall window will appear:
     ![Raspberry Monitoring Dashboard in Grafana picture 1](/images/Webinstall-01.png)
  7. Choose all the components you would like to install and change all the passwords (keep them in mind). 
     > **Note**: You can leave all the passwords as default, but it's not recommended.
  8. Press "Save" button. When your configuration is ready:
     ![Raspberry Monitoring Dashboard in Grafana picture 1](/images/Webinstall-02.png)
  9. Then press "Install" button. It will initiate installation in background:
     ![Raspberry Monitoring Dashboard in Grafana picture 1](/images/Webinstall-03.png)
  10. The installation process will take some time.
      Once that's done, it'll be like you have a new **Raspberry Gateway** up and running.

      You can scroll down for `Quick Links` or close browser window and anjoy your new Raspberry Gateway.
  </details>

  Afraid of GUI? Need more control?

  <details>
    <summary>Install everything with CLI</summary>
   
   **Safiest option**. Tested may times and works like a charm.

  5. Make copies of the configuration files and modify them for your enviroment:
      ```shell
      yes | cp -p example.inventory.yml inventory.yml 
      yes | cp -p example.config.yml config.yml
      ```
  6. Modify `inventory.yml` by replace of IP address with your Pi's IP, or comment that line and uncomment the `connection=local` line if you're running it on the Pi you're setting up. **Double check** that the `ansible_user` is correct for your setup.
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
  9. Run installation playbook:
     ```shell
     ansible-playbook main.yml
     ```
     > **Note**: **If running locally on the Pi**: You may have error like `Error while fetching server API version`. You have to relogin (or reboot your Pi) and then run the playbook again.
  </details>
  
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
> **Note**: qBitTorrent can be configured to use OpenVPN Client connection to download torrents the way your ISP will not recognize!

[**qBittorrent**](https://www.qbittorrent.org) an open-source software alternative to µTorrent, with lightweight web administration interface:

![qBittorrent WEB UI](/images/qBittorrent-web-ui.png)

[**Portainer**](https://www.portainer.io) is a lightweight *universal* management interface that can be used to easily manage Docker or K8S containers and environments which included in this setup:

![Portainer](/images/portainer.png)

[**Raspi Monitoring**](https://github.com/d3vilh/raspberry-gateway/tree/master/monitoring) The simple yet powerfull monitoring solution for your Raspberry server. Covers performance utilisation (CPU,MEM,I/O, Tempriture, storage usage), Hardware utilisation (Voltage, Power States, Devices Clock), Docker containers and Internet connection monitoring:

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

[**OpenVPN activity dashboard**](https://github.com/d3vilh/raspberry-gateway/blob/master/templates/openvpn_exporter.json.j2) and [OpenVPN-exporter](https://github.com/d3vilh/openvpn_exporter) which shows OpenVPN client connetions status, duration and consumed traffic:

![OpenVPN Grafana Dashboard](/images/OVPN_Dashboard.png)

## Other features:
  - [**Starlink Monitoring**](https://github.com/danopstech/starlink_exporter): For StarLink dishy tracking and statisitcs. 
  - [**Shelly Plug Monitoring**](https://github.com/geerlingguy/shelly-plug-prometheus): Tracks and displays power usage on a Shelly Plug running on the local network.

# Usage
  ## Portainer
   #### Portainer facts:
   * **UI access port** `http://localhost:9000/` (*change `localhost` to your Raspberry host ip/name*)
   * **Default password** will be set during the first login
   * **External ports** used by container: `9000:tcp`, `8000:tcp` (external API)

  ## Pi-hole
   #### Pi-hole facts:
   * **UI access port** `http://localhost:80/` (*change `localhost` to your Raspberry host ip/name*)
   * **Default password** is `gagaZush` it is [preconfigured in](https://github.com/d3vilh/raspberry-gateway/blob/master/example.config.yml#L31) `config.yml` file in `pihole_password` var
   * **Unbound DNS connection** can be [enabled in the](https://github.com/d3vilh/raspberry-gateway/blob/master/example.config.yml#L30) `config.yml`. Default option - `pihole_with_unbound: true`
   * **External ports** used by container: `80:tcp`, `443:tcp`, `53:tcp`, `53:udp`, `67:tcp`, `67:udp`
   * **Advanced Configuration** can be predefined in [`advanced.config.yml`](https://github.com/d3vilh/raspberry-gateway/blob/master/advanced.config.yml#L28) before the installation

  > **Note**: If you would like to add Unbound functionality to Pi-Hole, you have to stop and remove old Pi-Hole setup and re-install it again.

  ## Unbound DNS Server
   #### Unbound-DNS facts:
   * **UI access port** no UI available, running in Back-End.
   * **Default password** password is not required.
   * **Pi-Hole pair** to disable, [you have to set](https://github.com/d3vilh/raspberry-gateway/blob/master/example.config.yml#L30) `pihole_with_unbound: false` in `config.yml` before the installation.
   * **External ports** used by container: `5335:tcp`, `5335:udp`
   * **Configuration file** is available after the installation and located in `~/unbound-dns/etc-unbound/unbound.conf`
   * **Advanced Configuration** can be predefined in [`advanced.config.yml`](https://github.com/d3vilh/raspberry-gateway/blob/master/advanced.config.yml#L16) before the installation

  > **Note**: If you would like to add Unbound to the existent Pi-Hole setup, you have to stop and remove old Pi-Hole container and re-install it again alltogeather with Unbound and necessary options enabled.

  ## Technitium DNS Server
   #### Tech-DNS facts:
   * **UI access port** `http://localhost:5380/`, (*change `localhost` to your Raspberry host ip/name*)
   * **Default password** is `gagaZush` it is [preconfigured in](https://github.com/d3vilh/raspberry-gateway/blob/master/example.config.yml#L39) `config.yml` file in the `tech_dns_password` var
   * **External ports** used by container: `5380:tcp`, `53:tcp`, `53:udp`
   * **Configuration files** are available after the installation and located in `~/tech-dns/config/` directory
   * **Advanced Configuration** can be predefined in [`advanced.config.yml`](https://github.com/d3vilh/raspberry-gateway/blob/master/advanced.config.yml#L35) before the installation

  ## qBittorrent
   #### qBittorrent facts:
   * **UI access port** `http://localhost:8090/`, (*change `localhost` to your Raspberry host ip/name*)
   * **Default password** is `admin/adminadmin`, which **must** be changed via web interface on first login.
   * **External ports** used by container: `8090:tcp`, `6881:tcp`, `6881:udp`
   * **Configuration files** are available after the installation and located in `~/qbittorrent/config/qBittorrent/` directory
   * **Downloaded files** will be stored in the `~/qbittorrent/downloads` directory.
   * **Advanced Configuration** can be predefined in [`advanced.config.yml`](https://github.com/d3vilh/raspberry-gateway/blob/master/advanced.config.yml#L74) before the installation

  ## OpenVPN Server
   #### OpenVPN Server facts:
   * **UI access port** `http://localhost:8080/`, (*change `localhost` to your Raspberry host ip/name*)
   * **Default password** is `gagaZush` it is [preconfigured in](https://github.com/d3vilh/raspberry-gateway/blob/master/example.config.yml#L48) `config.yml` file in the `ovpnui_password` var
   * **External ports** used by containers, by default: `8080:tcp`, `1194:tcp`, `1194:udp`
   * **Configuration files** are available after the installation and located in `~/openvpn-server/*` directory
   * **Advanced Configuration** can be predefined in [`advanced.config.yml`](https://github.com/d3vilh/raspberry-gateway/blob/master/advanced.config.yml#L49) before the installation

  All the [**OpenVPN Server configuration**](https://github.com/d3vilh/raspberry-gateway/blob/master/openvpn-server/README.md) and Knowhow for this setup can be found [**here**](https://github.com/d3vilh/raspberry-gateway/blob/master/openvpn-server/README.md). It does include slides 😁
   > **Note**: If you are looking for x86_64 version of OpenVPN and openvpn-ui containers, please check [**openvpn-aws**](https://github.com/d3vilh/openvpn-aws)

  ## OpenVPN Client
   #### OpenVPN Client facts:
   * **UI access port** no UI available, running in Back-End
   * **Default password** password is not required
   * **External ports** used by container, by default: `random free port`
   * **Configuration files** are available after the installation and located in `~/openvpn-client/*` directory. 
   * **Configuration Options** necessary for the installation (defined in `config.yml` file)`):
     * `ovpn_client_cert: "example-client.opvn"` - file with your OpenVPN connection profile (`*.ovpn`). You have to put it into `~/raspberry-gateway/openvpn-client/` directory before installation and update its name in `ovpn_client_cert`. Use the [**example-client.ovpn**](https://github.com/d3vilh/raspberry-gateway/blob/master/openvpn-client/example-client.ovpn#L1) as a refference of all necessary options and file format. After the installation your `*.ovpn` file will be moved to `~/openvpn-client/*.ovpn` and used by container. If for some reason you need to change it, you have to put new file with the same name in `~/openvpn-client/` directory and restart openvpn-client container (`docker openvpn-client restart`).
     * `ovpn_client_allowed_subnet: "192.168.88.0/24" ` - Your local newtwork (WiFi or whatever), from which you want to access qBitTorrent WEB-UI when VPN Client connection is active.
   * **Advanced Configuration** can be predefined in [`advanced.config.yml`](https://github.com/d3vilh/raspberry-gateway/blob/master/advanced.config.yml#L56) before the installation:
     * `ovpn_client_secret: "filename.txt"` - filename with your OpenVPN connection profile user and password if you have any. You have to put it into `~/raspberry-gaveway/openvpn-client/` directory before installation and update its name in `ovpn_client_secret`. Use the [**example-credentials.txt**](https://github.com/d3vilh/raspberry-gateway/blob/master/openvpn-client/example-credentials.txt#L1) as refference.
     * `ovpn_client_killswitch: true` - If set to `true`, it will block all the traffic when VPN is connected, except the one from the `ovpn_client_allowed_subnet` subnet.

  For more documentation and How-to, please check dedicated [**openvpn-client README.md**](https://github.com/d3vilh/raspberry-gateway/tree/master/openvpn-client) file.

   > **Note**: If you just looking for all purpose OpenVPN client for Raspberry-Pi or x86 PC, please check [**vpntv**](https://github.com/d3vilh/vpntv) project.

  ## WireGuard Server
   #### WireGuard facts:
   * **UI access port** `http://localhost:5000/`, (*change `localhost` to your Raspberry host ip/name*)
   * **Default password** is `gagaZush` it is [preconfigured in](https://github.com/d3vilh/raspberry-gateway/blob/master/example.config.yml#L61) `config.yml` file in the `wireguard_password` var
   * **External ports** used by container: `5000:tcp`, `6881:tcp`, `6881:udp`
   * **Configuration files** are available after the installation and located in `~/tech-dns/config/` directory
   * **Advanced Configuration** Before the installation, can be predefined in [`advanced.config.yml`](https://github.com/d3vilh/raspberry-gateway/blob/master/advanced.config.yml#L65). WebUi username and WireGuard external server URL can be changed.

  ## Raspi-monitoring
  All the Data sources, Dashboards and exporters are automatically provisioned. Below you can find the list of available dashboards and their URLs.

   ### Grafana
   Used to visualize all the data provided by Prometheus.
   * **UI access port** `http://localhost:3030/`, (*change `localhost` to your Raspberry host ip/name*)
   * **Default password** is `admin/admin`, it is [preconfigured in](https://github.com/d3vilh/raspberry-gateway/blob/master/example.config.yml#L87) `config.yml` file and only used the first time Grafana starts up
   * **External ports** used by container: `3030:tcp`
   * **Configuration files** are available after the installation and located in `~/monitoring/grafana/` directory
   * **Advanced Configuration** Before the installation, can be predefined in [`advanced.config.yml`](https://github.com/d3vilh/raspberry-gateway/blob/master/advanced.config.yml#L82).

   #### Here is list of available Grafana dashboards:
   * **Raspberry Pi Monitoring**: Shows CPU, memory, and disk usage, as well as network traffic, temperature and Docker containers utilisation. `http://localhost:3030/d/rvk35ERRz/raspberry-monitoring`
   * **OpenVPN Monitoring**: - OpenVPN activity dashboard. `http://localhost:3030/d/58l7kyvVz/openvpn`
   * **AirGradient Monitoring** - Air quality dashboard. `http://localhost:3030/d/aglivingroom/airquality-airgradient`
   * **Starlink Monitoring**: Starlink monitoring dashboard. `http://localhost:3030/d/GG3mnflGz/starlink-overview`
   * **Shelly Plug Monitoring**: Shelly Plug dashboard. `http://localhost:3030/d/i_aeo-uMz/power-consumption`
   > **Note**: Change `localhost` to your Raspberry ip/hostname.

  If you don't see any data on the dashboard - try to change the time duration to something smaller. If this does not help - check via **Portainer UI** that all the exporters and containers are running:

  <img src="/images/portainer-run.png" alt="Running containers" width="350" border="1" />

  Then debug **Prometheus targets** described in the next partagraph.

  ### Prometheus
   Used to collect metrics from exporters and provide them to Grafana.
   * **UI access port** `http://localhost:9090/`, (*change `localhost` to your Raspberry host ip/name*)
   * **Default password** password is not set by default!
   * **External ports** used by container: `9090:tcp`, various exporters ports (see below)
   * **Configuration files** are available after the installation and located in `~/monitoring/prometeus/` directory
   * **Advanced Configuration** Before the installation, can be predefined in [`advanced.config.yml`](https://github.com/d3vilh/raspberry-gateway/blob/master/advanced.config.yml#L83)
   * **Targets** can be checked on `http://localhost:9090/targets` (*you know what2do with `localhost`* 🧐)

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

## Дякую and Kudos to all the envolved people:
  * [**Max Rydahl Andersen**](https://github.com/maxandersen) for the [Internet Monitoring](https://github.com/maxandersen/internet-monitoring).
  * [**Ryan Armstrong**](https://github.com/cavaliercoder) for [rpi-exporter](https://github.com/cavaliercoder/rpi_export)
  * [**Jeff Geerling**](https://github.com/geerlingguy) aka [@geerlingguy](https://github.com/geerlingguy) for all his efforts to keep us interesting in Raspberry Pi compiters and for [all his videos on youtube](https://www.youtube.com/c/JeffGeerling). Cosider to Like and Subscribe 

### Kudos to all folks maintaining:
  * [**Pi-hole**](https://pi-hole.net)
  * [**Unbound DNS**](https://nlnetlabs.nl/projects/unbound/about/)
  * [**Technitium-dns**](https://technitium.com/dns/)
  * [**qBittorrent**](https://www.qbittorrent.org)
  * [**Portainer**](https://www.portainer.io)
  * [**wireguard-ui**](https://github.com/ngoduykhanh/wireguard-ui)
  * [**cAdviser**](https://github.com/d3vilh/cadvisor) and 
  * other pieces of software used in this project.

May 2021, [**d3vilh**](https://github.com/d3vilh)
