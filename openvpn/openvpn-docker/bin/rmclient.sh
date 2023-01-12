#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e

# Set the path of the OpenVPN configuration file for the specified user
DEST_FILE_PATH="/etc/openvpn/clients/$1.ovpn"

# Check if the OpenVPN configuration file exists
if [[ ! -f $DEST_FILE_PATH ]]; then
    echo "User not found."
    exit 1
fi

# Modify the index.txt file by removing everything after pattern "/name=$1" in the line
sed -i'.bak' "s/\/name=${1}.*//" /usr/share/easy-rsa/pki/index.txt

# Set the EASYRSA_BATCH variable to enable non-interactive mode for easy-rsa
export EASYRSA_BATCH=1 # see https://superuser.com/questions/1331293/easy-rsa-v3-execute-build-ca-and-gen-req-silently

echo 'Revoke certificate...'

# Change to the easy-rsa directory and copy the easy-rsa variables file
cd /usr/share/easy-rsa
cp /etc/openvpn/config/easy-rsa.vars ./vars

# Revoke the specified user's certificate
./easyrsa revoke "$1"

# Generate a new CRL
echo 'Create new Create certificate revocation list (CRL)...'
./easyrsa gen-crl

# Make the CRL file readable
chmod +r ./pki/crl.pem

echo 'Sync pki directory...'
# Remove all files in the /etc/openvpn/pki directory
#rm -rf /etc/openvpn/pki/*

# Copy all files from the easy-rsa PKI directory to the OpenVPN PKI directory
cp -r ./pki/. /etc/openvpn/pki

echo 'Done!'
echo 'If you want to disconnect the user please restart the service using docker-compose restart openvpn.'
