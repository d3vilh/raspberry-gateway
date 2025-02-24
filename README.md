![Raspberry Gateway Logo](/images/Raspberry-Gateway-logo.png) 
**Raspberry-Gateway** provides a simple but powerful solution for managing your home internet gateway using a Raspberry Pi. This project includes a range of Docker containers, each serving a specific purpose to enhance your internet experience:

  * [**Portainer**](https://www.portainer.io) a lightweight universal management GUI for all Docker containers which included into this project. 
  * [**Unbound DNS**](https://nlnetlabs.nl/projects/unbound/about/) is the validating, recursive and caching DNS resolver. Designed to be fast and lean.
  * [**Pi-hole**](https://pi-hole.net) network-wide ad-blocking and local DNS solution. Can be paried with Unbound.
  * [**Technitium-dns**](https://technitium.com/dns/) is the self host DNS server to block ads & malware at DNS level for your network.
  * [**OpenVPN Server**](https://github.com/d3vilh/raspberry-gateway/tree/master/openvpn-server/openvpn-docker) with simple [**WEB UI**](https://github.com/d3vilh/openvpn-ui) and VPN subnets support. 
  * [**OpenVPN Client**](https://github.com/d3vilh/raspberry-gateway/tree/master/openvpn-client) for qBittorrent connection to the external VPN server.
  * [**GlueTun**](https://github.com/qdm12/gluetun) - universal OpenVPN and Wireguard client for multiple VPN providers, using DNS over TLS and a few proxy servers built-in.
  * [**WireGuard Server**](https://github.com/d3vilh/raspberry-gateway/tree/master/wireguard) with own WEB UI for easy management. 
  * [**Xray Server**](https://github.com/d3vilh/raspberry-gateway/blob/master/xray/README.md) with experimental Shadowsocks and XTLS-Reality fast tunnel proxy that helps you to bypass firewalls. 
  * [**Rustdesk OSS Server**](https://rustdesk.com) is a remote desktop software that allows you to connect to a remote computer from anywhere in the world. It is an alternative to TeamViewer, AnyDesk, and Chrome Remote Desktop.
  * [**qBittorrent**](https://www.qbittorrent.org) -  an open-source software alternative to µTorrent. 
  * [**Grafana Dashboards**](https://github.com/d3vilh/raspberry-gateway/tree/master/monitoring) for Internet speed, VPN, Raspberry Pi hardware and Docker containers monitoring. 
  * **Various Prometheus exporters**: cAdviser, AirGradient, StarLink, ShellyPlug and others. 

Overall, this Raspberry Pi Home Internet Gateway provides a universal solution for managing and monitoring your home internet enviroment with joy and ease.

[![latest version](https://img.shields.io/github/v/release/d3vilh/raspberry-gateway?color=%2344cc11&label=Latest%20release&style=for-the-badge)](https://github.com/d3vilh/raspberry-gateway/releases/latest)
# Requirements
  - [**Raspberry Pi 4**](https://www.raspberrypi.com/products/raspberry-pi-4-model-b/), [**Raspberry Pi CM4**](https://www.raspberrypi.com/products/compute-module-4/?variant=raspberry-pi-cm4001000) **and** [**CM4 I/O Board**](https://www.raspberrypi.com/products/compute-module-4-io-board/) or [**Raspberry Pi 3**](https://www.raspberrypi.com/products/raspberry-pi-3-model-b-plus/) board, with 1-2Gb RAM.
  - [**Raspberry Pi Imager**](https://www.raspberrypi.com/software/) to simplify installation of Raspberry Pi OS Lite (x64 or i686 bit).
  - [**Raspios Lite (64bit)**](https://downloads.raspberrypi.org/raspios_lite_arm64/images/) however is recommended for this setup.
  - **16Gb SD Card**
    > **Note**: You can run it on CM4 board with 8Gb eMMC card. Full installation on top of latest [Raspios lite (64bit)](https://downloads.raspberrypi.org/raspios_lite_arm64/images/) will use 4,5Gb of your eMMC card. Raspberry Pi **Zero-W** or **W2** boards can also be used, but it's important to note that they lack an internal Ethernet adapter and have limited CPU and RAM resources. This can restrict the number of containers that can be run and the number of clients that can connect to the VPN server.

# Installation
  1. Install dependencies:
     ```shell 
     sudo apt-get install -y git python3-pip musl-tools
     ```
  2. Install [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) with pip, as yum repo version is to old:
     ```shell
     sudo pip install --upgrade pip --break-system-packages && sudo pip install ansible --break-system-packages
     ```
     We need to use `--break-system-packages` to install *Ansible core 2.18.1* with propper `community.docker-compose-v2` support.
  3. Clone this repository: 
     ```shell
     git clone https://github.com/d3vilh/raspberry-gateway
     ```
  4. Then enter the repository directory: 
     ```shell 
     cd raspberry-gateway
     ```
  5. Install requirements: 
     ```shell
     ansible-galaxy collection install -r requirements.yml
     ```
     > **Note**: If you see `ansible-galaxy: command not found`, you have to relogin (or reboot your Pi) and then try again.
  <details>
    <summary>Continue Installation with WebUI</summary>

  6. Run [Webinstall](https://github.com/d3vilh/raspberry-gtw-webconfig) binary:
     ```shell
     secret@rpgw:~/raspberry-gateway $ sudo ./webinstall # Supports now both legacy Pi4_x64 and Pi5_x64
     2023/07/07 18:01:03 Welcome! The web interface will guide you on installation process.
     Installation logs: webinstall.log
     2023/07/07 18:01:03 Starting web server on http://10.10.10.18:8088
     ```
  7. Copy server address (`http://10.10.10.18:8088` as above example) from the console and paste into your browser, then press Enter. Raspberry-Gateway webinstall window will appear:
     ![Webinstall picture 1](/images/Webinstall-01.png)
  8. Choose all the components you would like to install and change all the passwords (keep them in mind). 
     > **Note**: You can leave all the passwords as default, but it's not recommended.
  9. Press "Save" button. When your configuration is ready:
     ![Webinstall picture 2](/images/Webinstall-02.png)
  10. Then press "Install" button. It will initiate installation in background:
     ![Webinstall picture 3](/images/Webinstall-03.png)
  11. The installation process will take some time.
      Once that's done, it'll be like you have a new **Raspberry Gateway** up and running.
  * #### Additional options:
    * **To Remove** any of previously installed component - click `Uninstall "component"` checkbox then `save` configuration file and press `Uninstall` button.
    * **To set Default options** for the next `webinstall` run - modify `example.config.yml` with the default parameters. 
    * Default **Ansible parameters**, such as `ansible_user` can be set in `example.inventory.yml` file.
  </details>

  Afraid of GUI? Need more control?

  <details>
    <summary>Install everything with CLI</summary>

  5. Make copies of the configuration files and modify them for your enviroment:
      ```shell
      yes | cp -p example.inventory.yml inventory.yml 
      yes | cp -p example.config.yml config.yml
      ```
  6. **Double check** that `ansible_user` is correct for `inventory.yml`. Need to run installtion on the remote server - follow the recomendations in config file.
     
     > **Note**: To make all necesary changes: `nano inventory.yml`, save the file - `Ctrl+O` and `Ctrl+X` to exit.
  7. Modify `config.yml` to **enable** or **disable** desired containers to be installed on your Pi.
     For example, to **enable** Portainer - change `enable_portainer: false` option to `enable_portainer: true` and vs to disable.
     > **Note**: Default configuration options in the list below are **bold**.
      <details>
      <summary>List of available configuration options</summary>

      * **Portainer** 
         * `portainer_enable: true` or `false` - to install Portainer, the Web-ui for Docker. Default **true**.
         * `remove_portainer: true` or `false` - to uninstall Portainer. Default **false**.

      * **Unbound DNS**
         * `unbound_dns_enable: true` or `false` - to install Unbound DNS, the fast and lean DNS. Default **true**. Beaware that Unbound DNS is not compatible with Techtitium DNS as they both use port 53.
         * `remove_unbound_dns: true` or `false` - to uninstall Unbound DNS. Default **false**.
         * `additional parameters` - in `config.yml` you'll see lot of additional parameters with default values. You can change them if you know what you are doing. Short description of each parameter is available in the same file.

      * **Pi-Hole** 
         * `pihole_enable: true` or `false` - to install Pi-Hole. Default **true**. Beaware that Pi-Hole is not compatible with Technitium DNS as they both use port 53.
         * `remove_pihole: false` or `true` - to uninstall Pi-Hole. Default **false**.
         * `pihole_inside_vpn: false` or `true` - configure Pi-Hole to use your [OpenVPN Client](https://github.com/d3vilh/raspberry-gateway/tree/master/openvpn-client) subnet instead of public Internet.
         * `pihole_password` - password for Pi-Hole WEB UI. Default **"gagaZush"**.

      * **Technitium DNS** 
         * `tech_dns_enable: false` or `true` - to install Technitium DNS. Default **false**. Beaware that Technitium DNS is not compatible with Pi-Hole and Unbound DNS as they use port 53 as well.
         * `remove_tech_dns: false` or `true` - to uninstall Technitium DNS. Default **false**.
         * `tech_dns_password` - password for Technitium DNS WEB UI. Default **"gagaZush"**.
         * `tech_dns_inside_vpn: false` or `true` - configure Technitium DNS to use your [OpenVPN Client](https://github.com/d3vilh/raspberry-gateway/tree/master/openvpn-client) subnet instead of public Internet.
         * `additional parameters` - in `config.yml` you'll see lot of additional parameters with default values. You can change them if you know what you are doing. Short description of each parameter is available in the same file.

      * **OpenVPN Server** 
         Advanced **OpenVPN Server** documentation and configuration examples is [here](https://github.com/d3vilh/raspberry-gateway/blob/master/openvpn-server/README.md).
         * `ovpn_server_enable: false` or `true` - to install OpenVPN Server. Default **false**.
         * `remove_ovpn_server: false` or `true` - to uninstall OpenVPN Server. Default **false**.
         * `ovpnui_user` - username for OpenVPN WEB UI. Default **"admin"**.
         * `ovpnui_password` - password for OpenVPN WEB UI. Default **"gagaZush"**.
         * `additional parameters` - in `config.yml` you'll see lot of additional parameters with default values. You can change them if you know what you are doing. Short description of each parameter is available in the same file.

      * **OpenVPN Client** 
         Advanced **OpenVPN Client** documentation with configuration examples is [here](https://github.com/d3vilh/raspberry-gateway/blob/master/openvpn-client/README.md).
         * `ovpn_client_enable: false` or `true` - to install OpenVPN Client. Default **false**.
         * `remove_ovpn_client: false` or `true` - to uninstall OpenVPN Client. Default **false**.
         * Put your OpenVPN connection profile `*.ovpn` into `openvpn-client` directory before installation and update its name in `ovpn_client_cert: "your-client.ovpn"` option before installation. Default **"webinstall-client.ovpn"**.
         * `ovpn_client_secret: "file with client secrets"` - filename with your OpenVPN connection profile user and password if you have any. Default **"webinstall-credentials.txt"**.
         * `ovpn_client_allowed_subnet: "your home wifi subnet/mask" ` - your local subnet from which you want to access qBitTorrent web-ui when VPN Client connection is active. Default **"192.168.88.0/24"**.
         * `ovpn_client_killswitch: false` or `true` - block all traffic if ovpn-client is down. Default **true**.

      * **Gluetun**
         * `gluetun_vpnclient_enable: false` or `true` - to install Gluetun VPN Client. Default **false**.
         * `remove_gluetun_vpnclient: false` or `true` - to uninstall Gluetun VPN Client. Default **false**.
         * `additional parameters` - in `config.yml` you'll see lot of additional parameters with default values. You can change them if you know what you are doing. Short description of each parameter is available in the same file.

      * **WireGuard Server** 
         * `wireguard_server_enable: false` or `true` - to install WireGuard Server. Default **false**.
         * `remove_wireguard: false` or `true` - to uninstall WireGuard Server. Default **false**.
         * `wireguard_password` - password for WireGuard WEB UI. Default **"gagaZush"**.
         * `wireguard_user` - username for WireGuard WEB UI. Default **"admin"**.
         * `wireguard_serverurl` - URL for WireGuard WEB UI. Default **"wg.example.com"**.

      * **qBitTorrent** 
         * `qbittorrent_enable: false` or `true` - to install qBitTorrent. Default **false**.
         * `remove_qbittorrent: false` or `true` - to uninstall qBitTorrent. Default **false**.
         * `qbittorrent_inside_vpn: false` or `true` - configure qBittorrent to use your [OpenVPN Client](https://github.com/d3vilh/raspberry-gateway/tree/master/openvpn-client) subnet instead of public Internet. Dont forget to endable OpenVPN Client installation as well.
         * `qbittorrent_inside_gluetun: false` or `true` - configure qBittorrent to use your Gluetun VPN Client subnet instead of public Internet. Dont forget to endable Gluetun installation as well.
         * `qbittorrent_webui_port: "8090"` - qBittorrent WEB UI port. Keept is default **"8090"**.

      * **Raspberry Monitoring** 
        Advanced **Raspberry Monitoring** documentation is [here](https://github.com/d3vilh/raspberry-gateway/blob/master/monitoring/README.md).
         * **General Monitoring parameters:**
           * `monitoring_enable: true` or `false` - to install Raspberry Monitoring. Default **true**.
           * `remove_monitoring: false` or `true` - to uninstall Raspberry Monitoring. Default **false**.
           * `monitoring_grafana_admin_password` - password for Grafana WEB UI. Default **"gagaZush"**.
           * `monitoring_days_keep_interval: "90d"` - how long to keep data in Prometheus DB. Default **"90d"**.
           * `monitoring_speedtest_interval: "1h"` - how often to run speedtest. Default **"60m"**.
           * `monitoring_ping_interval: "1m"` - how often to run ping tests. Default **"30s"**.
         * **OpenVPN Monitoring:**
           * `openvpn_monitoring_enable: true` or `false` - install **OpenVPN** monitoring dashboard. Default **false**.
           * `remove_openvpn_monitoring: false` or `true` - to uninstall OpenVPN monitoring dashboard. Default **false**.
         * **PiKVM Monitoring:**
           * `pikvm_monitoring_enable: true` or `false` - install **Pi-KVM** monitoring dashboard. Default **false**.
           * `remove_pikvm_monitoring: false` or `true` - to uninstall Pi-KVM monitoring dashboard. Default **false**.
           * `pikvm_target_ip: "PiKVM IP"` - Pi-KVM IP address to gather statistics from. Default **"192.168.88.3"**.
           * `pikvm_web_user: "admin"` - Pi-KVM side preconfigured Web-UI username. Default **"admin"**.
           * `pikvm_web_password` - Pi-KVM side preconfigured Web-UI password. Default **"gagaZush"**.
         * **AirGradient Monitoring:**
           * `airgradient_monitoring_enable: true` or `false` - install **AirGradient** monitoring dashboard. Default **false**.
           * `remove_airgradient_monitoring: false` or `true` - to uninstall AirGradient monitoring dashboard. Default **false**.
           Complete your **AirGradient** monitoring configuration in `advanced.config.yml`.
         * **StarLink Monitoring:**
           * `starlink_monitoring_enable: true` or `false` - install **StarLink** monitoring dashboard. Default **false**.
           * `remove_starlink_monitoring: false` or `true` - to uninstall StarLink monitoring dashboard. Default **false**.
           * `starlink_ip: "StarLink IP"` - StarLink IP address to get statistics from. Default **"10.10.10.1"**.
           * `starlink_port: "9817"` - StarLink port to get statistics from. Default **"9817"**.
         * **ShellPlug Monitoring:**
           * `shellyplug_monitoring_enable: true` or `false` - install **ShellyPlug** monitoring dashboard. Default **false**.
           * `remove_shelly_plug_monitoring: false` or `true` - to uninstall ShellyPlug monitoring dashboard. Default **false**.
           * `shelly_plug_hostname: "ShellyPlug IP"` - ShellyPlug IP address or hostname to get statistics from. Default **"server-room-shelly"**
           * `shelly_ip: "ShellyPlug IP"` - ShellyPlug IP address to get statistics from. Default **"192.168.88.66"**.
           * `shelly_port: "ShellyPlug Port"` - ShellyPlug port to get statistics from. Default **"9924"**.
           * `shelly_plug_http_username` - ShellyPlug HTTP username. Default **"admin"**.
           * `shelly_plug_http_password` - ShellyPlug HTTP password. Default **"gagaZush"**.

      * **Xray Server**
         Advanced **Xray Server** documentation and configuration examples is [here](https://github.com/d3vilh/raspberry-gateway/blob/master/xray/README.md).
         * `xray_enable: false` or `true` - to install XRAY Server. Default **false**.
         * `remove_xray: false` or `true` - to uninstall XRAY Server. Default **false**.
      </details>

  8. Modify **advanced configuration** options in `advanced.config.yml` if you desire to use additional Monitoring features, such as Telegram bot for notifications, to share your Grafana dashboard over Internet, to tune hosts to ping or set AirGradient monitoring parameters.
  9. Run installation playbook: 
     ```shell
     ansible-playbook main.yml
     ```
     > **Note**: **If running locally on the Pi**: You may have error like `Error while fetching server API version`. You have to relogin to your Pi and then run the playbook again.

  </details>
  
# Features
[**Pi-hole**](https://pi-hole.net) or [**Technitium-dns**](https://technitium.com/dns/) as the network-wide ad-blocking solution integrated with own local DNS and DHCP servers:

<p align="center">
<img src="/images/Pi-hole.1.png" alt="Pi-hole" width="410"><img src="/images/Technitium-dns.1.png" alt="Technitium" width="410">
</p>

[**OpenVPN Server**](https://openvpn.net) with subnets support and [**openvpn-ui**](https://github.com/d3vilh/openvpn-ui) as fast and lightweight web administration interface or
[**WireGuard**](https://www.wireguard.com) server - an extremely simple yet fast and modern VPN with own web administration interface:
<p align="center">
<img src="/images/OpenVPN-UI-Home.1.png" alt="OpenVPN WEB UI" width="410"><img src="/images/WireGuard-UI-Home.1.png" alt="WireGuard WEB UI" width="410">
</p>
<p align="center">
<img src="/images/OVPN_VLANs.png" alt="OpenVPN Server Subnets" width="600">
</p>

[**OpenVPN Client**](https://github.com/d3vilh/raspberry-gateway/tree/master/openvpn-client) container for using external OpenVPN server connection for selected containers of this project.
> **Note**: qBitTorrent can be configured to use OpenVPN Client or Gluetun connection to download torrents the way your ISP will not recognize!

[**GlueTun**](https://github.com/qdm12/gluetun) container as universal VPN client for using with multiple commercial VPN providers and built-in DNS over TLS, with a few proxy servers.

[**Xray Server**](https://github.com/d3vilh/raspberry-gateway/blob/master/xray/README.md) container, with experimental Shadowsocks and XTLS-Reality fast tunnel proxy that helps you to bypass firewalls.

<p align="center">
<img src="/images/XRAY-Dashboard1.png" alt="Xray Dashboard" height="358"><img src="/images/XRAY-Dashboard2.png" alt="Xray Inbounds" height="358">
</p>

[**qBittorrent**](https://www.qbittorrent.org) an open-source software alternative to µTorrent, with lightweight web administration interface:

![qBittorrent WEB UI](/images/qBittorrent-web-ui.png)

[**Portainer**](https://www.portainer.io) is a lightweight *universal* management interface that can be used to easily manage containers and environment which included in this setup:

![Portainer](/images/portainer.png)

[**Rustdesk OSS Server**](https://rustdesk.com) is a remote desktop software that allows you to connect to a remote computer from anywhere in the world. It is an alternative to TeamViewer, AnyDesk, and Chrome Remote Desktop.

![RustDesktop Client UI](/images/RustDesktop.png)

[**Raspi Monitoring**](https://github.com/d3vilh/raspberry-gateway/tree/master/monitoring) The simple yet powerfull monitoring solution for your Raspberry Gateway. Covers performance utilisation (CPU,MEM,I/O, storage usage), Hardware utilisation (Temperature, Voltage, Power States, Devices Clock), Docker containers statistics and Internet connection monitoring:

![Raspberry Monitoring Dashboard in Grafana picture 1](/images/raspi-monitoring_1.png) 
![Raspberry Monitoring Dashboard in Grafana picture 2](/images/raspi-monitoring_2.png) 
![Raspberry Monitoring Dashboard in Grafana picture 3](/images/raspi-monitoring_3.png) 
![Raspberry Monitoring Dashboard in Grafana picture 4](/images/raspi-monitoring_4.png) 
![Raspberry Monitoring Dashboard in Grafana picture 5](/images/raspi-monitoring_5.png) 
![Raspberry Monitoring Dashboard in Grafana picture 6](/images/raspi-monitoring_6.png) 

[**AirGradient Monitoring**](https://www.airgradient.com/diy): Accurate and Open Air Quality Monitoring Dashboard:

![AirGradient Monitoring Dashboard in Grafana picture 1](/images/air-gradient_1.png) 
![AirGradient Monitoring Dashboard in Grafana picture 2](/images/air-gradient_2.png)

## Other features:
  - [**OpenVPN activity dashboard**](https://github.com/d3vilh/raspberry-gateway/blob/master/templates/openvpn_exporter.json.j2) and [OpenVPN-exporter](https://github.com/d3vilh/openvpn_exporter) which shows OpenVPN client connetions status, duration and consumed traffic.
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

  > **Note**: If you would like to add Unbound functionality to Pi-Hole, you have to stop and remove old Pi-Hole setup and re-install it again.

  ## Unbound DNS Server
   #### Unbound-DNS facts:
   * **UI access port** no UI available, running in Back-End.
   * **Default password** password is not required.
   * **Pi-Hole pair** to disable, [you have to set](https://github.com/d3vilh/raspberry-gateway/blob/master/example.config.yml#L30) `pihole_with_unbound: false` in `config.yml` before the installation.
   * **External ports** used by container: `5335:tcp`, `5335:udp`
   * **Configuration file** is available after the installation and located in `~/unbound-dns/etc-unbound/unbound.conf`

  > **Note**: If you would like to add Unbound to the existent Pi-Hole setup, you have to stop and remove old Pi-Hole container and re-install it again alltogeather with Unbound and necessary options enabled.

  ## Technitium DNS Server
   #### Tech-DNS facts:
   * **UI access port** `http://localhost:5380/`, (*change `localhost` to your Raspberry host ip/name*)
   * **Default password** is `gagaZush` it is [preconfigured in](https://github.com/d3vilh/raspberry-gateway/blob/master/example.config.yml#L39) `config.yml` file in the `tech_dns_password` var
   * **External ports** used by container: `5380:tcp`, `53:tcp`, `53:udp`
   * **Configuration files** are available after the installation and located in `~/tech-dns/config/` directory

  ## qBittorrent
   #### qBittorrent facts:
   * **UI access port** `http://localhost:8090/`, (*change `localhost` to your Raspberry host ip/name*)
   * **Default password** is `admin/adminadmin`, which **must** be changed via web interface on first login.
   * **External ports** used by container: `8090:tcp`, `6881:tcp`, `6881:udp`
   * **Configuration files** are available after the installation and located in `~/qbittorrent/config/qBittorrent/` directory
   * **Downloaded files** will be stored in the `~/qbittorrent/downloads` directory.

  > **Note**: To prove you are **connected via VPN** run this command `sudo docker exec qbittorrent wget -qO - ifconfig.me` it should return your VPN IP address.

  ## OpenVPN Server
   #### OpenVPN Server facts:
   * **UI access port** `http://localhost:8080/`, (*change `localhost` to your Raspberry host ip/name*)
   * **Default password** is `gagaZush` it is [preconfigured in](https://github.com/d3vilh/raspberry-gateway/blob/master/example.config.yml#L48) `config.yml` file in the `ovpnui_password` var
   * **External ports** used by containers, by default: `8080:tcp`, `1194:tcp`, `1194:udp`
   * **Configuration files** are available after the installation and located in `~/openvpn-server/*` directory

  All the [**OpenVPN Server configuration**](https://github.com/d3vilh/raspberry-gateway/blob/master/openvpn-server/README.md) and Knowhow for this setup can be found [**here**](https://github.com/d3vilh/raspberry-gateway/blob/master/openvpn-server/README.md).
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
  > **Note**: To prove you are **connected via VPN** run this command `sudo docker exec openvpn-client wget -qO - ifconfig.me` it should return your VPN IP address.

  For more documentation and How-to, please check dedicated [**openvpn-client README.md**](https://github.com/d3vilh/raspberry-gateway/tree/master/openvpn-client) file.

   > **Note**: If you just looking for all purpose OpenVPN client for Raspberry-Pi or x86 PC, please check [**vpntv**](https://github.com/d3vilh/vpntv) project.

  ## Gluetun VPN Client
   #### Gluetun Client facts:
   * **UI access port** no UI available, running in Back-End
   * **Default password** password is not required
   * **External ports** `8888/tcp` as HTTP proxy, `8388/tcp`&`8388/udp` for Shadowsocks
   * **Configuration files** are available after the installation and located in `~/openvpn-client/*` directory. 
   * **Configuration Options** which necessary for the installation (defined in `config.yml` file)`):
     * `gluetun_vpn_service_provider` - is your VPN service provider (expressvpn, ivpn, nordvpn, protonvpn, surfshark, etc.) full list of supported providers [available here](https://github.com/qdm12/gluetun-wiki/tree/main/setup/providers). 
     * `gluetun_openvpn_user` - is your OpenVPN user provided by VPN provider
     * `gluetun_openvpn_password` - is your OpenVPN password, provided by VPN provider
     * `gluetun_server_countries` -  is comma separated list of countries
     * `gluetun_server_update_per` - is period to update your servers list using the built-in Gluetun update mechanisms (curently hardcoded to 24h)

  ## WireGuard Server
   #### WireGuard facts:
   * **UI access port** `http://localhost:5000/`, (*change `localhost` to your Raspberry host ip/name*)
   * **Default password** is `gagaZush` it is [preconfigured in](https://github.com/d3vilh/raspberry-gateway/blob/master/example.config.yml#L61) `config.yml` file in the `wireguard_password` var
   * **External ports** used by container: `5000:tcp`, `6881:tcp`, `6881:udp`
   * **Configuration files** are available after the installation and located in `~/tech-dns/config/` directory

  ## Xray Server
  **Main Documentation** and Configuration examples is [here](https://github.com/d3vilh/raspberry-gateway/blob/master/xray/README.md).
  
   #### Xray facts:
   * **UI access port** `http://localhost:54321`, (*change `localhost` to your Raspberry host ip/name*)
   * **Default password** is `admin/admin`, which **must** be changed via web interface on first login (`Pannel Settings` > `User Settings`).
   * **External ports** used by container: `443:tcp`, `80:tcp`, `54321:tcp`(by default)
   * **Configuration files** are available after the installation and located in `~/xray/` directory
   * **It is Important** to change following settings for better security:
     * default password in `Pannel Settings` > `User Settings` > `Password` to something strong and secure.
     * default pannel port in `Pannel Settings` > `Pannel Configurations` > `Pannel Port` from `54321` to some random port (the best in the upper end of the range, up to `65535`)
     * default configuration pannel URL in `Pannel Settings` > `Pannel Configurations` > `Panel URL Root Path` to something random, like `/mysecretpannel/` or `/superxray/`.

  ## Rustdesk Server
   #### Rustdesk facts:
   * **UI access port** No UI available in [OSS version](https://rustdesk.com/docs/en/self-host/rustdesk-server-pro/console/), running in Back-End.
   * **Default password** Use public key from configuration files.
   * **External ports** used by container in host mode: `21115:tcp` (Relay) `21116:tcp/udp` (ID Registration), `21117:tcp` (WebRTC Hole punching).
   * **Configuration files** are available after the installation and located in `~/rustdesk-server/*` directory
   Publik Key is located in `~/rustdesk-server/data/id_ed*.pub` file. 
   You need it to [configure](https://rustdesk.com/docs/en/client/) your [Rustdesk clients](https://rustdesk.com/download) sides:
     ```shell
     pi@d3vpi:~ $ cat ~/rustdesk-server/data/id_ed*.pub
     bvij9KsmajenaOdt9AazKURKAtnz1FLBGt8+5goUK4WZs=
     ```

  ## Raspberry-monitoring
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
     > **Note 1**: You have to configure your AirGradient device in `advanced.config.yml` before the installation.
     > **Note 2**: Your AirGradient device **must** have alternative [airgradient-improved](https://github.com/d3vilh/airgradient-improved) firmware flashed into EEPROM to support this feature.
   * **Starlink Monitoring**: Starlink monitoring dashboard. `http://localhost:3030/d/GG3mnflGz/starlink-overview`
   * **Shelly Plug Monitoring**: Shelly Plug dashboard. `http://localhost:3030/d/i_aeo-uMz/power-consumption`
   > **Note**: Change `localhost` to your Raspberry ip/hostname.

  If you don't see any data on the dashboard - try to change the time duration to something smaller. If this does not help - check via **Portainer UI** that all the exporters and containers are running:

  <img src="/images/portainer-run.png" alt="Running containers" width="350" border="1" />

  Then debug **Prometheus targets** described in the next partagraph.

  ### Prometheus
   Used for metrics collection from exporters, storing data and provide it to Grafana dashboards.
   * **UI access port** `http://localhost:9090/`, (*change `localhost` to your Raspberry host ip/name*)
   * **Default password** password is not set by default!
   * **External ports** used by container: `9090:tcp`, various exporters ports (see below)
   * **Configuration files** are available after the installation and located in `~/monitoring/prometeus/` directory
   * **Targets** can be checked on `http://localhost:9090/targets` (*you know what2do with `localhost`* 🧐)

   #### Here is list of available exporters/targets:

   * [**Node exporter**](https://github.com/d3vilh/raspberry-gateway/blob/master/templates/prometheus.yml.j2#L88) - Standard Linux server monitoring (CPU,RAM,I/O,FS,PROC). `http://nodeexp:9100/metrics`
   * [**cAdvisor exporter**](https://github.com/d3vilh/raspberry-gateway/blob/master/templates/prometheus.yml.j2#L98) - Docker containers monitoring. `http://cadvisor:8080/metrics`
   * [**rpi_exporter**](https://github.com/d3vilh/raspberry-gateway/blob/master/templates/prometheus.yml.j2#L92) - RaspberryPI HW monitoring. `http://rpi_exporter:9110/metrics`
   * [**Speedtest exporter**](https://github.com/d3vilh/raspberry-gateway/blob/master/templates/prometheus.yml.j2#L13) - Up/down speed and latency. `http://speedtest:9798/metrics` 
   * [**Blackbox exporter**](https://github.com/d3vilh/raspberry-gateway/blob/master/templates/prometheus.yml.j2#L66) - Desired sites avilability. `http://ping:9115/probe`
   * [**OpenVPN exporter**](https://github.com/d3vilh/raspberry-gateway/blob/master/templates/prometheus.yml.j2#L33) - OpenVPN activity monitoring. `http://ovpn_exporter:9176/metrics`
   * [**AirGradient exporter**](https://github.com/d3vilh/raspberry-gateway/blob/master/templates/prometheus.yml.j2#L49) - AirQuality monitoring. `http://remote-AirGradient-ip:9926/metrics`
   * [**PiKVM exporter**](https://github.com/d3vilh/raspberry-gateway/blob/master/templates/prometheus.yml.j2#L20) - PiKVM utilisation and temp monitoring. `https://remote-PiKVM-ip/api/export/prometheus/metrics`
   * [**Starlink exporter**](https://github.com/d3vilh/raspberry-gateway/blob/master/templates/prometheus.yml.j2#L59) - Starlink monitoring. `http://starlink:9817/metrics`
   * [**Shelly exporter**](https://github.com/d3vilh/raspberry-gateway/blob/master/templates/prometheus.yml.j2#L41) - Shelly Plug power consumption monitoring. `http://shelly:9924/metrics`

## Дякую and Kudos to all the envolved people:
  * [**Max Rydahl Andersen**](https://github.com/maxandersen) for the [Internet Monitoring](https://github.com/maxandersen/internet-monitoring).
  * [**Ryan Armstrong**](https://github.com/cavaliercoder) for [rpi-exporter](https://github.com/cavaliercoder/rpi_export)
  * [**Jeff Geerling**](https://github.com/geerlingguy) aka [@geerlingguy](https://github.com/geerlingguy) for all his efforts to keep us interesting in Raspberry Pi compiters and for [all his videos on youtube](https://www.youtube.com/c/JeffGeerling). Cosider to Like and Subscribe 

### Kudos to all folks maintaining:
  * [**Pi-hole**](https://github.com/pi-hole)
  * [**Unbound DNS**](https://github.com/NLnetLabs)
  * [**Technitium-dns**](https://github.com/TechnitiumSoftware/DnsServer)
  * [**Gluetun**](https://github.com/qdm12/gluetun)
  * [**qBittorrent**](https://github.com/qbittorrent)
  * [**Portainer**](https://github.com/portainer)
  * [**wireguard-ui**](https://github.com/ngoduykhanh/wireguard-ui)
  * [**cAdviser**](https://github.com/d3vilh/cadvisor)
  * [**RustDesktop**](https://rustdesk.com) team, especially the OSS maintainers and 
  * other pieces of software used in this project.

<a href="https://www.buymeacoffee.com/d3vilh" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" height="51" width="217"></a>

May 2021, [**d3vilh**](https://github.com/d3vilh)
