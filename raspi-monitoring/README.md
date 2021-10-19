# Raspi-monitoring

[**Raspi Monitoring**](https://github.com/d3vilh/raspberry-gateway/tree/master/raspi-monitoring) for monitor your Raspberry server utilisation (CPU,MEM,I/O, Tempriture, storage usage) and Internet connection. Internet connection statistics is based on [Speedtest.net exporter](https://github.com/MiguelNdeCarvalho/speedtest-exporter) results, ping stats and overall Internet availability tests based on HTTP push methods running by [Blackbox exporter](https://github.com/prometheus/blackbox_exporter) to the desired internet sites:

![Raspberry Monitoring Dashboard in Grafana picture 1](/images/raspi-monitoring_1.png) 
![Raspberry Monitoring Dashboard in Grafana picture 2](/images/raspi-monitoring_2.png) 

All this functionality based on [Grafana](https://grafana.com) and [Prometheus](http://prometheus.io/).
  > If you use the included Raspi Monitoring, it **will download a decently-large amount of data through your Internet connection on a daily basis**. You can completetly shutdown containers belongs to the `Raspi-monitoring stack` with **Portainer** or tune the `raspi-monitoring` setup to not run the speedtests as often.

The DataSource and Dashboard for Raspi-monitoring are automatically provisioned.

## Grafana dashboard

is available at http://localhost:3030/d/o9mIe_Aik/Raspi-monitoring 

Login with `admin` and the password `monitoring_grafana_admin_password` you preconfigured in `config.yml`.

> Note: The `monitoring_grafana_admin_password` is only used the first time Grafana starts up; if you need to change it later, do it via Grafana's admin UI.

If you don't see any data on dashboard - try to change the time duration to something smaller. If this does not helps - check via **Portainer UI** that all the exporters containers are running:

<img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/portainer-run.png" alt="Running containers" width="350" border="1" />

Then debug **Prometheus targets** described in next partagraph.

## Prometheus

http://localhost:9090/targets shows status of monitored targets as seen from prometheus - in this case which hosts being pinged and speedtest. note: speedtest will take a while before it shows as UP as it takes about 30s to respond.

http://localhost:9090/graph?g0.expr=probe_http_status_code&g0.tab=1 shows prometheus value for `probe_http_status_code` for each host. You can edit/play with additional values. Useful to check everything is okey in prometheus (in case Grafana is not showing the data you expect).

http://localhost:9115 blackbox exporter endpoint. Lets you see what have failed/succeded.

http://localhost:9798/metrics speedtest exporter endpoint. Does take about 30 seconds to show its result as it runs an actual speedtest when requested.

### Configuration

To change what hosts you ping you change the `targets` section in [/prometheus/pinghosts.yaml](./prometheus/pinghosts.yaml) file.

For speedtest the only relevant configuration is how often you want the check to happen. It is at 30 minutes by default which might be too much if you have limit on downloads. This is changed by editing `scrape_interval` under `speedtest` in [/prometheus/prometheus.yml](./prometheus/prometheus.yml).

## Kudos and Дякую to the original authorts

Kudos to @maxandersen for making the [Internet Monitoring](https://github.com/maxandersen/internet-monitoring) project, which forked and expanded with functionality to build Rasbpi-Monitoring.

**Grand Kudos** to Jeff Geerling aka [@geerlingguy](https://github.com/geerlingguy) for all his efforts to make us interesting in Raspberry Pi compiters and for [all his propaganda on youtube](https://www.youtube.com/c/JeffGeerling). Consider to like and subscribe ;)
