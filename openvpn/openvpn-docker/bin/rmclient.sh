#!/bin/bash
set -e

# .ovpn file path
DEST_FILE_PATH="/etc/openvpn/clients/$1.ovpn"

# Check if .ovpn file exists
if [[ ! -f $DEST_FILE_PATH ]]; then
    echo "User not found."
    exit 1
fi

export EASYRSA_BATCH=1 # see https://superuser.com/questions/1331293/easy-rsa-v3-execute-build-ca-and-gen-req-silently

echo 'Revoke certificate...'

# Copy easy-rsa variables
cd /opt/app/easy-rsa
cp /etc/openvpn/config/easy-rsa.vars ./vars

# Revoke certificate
./easyrsa revoke "client-$1"

echo 'Create new Create certificate revocation list (CRL)...'
./easyrsa gen-crl
chmod +r ./pki/crl.pem

echo 'Sync pki directory...'
rm -rf /etc/openvpn/pki/*
cp -r ./pki/. /etc/openvpn/pki

echo 'Done!'
echo 'If you want to disconnect the user please restart the service using docker-compose restart openvpn.'

