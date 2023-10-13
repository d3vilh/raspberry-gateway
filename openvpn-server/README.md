# OpenVPN and OpenVPN UI

Most of documentation can be found in the [main README.md](https://github.com/d3vilh/raspberry-gateway) file, if you want to run it without anything else you'll have to edit the [dns-configuration](https://github.com/d3vilh/raspberry-gateway/blob/master/openvpn-server/config/server.conf#L20) (which currently points to the PiHole DNS Server) and
if you don't want to use a custom dns-resolve at all you may also want to comment out [this line](https://github.com/d3vilh/raspberry-gateway/blob/master/openvpn-server/config/server.conf#L39).

## Docker and Docker compose
[**HERE**](https://github.com/d3vilh/raspberry-gateway/blob/master/openvpn-server/README.md) you can find all the the **Docker** and **Docker-compose** instructions, volumes and enviroment variables defifintion.

## Configuration
**OpenVPN UI** can be accessed on own port (*e.g. `http://localhost:8080` , change `localhost` to your Raspberry host ip/name*), the default user and password is `admin/gagaZush` preconfigured in `config.yml` which you supposed to [set in](https://github.com/d3vilh/raspberry-gateway/blob/master/example.config.yml#L25) `ovpnui_user` & `ovpnui_password` vars, just before the installation.

The volume container will be inicialized by using the official OpenVPN `openvpn_openvpn` image with included scripts to automatically generate everything you need  on the first run:
 - Diffie-Hellman parameters
 - an EasyRSA CA key and certificate
 - a new private key
 - a self-certificate matching the private key for the OpenVPN server
 - a TLS auth key from HMAC security

Default EasyRSA configuration whoch can be changed in `~/openvpn-server/config/easy-rsa.vars` file, is the following:

```shell
set_var EASYRSA_DN           "org"
set_var EASYRSA_REQ_COUNTRY  "UA"
set_var EASYRSA_REQ_PROVINCE "KY"
set_var EASYRSA_REQ_CITY     "Kyiv"
set_var EASYRSA_REQ_ORG      "SweetHome"
set_var EASYRSA_REQ_EMAIL    "sweet@home.net"
set_var EASYRSA_REQ_OU       "MyOrganizationalUnit"
set_var EASYRSA_REQ_CN       "server"
set_var EASYRSA_KEY_SIZE     2048
set_var EASYRSA_CA_EXPIRE    3650
set_var EASYRSA_CERT_EXPIRE  825
set_var EASYRSA_CERT_RENEW   30
set_var EASYRSA_CRL_DAYS     180
```
In the process of installation these vars will be copied to container volume `/etc/openvpn/pki/vars` and used during all EasyRSA operations.
You can update all these parameters later with OpenVPN UI on `Configuration > EasyRSA vars` page.

This setup use `tun` mode, because it works on the widest range of devices. tap mode, for instance, does not work on Android, except if the device is rooted.

The topology used is `subnet`, because it works on the widest range of OS. p2p, for instance, does not work on Windows.

The server config [specifies](https://github.com/d3vilh/raspberry-gateway/blob/master/openvpn-server/config/server.conf#L34) `push redirect-gateway def1 bypass-dhcp`, meaning that after establishing the VPN connection, all traffic will go through the VPN. This might cause problems if you use local DNS recursors which are not directly reachable, since you will try to reach them through the VPN and they might not answer to you. If that happens, use public DNS resolvers like those of OpenDNS (`208.67.222.222` and `208.67.220.220`) or Google (`8.8.4.4` and `8.8.8.8`).

If you wish to use your local Pi-Hole as a DNS server (the one which comes with this setup), you have to modify a [dns-configuration](https://github.com/d3vilh/raspberry-gateway/blob/master/openvpn-server/config/server.conf#L20) with your local Pi-Hole IP address.

### OpenVPN client subnets. Guest and Home users
[Raspberry-Gateway](https://github.com/d3vilh/raspberry-gateway/) OpenVPN server uses `10.0.70.0/24` **"Trusted"** subnet for dynamic clients by default and all the clients connected by default will have full access to your Home network, as well as your home Internet.
However you can be desired to share VPN access with your friends and restrict access to your **"Home network"** for them, but allow to use Internet connection over your VPN. This type of guest clients needs to live in special **"Guest users"** subnet - `10.0.71.0/24`:

<p align="center">
<img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OVPN_VLANs.png" alt="OpenVPN Subnets" width="700" border="1" />
</p>

* **"Trusted"** subnet is `ovpn_trusted_subnet` in [config.yml](https://github.com/d3vilh/raspberry-gateway/blob/master/example.config.yml#L80) and `TRUST_SUB` var in [docker-compose](https://github.com/d3vilh/raspberry-gateway/tree/master/openvpn-server/openvpn-docker#run-this-image-using-a-docker-composeyml-file) file.
* **"Guest"** subnet is `ovpn_guest_subnet` in [config.yml](https://github.com/d3vilh/raspberry-gateway/blob/master/example.config.yml#L81) and `GUEST_SUB` var in [docker-compose](https://github.com/d3vilh/raspberry-gateway/tree/master/openvpn-server/openvpn-docker#run-this-image-using-a-docker-composeyml-file) file.
* **"Home"** subnet is `ovpn_home_subnet` in [config.yml](https://github.com/d3vilh/raspberry-gateway/blob/master/example.config.yml#L82) and `HOME_SUB` vsr in [docker-compose](https://github.com/d3vilh/raspberry-gateway/tree/master/openvpn-server/openvpn-docker#run-this-image-using-a-docker-composeyml-file) file.

To assign desired subnet policy to the specific client, you have to define static IP address for this client when you'll be generate new .OVPN profile.
To do that, just enter `"Static IP (optional)"` field in `"Certificates"` page and press `"Create"` button.

You can apply optional Firewall rules for the OpenVPN server container in `~/openvpn-server/fw-rules.sh` file, which will be executed on the container start. Here is example to blocking traffic between 2 "Trusted" subnet clients:
```shell
~/openvpn-server $ cat fw-rules.sh
iptables -A FORWARD -s 10.0.70.88 -d 10.0.70.77 -j DROP
iptables -A FORWARD -d 10.0.70.77 -s 10.0.70.88 -j DROP
```

> Keep in mind, by default, all the clients got **"Trusted"** subnet and have full access, so you don't need to specifically configure static IP for your own devices. 


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
|   |-- data.db //Optional OpenVPN UI DB
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

### Generating .OVPN client profiles
  <details>
      <summary>How to generate .OVPN client profile</summary>
You can update external client IP and port address anytime under `"Configuration > OpenVPN Client"` menue. 

For this go to `"Configuration > OpenVPN Client"`:

<img src="https://github.com/d3vilh/openvpn-ui/blob/main/docs/images/OpenVPN-UI-ext_serv_ip1.png" alt="Configuration > Settings" width="350" border="1" />

And then update `"Connection Address"` and `"Connection Port"` fields with your external Internet IP and Port. 

To generate new Client Certificate go to `"Certificates"`, then press `"Create Certificate"` button, enter new VPN client name, complete all the rest fields and press `"Create"` to generate new Client certificate:

<img src="https://github.com/d3vilh/openvpn-ui/blob/main/docs/images/OpenVPN-UI-ext_serv_ip2.png" alt="Server Address" width="350" border="1" />  <img src="https://github.com/d3vilh/openvpn-ui/blob/main/docs/images/OpenVPN-UI-New_Client.png" alt="Create Certificate" width="350" border="1" />

To download .OVPN client configuration file, press on the `Client Name` you just created:

<img src="https://github.com/d3vilh/openvpn-ui/blob/main/docs/images/OpenVPN-UI-New_Client_download.png" alt="download OVPN" width="350" border="1" />

Install [Official OpenVPN client](https://openvpn.net/vpn-client/) to your client device.

Deliver .OVPN profile to the client device and import it as a FILE, then connect with new profile to enjoy your free VPN:

<img src="https://github.com/d3vilh/openvpn-ui/blob/main/docs/images/OpenVPN-UI-Palm_import.png" alt="PalmTX Import" width="350" border="1" /> <img src="https://github.com/d3vilh/openvpn-ui/blob/main/docs/images/OpenVPN-UI-Palm_connected.png" alt="PalmTX Connected" width="350" border="1" />

  </details>

### Renew Certificates for client profiles
  <details>
      <summary>How to renew old client profile</summary>
To renew certificate, go to `"Certificates"` and press `"Renew"` button for the client you would like to renew certificate for:

<img src="https://github.com/d3vilh/openvpn-ui/blob/main/docs/images/OpenVPN-UI-Cert-Renew.01.png" alt="Renew OpenVPN Certificate" width="600" border="1" />

Right after this step new Certificate will be genrated and it will appear as new client profile with the same Client name. At this point both client profiles will have updated Certificate when you try to download it.

Once you will deliver new client profile with renewed Certificate to you client, press `"Revoke"` button for old profile to revoke old Certificate, old client profile will be deleted from the list.

If, for some reason you still would like to keep old certificate you have to `"Revoke"` new profile, old certificate will be rolled back and new profile will be deleted from the list.

Renewal process will not affect active VPN connections, old client will be disconnected only after you revoke old certificate or certificate term of use will expire.
  </details>

### Revoking .OVPN profiles
  <details>
      <summary>How to revoke client certificate</summary>

If you would like to prevent client to use yor VPN connection, you have to revoke client certificate and restart the OpenVPN daemon.
You can do it via OpenVPN UI `"Certificates"` menue, by pressing `"Revoke"`` amber button:

<img src="https://github.com/d3vilh/openvpn-ui/blob/main/docs/images/OpenVPN-UI-Revoke.png" alt="Revoke Certificate" width="600" border="1" />

Certificate revoke won't kill active VPN connections, you'll have to restart the service if you want the user to immediately disconnect. It can be done from the same `"Certificates"` page, by pressing Restart red button:

<img src="https://github.com/d3vilh/openvpn-ui/blob/main/docs/images/OpenVPN-UI-Restart.png" alt="OpenVPN Restart" width="600" border="1" />

You can do the same from the `"Maintenance"` page.

After Revoking and Restarting the service, the client will be disconnected and will not be able to connect again with the same certificate. To delete the certificate from the server, you have to press `"Remove"` button.
  </details>

### Two Factor Authentication (2FA)
Starting from vestion `0.9.3` OpenVPN-UI has Two Factor Authentication (2FA) feature.
OpenVPN-UI uses [oath-toolkit](https://savannah.nongnu.org/projects/oath-toolkit/) for two factor authentication. Means you don't need any ThirdParty 2FA provider.
When generating 2FA-enabled certificates OpenVPN-UI will provide QR code with 2FA secret, which you can scan with your 2FA app (Google Authenticator [iOS](https://apps.apple.com/us/app/google-authenticator/id388497605), [Android](https://play.google.com/store/apps/details?id=com.google.android.apps.authenticator2&pcampaignid=web_share), Microsoft Authenticator [iOS](https://apps.apple.com/us/app/microsoft-authenticator/id983156458), [Android](https://play.google.com/store/apps/details?id=com.azure.authenticator&pcampaignid=web_share), etc) to get 2FA token for connection with this certificate.

2FA Certificates **`Renewal`**, **`Revoke`** and **`Delete`** process is the same as for regular certificates.

#### To enable 2FA you have to:

* Go to `"Configuration > OpenVPN Client"` page and enable `"Two Factor Authentication"` option to switch Certificates interface to 2FA mode, so you can generate certificates with 2FA enabled and access 2FA QR code for already generated certificates.

  > **Note**: You can generate 2FA-ready certificates at this stage, then deliver 2FA Certificates to all your client devices and enable 2FA Server support later, when you'll be ready to use it. Before that Server will still accept non 2FA-ready certificates only.

* Go to `"Configuration > OpenVPN Server"` page and enable `"Two Factor Authentication"` option for OpenVPN Server backend. Once 2FA is enabled for Server, OpenVPN-Server **will allow 2FA connections only** (non 2FA-ready certificates won't connect).

#### 2FA .OVPN profiles creation
  <details>
      <summary>How to generate 2FA Certificate</summary>

Procedure for 2FA generation is the same as for regular certificate, but you have to use the uniq `2FA Name` in the email-kind format:

<img src="https://github.com/d3vilh/openvpn-ui/blob/main/docs/images/OpenVPN-UI-2FA-Cert-Create.png" alt="2FA Certificate create" width="600" border="1" />

> **Note**: For Multifactor Authentication (MFA), you can add one more password by completing **`Passphrase`** option. 

Both **`Passphrase`** and **`Client Static IP`** are optional parameters.

When you complete all the fields, click on **`Create`** and your new 2FA Certificate will be ready.

Once this done, you can click on the new certificate in the `Certificates` page to see all the details including QR code for 2FA token:

<img src="https://github.com/d3vilh/openvpn-ui/blob/main/docs/images/OpenVPN-UI-2FA-Cert-details.png" alt="2FA Certificate details" width="600" border="1" />

You can copy or email this information directly to happy 2FA certificate owner.
  </details>

#### 2FA certificates usage
  <details>
      <summary>How to add 2FA profile to client</summary>

To use 2FA certificate you have to install 2FA app on your device (**Google Authenticator** [iOS](https://apps.apple.com/us/app/google-authenticator/id388497605), [Android](https://play.google.com/store/apps/details?id=com.google.android.apps.authenticator2&pcampaignid=web_share), **Microsoft Authenticator** [iOS](https://apps.apple.com/us/app/microsoft-authenticator/id983156458), [Android](https://play.google.com/store/apps/details?id=com.azure.authenticator&pcampaignid=web_share), etc) and scan QR code from the `Certificates` details page.

After scanning QR-code, new Authenticator profile will be created in your 2FA app with the same name as your 2FA Certificate name:

<img src="https://github.com/d3vilh/openvpn-ui/blob/main/docs/images/OpenVPN-UI-2FA-mobi-authenticator.png" alt="2FA Authenticator" width="350" border="1" />

Then you have to download and deliver `.OVPN profile` to [OpenVPN Connect app](https://openvpn.net/client/) and open it as a file. Following window appear:

<img src="https://github.com/d3vilh/openvpn-ui/blob/main/docs/images/OpenVPN-UI-2FA-mobi-profile-add.png" alt="2FA OpenVPN Connect profile add" width="350" border="1" />

Click `Add` to add new profile to OpenVPN Connect. Then you will be asked to enter your Username. As username use `2FA Name` which you used during Certificate/profile generation (as precisely as you can. `2FA Name` is part of authentication process):

<img src="https://github.com/d3vilh/openvpn-ui/blob/main/docs/images/OpenVPN-UI-2FA-mobi-username.png" alt="2FA OpenVPN Connect profile username" width="350" border="1" />

When you'll be prompted to Enter the password, you have to enter your 2FA token from your 2FA app:

<img src="https://github.com/d3vilh/openvpn-ui/blob/main/docs/images/OpenVPN-UI-2FA-mobi-password.png" alt="2FA OpenVPN Connect profile 2FA password" width="350" border="1" />

Connection will be suceeded if you entered `2FA Name` and 2FA token correctly.

For MFA authentication you can use optional `Passphrase` when generating new Client certificate, to protect your 2FA token with additional password. In this case you have to enter your `Passphrase` as a `Private Key Password` and 2FA token as `Password`: 

<img src="https://github.com/d3vilh/openvpn-ui/blob/main/docs/images/OpenVPN-UI-2FA-mobi-password-cert.png" alt="2FA OpenVPN Connect profile 2FA and Certificate passwords" width="350" border="1" />

  </details>

### Alternative, CLI ways to deal with OpenVPN configuration
To generate new .OVPN profile execute following command. Password as second argument is optional:
```shell
sudo docker exec openvpn bash /opt/app/bin/genclient.sh <name> <IP> <?password?>
```

You can find you .ovpn file under `/openvpn/clients/<name>.ovpn`, make sure to check and modify the `remote ip-address`, `port` and `protocol`. It also will appear in `"Certificates"` menue of OpenVPN UI.

Revoking of old .OVPN files can be done via CLI by running following:

```shell
sudo docker exec openvpn bash /opt/app/bin/revoke.sh <clientname>
```

Removing of old .OVPN files can be done via CLI by running following:

```shell
sudo docker exec openvpn bash /opt/app/bin/rmcert.sh <clientname>
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

### OpenVPN-UI User Management
Starting from `v.0.9.2` OpenVPN UI has user management feature. 

You can create and delete users with different privileges - Administrators or regular users:
* Administrators has full access
* Regular users has access to Home page, Certificates and Logs pages only. This users can create, renew, revoke and delete all the certificates.


<details>
      <summary>How to manage OpenVPN-UI Users</summary>

This functionality available via `"Users Profiles"` page:

<img src="https://github.com/d3vilh/openvpn-ui/blob/main/docs/images/OpenVPN-UI-ProfileAdmin.png" alt="Username > Profile" width="350" border="1" />


Then, if your user have enough privilegies you can Create new profile or manage profiles of other users:

<img src="https://github.com/d3vilh/openvpn-ui/blob/main/docs/images/OpenVPN-UI-ProfileCreate.png" alt="New OpenVPN UI Profile creation" width="600" border="1" />

<img src="https://github.com/d3vilh/openvpn-ui/blob/main/docs/images/OpenVPN-UI-ProfileManage.png" alt="OpenVPN UI Profiles management" width="600" border="1" />

</details>


### OpenVPN activity dashboard
[Raspberry-Gateway](https://github.com/d3vilh/raspberry-gateway/) setup includes Prometheus [OpenVPN-exporter](https://github.com/d3vilh/openvpn_exporter) and OpenVPN [Grafana dashboard](https://github.com/d3vilh/raspberry-gateway/blob/master/templates/openvpn_exporter.json.j2) which you can [enable in](https://github.com/d3vilh/raspberry-gateway/blob/master/example.config.yml#L39) by setting `openvpn_monitoring_enable` option to `true`.

![OpenVPN Grafana Dashboard](/images/OVPN_Dashboard.png)

### OpenVPN UI screenshots

<img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OpenVPN-UI-Login.png" alt="OpenVPN-UI Login screen" width="1000" border="1" />

<img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OpenVPN-UI-Home.png" alt="OpenVPN-UI Home screen" width="1000" border="1" />

<img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OpenVPN-UI-Certs.png" alt="OpenVPN-UI Certificates screen" width="1000" border="1" />

<img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OpenVPN-UI-Logs.png" alt="OpenVPN-UI Logs screen" width="1000" border="1" />

<img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OpenVPN-UI-Config.png" alt="OpenVPN-UI Configuration screen" width="1000" border="1" />

<img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OpenVPN-UI-Server-config.png" alt="OpenVPN-UI Server Configuration screen" width="1000" border="1" />

<img src="https://github.com/d3vilh/raspberry-gateway/blob/master/images/OpenVPN-UI-Profile.png" alt="OpenVPN-UI User Profile" width="1000" border="1" />


<a href="https://www.buymeacoffee.com/d3vilh" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 51px !important;width: 217px !important;" ></a>