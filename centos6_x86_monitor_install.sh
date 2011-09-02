################################################################################
#!/bin/bash																	   #
################################################################################
#																			   #
# bash script for installation of monitoring tools capable with CentOS 6.0 x86 #
# Author: Richard J. Breiten												   #
#		rbreiten@oplib.org													   #
#		Ouachita Parish Public Library										   #
# Updated 2011-08-29														   #
################################################################################
# Rev: 0.0.1				    											   #
################################################################################
#																			   #
# Todo list																	   #
# - upgrade process															   #
# -- Make sure all installations work and run without any issue				   #
# -- 																		   #
# -- Look at snmpwalk line...												   #
# -- Look at NagiosQL installation											   #
# -- Look at NConf installation												   #
# -- Look at NaReTo installation											   #
################################################################################

LOCATION=/opt

yum -y update
yum -y make
yum -y install yum-priorities

rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt

cd /opt/
# RPMForge 0.5.2-2 -- Updated 2010-11-13
wget http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.i386.rpm
rpm -K rpmforge-release-0.5.2-2.el6.rf.*.rpm
rpm -i rpmforge-release-0.5.2-2.el6.rf.*.rpm

yum -y install openssh-server

# Apache web server
yum -y httpd

# PHP and PHP web admin
yum -y php
yum -y phpmyadmin

# Assorted MySQL binaries
yum -y mysql-server
yum -y mysql
yum -y mysql-devel

# Perl plugin
yum -y install perl-Net-SSLeay

cd /usr/src
#Webmin 1.550 -- Updated 2011-04-26
wget http://sourceforge.net/projects/webadmin/files/webmin/1.550/webmin-1.550-1.noarch.rpm
rpm -i webmin-1.550-1.noarch.rpm

# NMap
yum -y install nmap

# Ethereal
yum -y install ethereal

# Common Linux/Unix Utilities
yum -y install httpd gcc glibc glibc-common gd gd-devel php

#useradd -m nagios
#passwd nagios
#groupadd nagmon
#usermod -a -G nagmon nagios
#usermod -a -G nagmon apache

# Nagios 3.3.1 -- Package last updated 2011-07-26
mkdir /opt/Nagios
cd /opt/Nagios
wget http://sourceforge.net/projects/nagios/nagios-3.3.1.tar.gz
tar xzvf nagios-3.3.1.tar.gz
cd nagios-3.3.1
./configure --with-command-group=nagmon
make all
make install
make install-init
make install-config
make install-commandmode
make install-webconf
htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin
service httpd restart

# Nagios Plugins -- Package last updated 2010-07-27
wget http://sourceforge.net/projects/nagiosplug/files/nagiosplug/1.4.15/nagios-plugins-1.4.15.tar.gz
cd /opt/Nagios
tar xzf nagios-plugins-1.4.15.tar.gz
cd nagios-plugins-1.4.15
./configure --with-nagios-user=nagios --with-nagios-group=nagios
make
make install
/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
chcon -R -t httpd_sys_content_t /usr/local/nagios/sbin/
chcon -R -t httpd_sys_content_t /usr/local/nagios/share/
chkconfig --add nagios
chkconfig nagios on
chkconfig httpd on
service nagios start

#yum -y install cacti
service snmpd start
chkconfig snmpd on

# oppl and localhost names will be the SNMP strings that will be searched - you 
# will need to change as needed
# Does not currently work at the moment...
snmpwalk -v 1 -c oppl localhost IP-MIB::ipAdEntIfIndex