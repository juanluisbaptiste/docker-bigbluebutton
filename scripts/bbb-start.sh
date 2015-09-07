#!/bin/bash
# Little helper start script for BigBlueButton in a docker container.
# Author: Juan Luis Baptiste <juan.baptiste@gmail.com>

DEFAULT_BBB_INSTALL_DEMOS="no"

function get_ip (){
    /sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'
}

IP=`get_ip`

if [ ! -z $BBB_INSTALL_DEMOS -a "$BBB_INSTALL_DEMOS" == "yes" ]; then
    echo -e "\n\e[92mInstalling BigBlueButton demo package...\n\e[0m"
    DEBIAN_FRONTEND=noninteractive apt-get install -y bbb-demo
    [ $? -gt 0 ] && echo - "ERROR: Could not intall the demos." && exit 1
    echo -e "\n\e[92mDone.\e[0m\n"
fi

echo -e "Starting BigBlueButton services...\n"
service redis-server-2.2.4 start
service bbb-openoffice-headless start
echo -e "Updating BigBlueButton IP address configuration...\n"

if [ ! -z "$SERVER_NAME" ];then
    echo -e "Using $SERVER_NAME as hostname."
    #Add an entry to /etc/hosts pointing the container IP address 
    #to $SERVER_NAME
    printf '%s\t%s\n' $IP $SERVER_NAME | cat >> /etc/hosts    
    CONTAINER_IP=$IP
    IP=$SERVER_NAME
fi
bbb-conf --setip $IP
[ ! -z $SERVER_SALT ] && echo -e "Setting Salt to: $SERVER_SALT" && bbb-conf --setsecret $SERVER_SALT

#Replace the IP address on the demo web app, it seems 
#bbb-conf --setip doesn't do it

#For some reason sometimes meetings fail when started from mconf-web
#until we clean the installation
echo -e "Cleaning configuration...\n"
bbb-conf --clean

echo -e "Checking configuration...\n"
bbb-conf --check

echo -e "*******************************************"
echo -e "Use this address to access your \nBigBlueButton container: \n\nhttp://$IP\n"
echo -e "The container's internal IP address \nis: $CONTAINER_IP\n"
echo -e "*******************************************\n"

#Ugly hack: Infinite loop to maintain the container running
while true;do sleep 100000;done
