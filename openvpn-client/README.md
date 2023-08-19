# OpenVPN Client for Docker
This is an OpenVPN client docker container. It makes routing containers' traffic through OpenVPN easy.
Allows you to easily select which applications use the VPN without needing to set up split tunneling and eliminates the need to install an OpenVPN client on the host.

It supports: 
* Any OpenVPN configuration file (`*.ovpn`), so it should work with any VPN provider.
* Docker secrets for passing credentials to the VPN.
* Can be used with other containers that use the same network stack as the OpenVPN client.
* It has a `iptables` *kill switch* that disconnects the container from the internet if the VPN connection drops and denys all traffic except for the traffic to the VPN server and especially allowed subnets.

#### Environment variables
###### CLIENT CONFIGURATION FILE
`ovpn_client_cert: "example-client.opvn"`
The OpenVPN configuration file or search pattern. If unset, a random `.conf` or `.ovpn` file will be selected. The file must be located in the `~/openvpn-client` directory. You can use the [**example-client.ovpn**](https://github.com/d3vilh/raspberry-gateway/blob/master/openvpn-client/example-client.ovpn#L1) as a refference of all necessary options

###### AUTH SECRET
`ovpn_client_secret:example-credentials.txt`
Pass here the [Docker secret](https://docs.docker.com/engine/swarm/secrets/#use-secrets-in-compose) that contains the credentials for accessing the VPN.
For authentification with user and password on top of *.ovpn, you have to put text file in `~/openvpn-client/example-credentials.txt` which must contain two lines: the first line is the username, the second line is the password, like in [refference file](https://github.com/d3vilh/raspberry-gateway/blob/master/openvpn-client/example-credentials.txt#L1). Then update `ovpn_client_secret` option of [config.yml](https://github.com/d3vilh/raspberry-gateway/blob/master/example.config.yml#L55) file with the filename containg credentials.
Don't forget to add the following line to the OpenVPN configuration file, if you want to use the credentials file:
```bash
auth-user-pass example-credentials.txt
```

###### ALLOWED SUBNETS
`ovpn_client_allowed_subnet:192.168.0.0/24`
A list of one or more comma-separated subnets (e.g. `192.168.0.0/24,10.0.60.0/24`) to allow outside of the VPN tunnel.
If you plan to connect to containers that use the OpenVPN container's network stack (which is likely). it's recommended to use this variable. Even if you're not using the kill switch, the entrypoint script will add routes to each of the `ovpn_client_allowed_subnet` to enable network connectivity from outside of Docker (You need it for qBitTorrent web-ui access for example).

###### KILL SWITCH
`ovpn_client_killswitch: true  `
Default value is `true`.
Whether or not to enable the kill switch. If set to `true`, it will block all the traffic when VPN is connected, except the one from the `ovpn_client_allowed_subnet` subnet

### Using with other containers
For **Pi-hole**, **Technitium DNS** and **qBitTorrent** you can use special option in the `config.yml` file to enable VPN connection for them. So enabled contaier will always use VPN as the only internet access point. 
For example, to enable VPN for **qBitTorrent**, you need to set `qbittorrent_inside_vpn` to `true` in the [config.yml](https://github.com/d3vilh/raspberry-gateway/blob/master/example.config.yml#L89) file.
For **Pi-hole** and **Technitium DNS** you need to set `pihole_inside_vpn` and `technitium_inside_vpn` to `true` respectively.

### Verifying functionality
To verify that the openvpn-client container is functioning properly, you can run the following command:

```bash
sudo docker exec openvpn-client wget -qO - ifconfig.me
```
This command should return the public IP address of the openvpn-client container. If the IP address matches the one provided by your VPN provider, then the openvpn-client container is functioning properly.

To confirm other continers are using the VPN, you can run the following command (qbittorrent in this example):

```bash
sudo docker exec qbittorrent wget -qO - ifconfig.me
```
This should return the public IP address of the VPN provider, same as openvpn-client container.

<a href="https://www.buymeacoffee.com/d3vilh" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 51px !important;width: 217px !important;" ></a>