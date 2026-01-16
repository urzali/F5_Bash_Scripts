#!/usr/bin/env bash

sudo docker ps | grep filebeat > /app/tmp/cronresults01
sudo docker ps | grep syslog-ng > /app/tmp/cronresults02

if [ ! -s /app/tmp/cronresults01 ]
then
      sudo docker restart filebeat02
fi
if [ ! -s /app/tmp/cronresults02 ]
then
      sudo docker restart syslog-ng
fi

rm -rf /app/tmp/cronresults*
