# Start from Alpine base image
FROM arm64v8/alpine
LABEL maintainer="Mr.Philipp <d3vilh@github.com>"

# Copy all files in the current directory to the /opt/app directory in the container
COPY . /opt/app
# Set the working directory to /opt/app
WORKDIR /opt/app

RUN apk --no-cache --no-progress upgrade && \
    apk --no-cache --no-progress add bash bind-tools curl wget ip6tables iptables openvpn easy-rsa
#Install Latest RasyRSA Version
RUN chmod 755 /usr/share/easy-rsa/*

# Add the openssl-easyrsa.cnf file to the easy-rsa directory
ADD openssl-easyrsa.cnf /opt/app/easy-rsa/

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