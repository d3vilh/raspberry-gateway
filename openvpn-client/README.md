# OpenVPN Client for Docker
This is an OpenVPN client docker container. It makes routing containers' traffic through OpenVPN easy.
Allows you to easily select which applications use the VPN without needing to set up split tunneling and eliminates the need to install an OpenVPN client on the host.

It supports: 
* Any OpenVPN configuration file, so it should work with any VPN provider.
* Docker secrets for passing credentials to the VPN.
* Can be used with other containers that use the same network stack as the OpenVPN client.
* It has a `iptables` *kill switch* that disconnects the container from the internet if the VPN connection drops.

### Getting the image
To pull it from DockerHub Container Registry, run
```bash
docker pull d3vilh/openvpn-client:arm64v8
```

### Building the image
```bash
docker build -t openvpn-client .
```
### Running the image
To run the OpenVPN client image, you need to create the container with the NET_ADMIN capability and ensure that /dev/net/tun is accessible. Here are basic examples for docker run and Compose, but you'll likely want to customize them. Check the section below to learn how to use the openvpn-client network stack with other containers.

#### `docker-compose`
```yaml
services:
  openvpn-client:
    image: d3vilh/openvpn-client:arm64v8
    container_name: openvpn-client
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun:/dev/net/tun
    environment:
      - ALLOWED_SUBNETS=192.168.88.0/24
      # - AUTH_SECRET=example-credentials.txt
      # - CONFIG_FILE=antresolka.ovpn
      # - KILL_SWITCH=false
    volumes:
      - ./ovpn-client:/config
    restart: unless-stopped
```
#### `docker run`
```bash
docker run --detach \
  --name=openvpn-client \
  --cap-add=NET_ADMIN \
  --device=/dev/net/tun \
  --volume ./ovpn-client:/config \
  d3vilh/openvpn-client:arm64v8
```
#### Environment variables
###### `ALLOWED_SUBNETS`
A list of one or more comma-separated subnets (e.g. `192.168.88.0/24,10.0.60.0/24`) to allow outside of the VPN tunnel.
If you plan to connect to containers that use the OpenVPN container's network stack (which is likely), it's recommended to use this variable. Even if you're not using the kill switch, the entrypoint script will add routes to each of the `ALLOWED_SUBNETS` to enable network connectivity from outside of Docker.

###### `AUTH_SECRET`
Pass here the Docker secret that contains the credentials for accessing the VPN. 
Docker Compose supports [Docker secrets](https://docs.docker.com/engine/swarm/secrets/#use-secrets-in-compose), which can be used to pass proxy credentials securely. Check out the [docker-compose.yml](docker-compose.yml) file in this repository for an example of how to use Docker secrets.

###### `CONFIG_FILE`
The OpenVPN configuration file or search pattern. If unset, a random `.conf` or `.ovpn` file will be selected.

###### `KILL_SWITCH`
Default value is `true`.
Whether or not to enable the kill switch. can be set with following values: `true`, `t`, `yes`, `y`, `1`, `on`, `enable`, or `enabled`.

### Using with other containers
After setting up the `openvpn-client` container, you can configure other containers to use its network stack, enabling them to utilize the VPN tunnel. The method you use to achieve this depends on how your container is created.

If your container is being created with
1. the same Compose YAML file as `openvpn-client`, add `network_mode: service:openvpn-client` to the container's service definition.
2. a different Compose YAML file than `openvpn-client`, add `network_mode: container:openvpn-client` to the container's service definition.
3. `docker run`, add `--network=container:openvpn-client` as an option to `docker run`.

Assuming your container has `wget` or `curl` installed, you can verify that everything is working correctly by running either `docker exec <container_name> wget -qO - ifconfig.me` or `docker exec <container_name> curl -s ifconfig.me`. This command will return the public IP address of your container, which should match the IP address of `openvpn-client`.

#### Handling ports intended for connected containers
If you need to access a port on a connected container, you should publish that port on the `openvpn-client` container instead of the connected container. To achieve this, use `-p <host_port>:<container_port>` if you're using `docker run`. Alternatively, add the following snippet to the `openvpn-client` service definition in your Compose file if using `docker-compose`.

```yaml
ports:
  - <host_port>:<container_port>
```
Make sure to replace `<host_port>` and `<container_port>` with the actual port numbers used by your connected container in both cases.

### Verifying functionality
To verify that the openvpn-client container is functioning properly, you can run the following command:

```bash
docker run -it --rm --net=container:<openvpn-client-container-name> appropriate/curl wget -qO - ifconfig.me
```
This command should return the public IP address of the openvpn-client container. If the IP address matches the one provided by your VPN provider, then the openvpn-client container is functioning properly.

You can also verify that other containers are using the openvpn-client container's network stack by running the same command on those containers, but replacing `<openvpn-client-container-name>` with the name of the container that you want to verify. If the IP address returned by the command matches the one provided by your VPN provider, then that container is using the openvpn-client container's network stack.

#### VPN authentication
You can provide your OpenVPN configuration file with the necessary credentials by creating a file (any name will work, but for this example, we'll use `credentials.txt`) next to the OpenVPN configuration file with your `username` on the first line and your `password` on the second line, like this:

```bash
username
password
```
Then, add the following line to the OpenVPN configuration file:

```bash
auth-user-pass credentials.txt
```
This instructs OpenVPN to read the credentials.txt file whenever it needs to authenticate.