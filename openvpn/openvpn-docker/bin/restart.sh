#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e

# Directory where OpenVPN configuration files are stored
OVDIR=/etc/openvpn
CONTAINER_ID=$(curl --unix-socket /var/run/docker.sock "http:/v1.40/containers/json?filters={\"name\":[\"openvpn\"]}" | grep -oP '(?<="Id":")[^"]*')
# Change to the /opt directory
#cd /opt/
curl --unix-socket /var/run/docker.sock -X POST "http:/v1.40/containers/$CONTAINER_ID/restart"