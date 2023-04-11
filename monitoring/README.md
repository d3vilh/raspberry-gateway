# Raspi-monitoring

[**Raspi Monitoring**](https://github.com/d3vilh/raspberry-gateway/tree/master/raspi-monitoring) for monitor your Raspberry server utilisation (CPU,MEM,I/O, Tempriture, storage usage) and Internet connection. Internet connection statistics is based on [Speedtest.net exporter](https://github.com/MiguelNdeCarvalho/speedtest-exporter) results, ping stats and overall Internet availability tests based on HTTP push methods running by [Blackbox exporter](https://github.com/prometheus/blackbox_exporter) to the desired internet sites:

![Raspberry Monitoring Dashboard in Grafana picture 1](/images/raspi-monitoring_1.png) 
![Raspberry Monitoring Dashboard in Grafana picture 2](/images/raspi-monitoring_2.png) 
![Raspberry Monitoring Dashboard in Grafana picture 3](/images/raspi-monitoring_3.png) 
![Raspberry Monitoring Dashboard in Grafana picture 4](/images/raspi-monitoring_4.png) 
![Raspberry Monitoring Dashboard in Grafana picture 5](/images/raspi-monitoring_5.png) 
![Raspberry Monitoring Dashboard in Grafana picture 6](/images/raspi-monitoring_6.png) 

All this functionality based on [Grafana](https://grafana.com) and [Prometheus](http://prometheus.io/).
  > If you use the included Raspi Monitoring, it **will download a decently-large amount of data through your Internet connection on a daily basis**. You can completetly shutdown containers belongs to the `Raspi-monitoring stack` with **Portainer** or tune the `raspi-monitoring` setup to not run the speedtests as often.


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
   * **OpenVPN exporter** - OpenVPN activity monitoring. `http://openvpn:9176/metrics`
   * **AirGradient exporter** - AirQuality monitoring. `http://remote-AirGradient-ip:9926/metrics`
   * **PiKVM exporter** - PiKVM utilisation and temp monitoring. `https://remote-PiKVM-ip/api/export/prometheus/metrics`
   * **Starlink exporter** - Starlink monitoring. `http://starlink:9817/metrics`
   * **Shelly exporter** - Shelly Plug power consumption monitoring. `http://shelly:9924/metrics`

## Дякую and Kudos to all the envolved peole

Kudos to @vegasbrianc for [super easy docker](https://github.com/vegasbrianc/github-monitoring) stack used to build this project.
Kudos to @maxandersen for making the [Internet Monitoring](https://github.com/maxandersen/internet-monitoring) project, which was forked to extend its functionality and now part of **Raspi-monitoring**.
Kudos to folks maintaining [**Pi-hole**](https://pi-hole.net), [**Technitium-dns**](https://technitium.com/dns/), [**qBittorrent**](https://www.qbittorrent.org), [**Portainer**](https://www.portainer.io), [**wireguard-ui**](https://github.com/ngoduykhanh/wireguard-ui), [**cAdviser**](https://github.com/d3vilh/cadvisor) and other pieces of software used in this project.

**Grand Kudos** to Jeff Geerling aka [@geerlingguy](https://github.com/geerlingguy) for all his efforts to keep us interesting in Raspberry Pi compiters and for [all his videos on youtube](https://www.youtube.com/c/JeffGeerling). Like and subscribe.