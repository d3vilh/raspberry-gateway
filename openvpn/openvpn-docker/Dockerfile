# Start from Ubuntu 18.04 base image
FROM ubuntu:18.04

# Copy all files in the current directory to the /opt/app directory in the container
COPY . /opt/app
# Set the working directory to /opt/app
WORKDIR /opt/app

# Update package manager and install the latest version of OpenVPN
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install gnupg wget -y && \
    wget -qO - 'https://swupdate.openvpn.net/repos/repo-public.gpg' | apt-key add - && \
    echo 'deb http://build.openvpn.net/debian/openvpn/stable bionic main' > /etc/apt/sources.list.d/openvpn-aptrepo.list && \
    apt-get install openvpn -y

#Install Latest RasyRSA Version
#RUN apt-get update && apt-get install -y easy-rsa
#RUN chmod 755 /usr/share/easy-rsa/*

# Download and extract EasyRSA and remove the downloaded tar file
RUN wget -q https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.7/EasyRSA-3.0.7.tgz && \
    tar xf EasyRSA-3.0.7.tgz && \
    rm -f EasyRSA-3.0.7.tgz && \
    mv EasyRSA-3.0.7 easy-rsa

# Add the openssl-easyrsa.cnf file to the easy-rsa directory
ADD openssl-easyrsa.cnf /opt/app/easy-rsa/

# Install iptables
RUN apt-get install iptables -y

# Expose the OpenVPN port (1194/udp)
EXPOSE 1194/udp

# Make all files in the bin directory executable
RUN chmod +x bin/*

# Make the docker-entrypoint.sh script executable
RUN chmod +x docker-entrypoint.sh

# Set the entrypoint to the docker-entrypoint.sh script, passing in the following arguments:
# $REQ_COUNTRY $REQ_PROVINCE $REQ_CITY $REQ_ORG $REQ_OU $REQ_CN
ENTRYPOINT ./docker-entrypoint.sh \
                "$REQ_COUNTRY" \
                "$REQ_PROVINCE" \
                "$REQ_CITY" \
                "$REQ_ORG" \
                "$REQ_OU" \
                "$REQ_CN"
