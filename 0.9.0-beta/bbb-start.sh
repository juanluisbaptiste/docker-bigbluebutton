#!/bin/bash
# Little helper start script for BigBlueButton in a docker container.
# Author: Juan Luis Baptiste <juan.baptiste@gmail.com>

. /functions.sh

DEFAULT_DEBUG="no"
DEFAULT_BBB_INSTALL_DEMOS="no"

[ -z "${DEBUG}" ] && DEBUG=$DEFAULT_DEBUG
if [ ! -z "${DEBUG}" -a "${DEBUG}" == "yes" ]; then
    echo -e "\e[92mPreparing debug mode...\n\e[0m"
    DEBIAN_FRONTEND=noninteractive apt-get install -y nmap lsof telnet bbb-check
    [ $? -gt 0 ] && echo - "ERROR: Could not intall tools." && exit 1
    echo -e "\e[92mDone.\e[0m\n"
    set -x
fi

IP=`get_ip`

service tomcat7 start

[ -z "${BBB_INSTALL_DEMOS}" ] && BBB_INSTALL_DEMOS=$DEFAULT_BBB_INSTALL_DEMOS
if [ ! -z "$BBB_INSTALL_DEMOS" -a "$BBB_INSTALL_DEMOS" == "yes" ]; then
    echo -e "\e[92mInstalling BigBlueButton demo package...\n\e[0m"
    DEBIAN_FRONTEND=noninteractive apt-get install -y bbb-demo
    [ $? -gt 0 ] && echo - "ERROR: Could not intall the demos." && exit 1
    echo -e "\e[92mDone.\e[0m\n"
fi


echo -e "\e[92mStarting BigBlueButton services...\e[0m"
service redis-server start
#service bbb-openoffice-headless start
echo -e "\e[92mUpdating BigBlueButton IP address configuration...\e[0m"

if [ ! -z "$SERVER_NAME" ];then
    echo -e "\n\e[92mUsing $SERVER_NAME as hostname.\e[0m"
    #Add an entry to /etc/hosts pointing the container IP address
    #to $SERVER_NAME
    printf '%s\t%s\n' $IP $SERVER_NAME | cat >> /etc/hosts
    #printf '%s\t%s\n' 127.0.0.1 $SERVER_NAME | cat >> /etc/hosts
    CONTAINER_IP=$IP
    IP=$SERVER_NAME
fi
#Set new hostname
bbb-conf --setip $IP

#Fixing SIP configuration
#set_var "sip.server.host" "127.0.0.1" /usr/share/red5/webapps/sip/WEB-INF/bigbluebutton-sip.properties
#Add SIP server configuration
#sed -i '1s/^/sip.server.host=127.0.0.1\n/' /usr/share/red5/webapps/sip/WEB-INF/bigbluebutton-sip.properties
#sed -i '2s/^/sip.server.port=5070\n/' /usr/share/red5/webapps/sip/WEB-INF/bigbluebutton-sip.properties
#Add freeswitch configuration
#set_var "freeswitch.ip" "127.0.0.1" /usr/share/red5/webapps/sip/WEB-INF/bigbluebutton-sip.properties
#set_var "freeswitch.port" "5060" /usr/share/red5/webapps/sip/WEB-INF/bigbluebutton-sip.properties
#set_var "bbb.sip.app.ip" "127.0.0.1" /usr/share/red5/webapps/sip/WEB-INF/bigbluebutton-sip.properties
#set_var "bbb.sip.app.port" "5070" /usr/share/red5/webapps/sip/WEB-INF/bigbluebutton-sip.properties
#Comment this line
#set_var "local_ip_v4" "127.0.0.1\"\/>" /opt/freeswitch/conf/vars.xml
#sed -i "s/<X-PRE-PROCESS cmd=\"set\" data=\"local_ip_v4=*/<\!--<X-PRE-PROCESS cmd=\"set\" data=\"local_ip_v4=/; /<X-PRE-PROCESS cmd=\"set\" data=\"local_ip_v4=*/s/\"\/>/\"\/>-->/" /opt/freeswitch/conf/vars.xml
#set_var "bind_server_ip" "${CONTAINER_IP}\"\/>" /opt/freeswitch/conf/vars.xml
#set_var "external_rtp_ip" "${CONTAINER_IP}\"\/>" /opt/freeswitch/conf/vars.xml
#set_var "external_sip_ip" "${CONTAINER_IP}\"\/>" /opt/freeswitch/conf/vars.xml
#sed -i -r "/ext-rtp-ip/s/(.*value*[=,:] *\").*/\1\$\$\{external_rtp_ip\}\"\/>/" /opt/freeswitch/conf/sip_profiles/external.xml
#sed -i -r "/ext-sip-ip/s/(.*value*[=,:] *\").*/\1\$\$\{external_sip_ip\}\"\/>/" /opt/freeswitch/conf/sip_profiles/external.xml
#sed -i -r "s/(.*proxy_pass http:\/\/*).*/\1${CONTAINER_IP}:5066;/" /etc/bigbluebutton/nginx/sip.nginx

#Replace the IP address on the demo web app, it seems
#bbb-conf --setip doesn't do it
echo -e "\n\e[92mChanging IP address in demo API:\e[0m $IP"
sed -ri "s/(.*BigBlueButtonURL *= *\").*/\1http:\/\/$IP\/bigbluebutton\/\";/" /var/lib/tomcat7/webapps/demo/bbb_api_conf.jsp
#It seems that some times bbb-conf --setsecret doesn't set the secret on the demo api conf file.
sed -ri "s/(.*salt *= *\").*/\1$SERVER_SALT\";/" /var/lib/tomcat7/webapps/demo/bbb_api_conf.jsp

#Set the mobile salt to enable mobile access
[ ! -z $MOBILE_SALT ] && echo -e "\n\e[92mSetting mobile salt to:\e[0m $MOBILE_SALT"
[ ! -z $MOBILE_SALT ] && sed -ri "s/(.*mobileSalt *= *\").*/\1$MOBILE_SALT\";/" /var/lib/tomcat7/webapps/demo/mobile_conf.jsp

[ ! -z $SERVER_SALT ] && echo -e "\n\e[92mSetting Salt to:\e[0m $SERVER_SALT" && bbb-conf --setsecret $SERVER_SALT

[ -z "${DEBUG}" ] && set +x
#For some reason sometimes meetings fail when started from mconf-web
#until we clean the installation
echo -e "\n\e[92mCleaning configuration...\n\e[0m"
bbb-conf --clean

# echo -e "\n\e[92mChecking configuration...\n"
# bbb-conf --check

echo -e "\n\e[92m*******************************************\e[0m"
echo -e "\n\e[0mUse this address to access your \nBigBlueButton container:\e[92m \n\nhttp://$IP\n\e[0m"
echo -e "\n\e[0mThe container's internal IP address \nis:\e[92m $CONTAINER_IP\n\e[0m"
echo -e "\n\e[92m*******************************************\e[0m\n"

#Ugly hack: Infinite loop to maintain the container running
while true;do sleep 100000;done
