#!/usr/bin/env bash

# Parse debug arg from Ruby
[[ $1 == "true" ]] && set -x

# ASCII typo
asciitypo="$(cat <<-ENDOFTYPO
.__                    __   __
|  |__   ____  _______/  |_|  | __ ____   ____ ______   ___________
|  |  \ /  _ \/  ___/\   __\  |/ // __ \_/ __ \\\____ \_/ __ \_  __ \.
|   Y  (  <_> )___ \  |  | |    <\  ___/\  ___/|  |_> >  ___/|  | \/
|___|  /\____/____  > |__| |__|_ \\\___  >\___  >   __/ \___  >__|
     \/           \/            \/    \/     \/|__|        \/
ENDOFTYPO
)"

# Make sure to use root user
sudo su

# Check if dnsmasq package is installed
if [[ ! -n $(dpkg -l | grep dnsmasq) ]]; then
    # Update apt repositories
    apt-get -y update
    # Install ...
    apt-get install -y curl vim git build-essential                 # ... requirements
    apt-get install -y apache2 php5 libapache2-mod-php5 php5-mysql  # ... web server + php
    apt-get install -y dnsmasq                                      # ... dnsmasq
    # Apply base config for dnsmasq
    cp /vagrant/opt/dnsmasq.conf /etc/dnsmasq.conf
    cp /vagrant/opt/dnsmasq.hosts /etc/dnsmasq.hosts
    # Restart dnsmasq
    service dnsmasq restart
    # Final success message
    guestIP=$(ip address show eth1 | grep 'inet ' | sed -e 's/^.*inet //' -e 's/\/.*$//')
    echo "${asciitypo}"
    echo "---"
    echo "Try to run the following command on your host to test the DNS server:"
    echo "$ dig this.is.a.tld.test @${guestIP} +short"
    echo "Access the hostkeeper web interface:"
    echo "$ open http://${guestIP}"
fi
