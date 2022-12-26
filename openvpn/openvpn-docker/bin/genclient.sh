#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Set the path of the OpenVPN configuration file for the specified user
DEST_FILE_PATH="/etc/openvpn/clients/$1.ovpn"

# Validate the specified username and check for duplicate files
if  [[ -z $1 ]]; then
    # Display an error message if the username is empty
    echo 'Name cannot be empty.'
    # Exit the script with a non-zero exit status to indicate an error
    exit 1
elif [[ -f $DEST_FILE_PATH ]]; then
    # Display an error message if a file with the specified username already exists
    echo "User with name $1 already exists under openvpn/clients."
    # Exit the script with a non-zero exit status to indicate an error
    exit 1
fi

# Set the EASYRSA_BATCH variable to enable non-interactive mode for easy-rsa
export EASYRSA_BATCH=1 # see https://superuser.com/questions/1331293/easy-rsa-v3-execute-build-ca-and-gen-req-silently

echo 'Generating client certificate...'

# Change to the easy-rsa directory and copy the easy-rsa variables file
cd /usr/share/easy-rsa
cp /etc/openvpn/config/easy-rsa.vars ./vars

# Check if a password was specified
if  [[ -z $2 ]]; then
    # If no password was specified, generate a certificate without a password
    echo 'Generating certificate without password...'
./easyrsa --batch --req-cn="$1" gen-req "$1" nopass 
else
    # If a password was specified, generate a certificate with a password
    echo 'Generating certificate with password....'
    # See https://stackoverflow.com/questions/4294689/how-to-generate-an-openssl-key-using-a-passphrase-from-the-command-line
    # ... and https://stackoverflow.com/questions/22415601/using-easy-rsa-how-to-automate-client-server-creation-process
    # ... and https://github.com/OpenVPN/easy-rsa/blob/master/doc/EasyRSA-Advanced.md
    # Use the specified password to generate the certificate
    (echo -e '\n') | ./easyrsa --batch --req-cn="$1" --passin=pass:${2} --passout=pass:${2} gen-req "$1"
fi

# Sign the certificate request
./easyrsa sign-req client "$1"

# Modify the index.txt file by adding /name=$1 to the end of the line for the specified user
sed -i'.bak' "$ s/$/\/name=${1}/" /usr/share/easy-rsa/pki/index.txt

# Display the updated line in the index.txt file
echo "index.txt updated:"
tail -1 /usr/share/easy-rsa/pki/index.txt

# Set variables for the CA certificate, client certificate, client key, and TLS authentication key
CA="$(cat ./pki/ca.crt )"
CERT="$(cat ./pki/issued/${1}.crt | grep -zEo -e '-----BEGIN CERTIFICATE-----(\n|.)*-----END CERTIFICATE-----' | tr -d '\0')"
KEY="$(cat ./pki/private/${1}.key)"
TLS_AUTH="$(cat ./pki/ta.key)"

# Create the .ovpn file for the specified user by combining the contents of the client.conf file with the CA certificate, client certificate, client key, and TLS authentication key
echo 'Generating .ovpn file...'
echo "$(cat /etc/openvpn/config/client.conf)
<ca>
$CA
</ca>
<cert>
$CERT
</cert>
<key>
$KEY
</key>
<tls-auth>
$TLS_AUTH
</tls-auth>
" > "$DEST_FILE_PATH"

echo 'OpenVPN Client configuration successfully generated!'

# Display the location of the generated .ovpn file
echo "Checkout openvpn/clients/$1.ovpn"
