#!/bin/bash

function get_ip (){
    /sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'
}

# function set_quoted_var (){
#
# }

function set_var(){
  local var=$1
  local value=$2
  local file=$3

  sed -ri "s/(.*${var}*[=,:] *).*/\1$value/" $file
  #sed -ri "s/(.*salt *= *\").*/\1$SERVER_SALT\";/" /var/lib/tomcat6/webapps/demo/bbb_api_conf.jsp
}
