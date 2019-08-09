#!/bin/bash

home_path=/etc/zabbix
zabpath=/etc/zabbix/zabbix_agentd.conf

if [ -d "$home_path" ]; then
 echo "Zabix is already installed. Terminated!"
 exit 1;
else
 rpm -ivh http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-release-3.4-1.el7.centos.noarch.rpm
 yum -y install zabbix-agent
 systemctl stop zabbix-agent;
 touch $home_path/zabbix_agentd.psk
 openssl rand -hex 32 > $home_path/zabbix_agentd.psk
 if [ -f "$zabpath" ]; then
  sed -i 's/^Server=127.0.0.1$/Server=10.1.10.7/' $zabpath
  sed -i 's/^ServerActive=127.0.0.1$/ServerActive=10.1.10.7/' $zabpath
  sed -i 's/^# TLSConnect=unencrypted$/TLSConnect=psk/' $zabpath
  sed -i 's/^# TLSAccept=unencrypted$/TLSAccept=psk/' $zabpath
  sed -i 's/^# TLSPSKIdentity=$/TLSPSKIdentity='$HOSTNAME'/' $zabpath
  sed -i 's/^# Hostname=$/Hostname='$HOSTNAME'/' $zabpath
  sed -i 's/# TLSPSKFile=/TLSPSKFile=\/\etc\/\zabbix\/\zabbix_agentd.psk/' $zabpath
  chown zabbix: /etc/zabbix
  touch $home_path/info.txt
  hostname >> $home_path/info.txt
  ip a | grep [YOURNETWORK] | awk {'print $2'} | sed 's/\/24//' >> $home_path/info.txt
  cat $home_path/zabbix_agentd.psk >> $home_path/info.txt
  systemctl start zabbix-agent
  systemctl enable zabbix-agent
 else
  echo "File is not created $zabpath"
  exit 1;
 fi
fi