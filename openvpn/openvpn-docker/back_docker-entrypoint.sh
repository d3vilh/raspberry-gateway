#!/bin/bash
set -e

if [[ ! -f /etc/openvpn/pki/ca.crt ]]; then
    export EASYRSA_BATCH=1 # see https://superuser.com/questions/1331293/easy-rsa-v3-execute-build-ca-and-gen-req-silently
    cd /opt/app/easy-rsa

    # Copy easy-rsa variables
    cp /etc/openvpn/config/easy-rsa.vars ./vars

    # Building the CA
    echo 'Setting up public key infrastructure...'
    ./easyrsa init-pki

    echo 'Generating ertificate authority...'
    ./easyrsa build-ca nopass

    # Creating the Server Certificate, Key, and Encryption Files
    echo 'Creating the Server Certificate...'
    ./easyrsa gen-req server nopass

    echo 'Sign request...'
    ./easyrsa sign-req server server

    echo 'Generate Diffie-Hellman key...'
    ./easyrsa gen-dh

    echo 'Generate HMAC signature...'
    openvpn --genkey --secret pki/ta.key

    echo 'Create certificate revocation list (CRL)...'
    ./easyrsa gen-crl
    chmod +r ./pki/crl.pem

    # Copy to mounted volume
    cp -r ./pki/. /etc/openvpn/pki
else
    # Copy from mounted volume
    cp -r /etc/openvpn/pki /opt/app/easy-rsa
    echo 'PKI already set up.'
fi

# Configure network
mkdir -p /dev/net
if [ ! -c /dev/net/tun ]; then
    mknod /dev/net/tun c 10 200
fi

echo 'Configuring networking rules...'
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
sysctl -p /etc/sysctl.conf

echo 'Configuring iptables...'
echo 'NAT for OpenVPN clients'
iptables -t nat -A POSTROUTING -s 10.0.70.0/24 -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.0.71.0/24 -o eth0 -j MASQUERADE

echo 'Blocking ICMP for external clients'
iptables -A FORWARD -p icmp -j DROP --icmp-type echo-request -s 10.0.71.0/24 
iptables -A FORWARD -p icmp -j DROP --icmp-type echo-reply -s 10.0.71.0/24 

echo 'Blocking internal home subnet to access from external openvpn clients (Internet still available)'
iptables -A FORWARD -s 10.0.71.0/24 -d 192.168.88.0/24 -j DROP

echo 'IPT MASQ Chains:'
iptables -t nat -L | grep MASQ
echo 'IPT FWD Chains:'
iptables -v -x -n -L | grep DROP 

echo 'Start openvpn process...'
/usr/sbin/openvpn --cd /etc/openvpn --script-security 2 --config /etc/openvpn/config/server.conf

