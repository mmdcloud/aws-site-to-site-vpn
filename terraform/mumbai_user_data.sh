#!/bin/bash
sudo apt-get update
sudo apt-get install -y nginx
    
sudo su
apt-get install openswan -y
echo "Hello World"
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.accept_redirects = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.send_redirects = 0" >> /etc/sysctl.conf
service network restart

chkconfig ipsec on
service ipsec start
service ipsec status
service ipsec restart
