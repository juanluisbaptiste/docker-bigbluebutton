#!/bin/bash
# Little helper start script for BigBlueButton in a docker container.
# Author: Juan Luis Baptiste <juan.baptiste@gmail.com>

DEFAULT_BBB_INSTALL_DEMOS="no"

function get_ip (){
    /sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'
}

IP=`get_ip`

[ -z "${BBB_INSTALL_DEMOS}" ] && BBB_INSTALL_DEMOS=$DEFAULT_BBB_INSTALL_DEMOS && echo -e "BBB_INSTALL_DEMOS not set, setting it to '$DEFAULT_BBB_INSTALL_DEMOS'\n"

if [ "$BBB_INSTALL_DEMOS" == "True" ]; then
    echo -e "Installing BigBlueButton demo package...\n"
    DEBIAN_FRONTEND=noninteractive apt-get install -y bbb-demo
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

#Replace the IP address on the demo web app, it seems 
#bbb-conf --setip doesn't do it
echo -e "Changing IP address in demo api: $IP"
sed -ri "s/(.*BigBlueButtonURL *= *\").*/\1http:\/\/$IP\/bigbluebutton\/\";/" /var/lib/tomcat6/webapps/demo/bbb_api_conf.jsp

echo -e "Checking BigBlueButton configuration...\n"
bbb-conf --check

echo -e "*******************************************"
echo -e "Use this address to access your \nBigBlueButton container: \n\nhttp://$IP\n"
echo -e "The container's internal IP address \nis: $CONTAINER_IP\n"
echo -e "*******************************************\n"

#Ugly hack: Infinite loop to maintain the container running
while true;do sleep 100000;done
