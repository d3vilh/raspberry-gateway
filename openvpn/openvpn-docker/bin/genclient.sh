#!/bin/bash
# OVPN SCRIPT
set -e

# .ovpn file path
DEST_FILE_PATH="/etc/openvpn/clients/$1.ovpn"

# Validate username and check for duplicates
if  [[ -z $1 ]]; then
    echo 'Name cannot be empty.'
    exit 1
elif [[ -f $DEST_FILE_PATH ]]; then
    echo "User with name $1 already exists under openvpn/clients."
    exit 1
fi

export EASYRSA_BATCH=1 # see https://superuser.com/questions/1331293/easy-rsa-v3-execute-build-ca-and-gen-req-silently


echo 'Generate client certificate...'

# Copy easy-rsa variables
cd /usr/share/easy-rsa
cp /etc/openvpn/config/easy-rsa.vars ./vars
./vars
echo $KEY_COUNTRY
echo $KEY_EMAIL

# Generate certificates
if  [[ -z $2 ]]; then
    echo 'Without password...'
    ./easyrsa --batch --req-cn="$1" gen-req "client-$1" nopass
else
    echo 'With password...'
    # See https://stackoverflow.com/questions/4294689/how-to-generate-an-openssl-key-using-a-passphrase-from-the-command-line
    # ... and https://stackoverflow.com/questions/22415601/using-easy-rsa-how-to-automate-client-server-creation-process
    # ... and https://github.com/OpenVPN/easy-rsa/blob/master/doc/EasyRSA-Advanced.md
    (echo -e '\n') | ./easyrsa --batch --req-cn="$1" --passin=pass:${2} --passout=pass:${2} gen-req "client-$1"
fi

# Sign request
./easyrsa sign-req client "client-$1"

# Certificate properties
CA="$(cat ./pki/ca.crt )"
CERT="$(cat ./pki/issued/client-${1}.crt | grep -zEo -e '-----BEGIN CERTIFICATE-----(\n|.)*-----END CERTIFICATE-----' | tr -d '\0')"
KEY="$(cat ./pki/private/client-${1}.key)"
TLS_AUTH="$(cat ./pki/ta.key)"

#echo 'Sync pki directory...'
#cp -r ./pki/. /etc/openvpn/pki

echo 'Generate .ovpn file...'
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
echo "Checkout openvpn/clients/$1.ovpn"
