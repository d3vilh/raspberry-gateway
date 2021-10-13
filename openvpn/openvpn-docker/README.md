<h3 align="center">
    <img src="https://user-images.githubusercontent.com/30767528/91842261-0a27a600-ec54-11ea-9572-04c213f80374.png" alt="Logo" width="500">
</h3>

<h3 align="center">
    OpenVPN Docker Image
</h3>

There is already an existing docker-image for openvpn created by [kylemanna/docker-openvpn](https://github.com/kylemanna/docker-openvpn) - With over [216](https://github.com/kylemanna/docker-openvpn/issues) issues,
[40](https://github.com/kylemanna/docker-openvpn/pulls) open PR's and last commit done in March 2020 I decided to tread this image as not maintained anymore, also It was a good way for me to make myself more familiar with building and setting up docker iamges so that's why I created my own.

Most of its documentation can be found in the [root](https://github.com/d3vilh/raspberry-gateway) directory, if you want to run it without anything else you'll have to edit the [dns-configuration](https://github.com/d3vilh/raspberry-gateway/blob/master/openvpn/config/server.conf#L20) (which currently points to the PiHole DNS Server) and
if you don't want to use a custom dns-resolve at all you may also want to comment out [this line](https://github.com/d3vilh/raspberry-gateway/blob/master/openvpn/config/server.conf#L39).


### Run this image using `docker` itself

First, build the image:
```sh
sudo docker build -t openvpn .
```

Run the image:
```sh
sudo docker run openvpn \
    --expose 1194:1194/udp \
    --mount type=bind,src=./openvpn/pki,dst=/etc/openvpn/pki \
    --mount type=bind,src=./openvpn/clients,dst=/etc/openvpn/clients \
    --mount type=bind,src=./openvpn/config,dst=/etc/openvpn/config \
    --cap-add=NET_ADMIN \
    --restart=unless-stopped
```

### Run this image using a `docker-compose.yml` file

```yaml
services:
    openvpn:
        container_name: openvpn-tcp-443
        build: ./openvpn-docker
        ports:
            - 1194:1194/udp
        volumes:
            - ./openvpn/pki:/etc/openvpn/pki # Directory with our public key infrastructure
            - ./openvpn/clients:/etc/openvpn/clients # .ovpn files
            - ./openvpn/config:/etc/openvpn/config # server.conf and client.conf should both be in there
        cap_add:
            - NET_ADMIN
        restart: unless-stopped
# ... other services
```
