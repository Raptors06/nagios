################################################################################
#!/bin/bash																	   #
################################################################################
#																			   #
# bash script for installation of monitoring tools capable with CentOS 5.5 x86 #
# Author: Richard J. Breiten												   #
#		rbreiten@oplib.org													   #
#		Ouachita Parish Public Library										   #
# Updated 2012-05-29														   #
################################################################################
# Rev: 0.1.1				    											   #
################################################################################
#																			   #
# Todo list																	   #
# - upgrade process															   #
# -- Make sure all installations work and run without any issue				   #
# -- Look at adding in for MRTG install to keep files locally				   #
# -- Look at snmpwalk line...												   #
# -- Look at NagiosQL installation											   #
# -- Look at NConf installation												   #
# -- Look at NaReTo installation											   #
# -- Clean up files downloaded, etc...										   #
################################################################################

LOCATION=/opt

# Update yum repositories
yum -y update

# Install Linux/Unix utilities to make install files
yum -y install make
yum -y install yum-priorities

# Common Linux/Unix Utilities
yum -y install gcc gcc-c++ libstdc++ glib2-devel glibc glibc-common gd gd-devel perl-GD libpng-devel libjpeg-devel
yum -y install rrdtool fping cpp fontconfig-devel openssl-devel
yum -y install net-snmp net-snmp-libs net-snmp-utils dmidecode lm_sensors

rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt

cd /opt/
# RPMForge 0.5.2-2 -- Updated 2010-11-13
wget http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.2-2.el5.rf.i386.rpm
rpm -K rpmforge-release-0.5.2-2.el5.rf.*.rpm
rpm -i rpmforge-release-0.5.2-2.el5.rf.*.rpm

# OpenSSH server for remote access
yum -y install openssh-server

# Apache web server
yum -y install httpd

# PHP and PHP web admin
yum -y install php php-gd php-mysql php-pear
pear channel-update pear.php.net
#pear config-set http_proxy http://my_proxy.com:port #IF USING A PROXY!!
pear upgrade-all
yum -y install php-ldap php-xml php-mbstring php-snmp
yum -y install phpmyadmin

# Assorted MySQL binaries
yum -y install mysql mysql-server mysql-devel
/etc/init.d/mysqld start
chkconfig --add mysqld

#!!!!!!!Will need to check if mysql commands can be used in a batch script like this
#mysql -u root

# Perl plugins
yum -y install perl-Net-SSLeay perl-Crypt-DES perl-Digest-SHA1 perl-Digest-HMAC perl-Socket6 perl-IO-Socket-INET6
yum -y install perl-DBI perl-DBD-MySQL perl-Config-IniFiles perl-rrdtool

cd /usr/src
# Webmin 1.580 -- Updated 2012-01-22
wget http://sourceforge.net/projects/webadmin/files/webmin/1.580/webmin-1.580-1.noarch.rpm
rpm -i webmin-1.580-1.noarch.rpm

# NMap
yum -y install nmap

# Ethereal
yum -y install ethereal

service snmpd start
chkconfig snmpd on
# oppl and localhost names will be the SNMP strings that will be searched - you 
# will need to change as needed
# Does not currently work at the moment...
# snmpwalk -v 1 -c oppl localhost IP-MIB::ipAdEntIfIndex

#########################################
# -- Beginning of Nagios Installation-- #
#########################################
# useradd -m nagios
# passwd nagios
# groupadd nagmon
# /usr/sbin/usermod -L nagios
# /usr/sbin/groupadd nagcmd
# /usr/sbin/usermod -G nagios,nagcmd nagios
# /usr/sbin/usermod -G nagios,nagcmd apache

#useradd -m nagios
#passwd nagios
#groupadd nagmon
#usermod -a -G nagmon nagios
#usermod -a -G nagmon apache

# Nagios 3.4.1 -- Package last updated 2011-05-14
#Maybe just use yum install nagios??? Would this be advisable? Will have to see - FAN uses a different mirror...

# mkdir /opt/Nagios
# cd /opt/Nagios
cd /opt/
wget http://sourceforge.net/projects/nagios/files/nagios-3.x/nagios-3.4.1/nagios-3.4.1.tar.gz
tar xzvf nagios-3.4.1.tar.gz
mv /opt/nagios-3.4.1/ /opt/nagios/
cd nagios
./configure --with-command-group=nagmon --enable-nanosleep --enable-event-broker
make all
make install
make install-init
make install-config
make install-commandmode
make install-webconf
htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin
service httpd restart

####################################
# ---Nagios Plugin Installation--- #
####################################
# Plugin #1 - Nagios Plugins
#	Package last updated 2010-07-27
yum -y install openldap-devel
yum -y install samba-client libsmbclient
cd /opt/
wget http://sourceforge.net/projects/nagiosplug/files/nagiosplug/1.4.15/nagios-plugins-1.4.15.tar.gz
tar xvf nagios-plugins-1.4.15.tar.gz
mv /opt/nagios-plugins-1.4.15/ /opt/nagios-plugins
cd nagios-plugins
./configure --with-nagios-user=nagios --with-nagios-group=nagmon --with-openssl=/usr/bin/openssl --enable-perl-modules
make
make install

# Plugin #2 - NRPE 2.13 -- Package last updated 2011-11-11
#	Package last updated 
cd /opt/
wget http://sourceforge.net/projects/nagios/files/nrpe-2.x/nrpe-2.13/nrpe-2.13.tar.gz
tar xvf nrpe-2.13.tar.gz
mv /opt/nrpe-2.13/ /opt/nrpe/
cd nrpe
./configure --with-ssl=/usr/bin/openssl --with-ssl-lib=/usr/lib
make all
make install-plugin

# Plugin #3 - NSCA 2.9.1 -- Package last updated 2007-07-03
cd /opt/
wget http://sourceforge.net/projects/nagios/files/nsca-2.x/nsca-2.9.1/nsca-2.9.1.tar.gz
tar xvf nsca-2.9.1.tar.gz
mv /opt/nsca-2.9.1/ /opt/nsca
cd nsca
#./configure
#make all
#make install-plugin


######################################
# ---Nagios NDOUtils Installation--- #
######################################
# Package last updated 2012-05-17
cd /opt/
wget http://prdownloads.sourceforge.net/sourceforge/nagios/ndoutils-1.5.1.tar.gz
tar xzf ndoutils-1.5.1.tar.gz
mv /opt/ndoutils-1.5.1/ /opt/ndoutils
cd ndoutils
#!!!WILL NEED TO CHECK SINCE VERSION HAS INCREMENTED!!!
#less README
#wget http://svn.centreon.com/trunk/ndoutils-patch/ndoutils1.4b9_light.patch
#patch -p1 -N < ndoutils1.4b9_light.patch
#less README
./configure --prefix=/opt/nagios/ --enable-mysql --disable-pgsql \ --with-ndo2db-user=nagios --with-ndo2db-group=nagios
make
cp ./src/ndomod-3x.o /opt/nagios/bin/ndomod.o
cp ./src/ndo2db-3x /opt/nagios/bin/ndo2db
cp ./config/ndo2db.cfg-sample /opt/nagios/etc/ndo2db.cfg
cp ./config/ndomod.cfg-sample /opt/nagios/etc/ndomod.cfg
sudo chmod 774 /opt/nagios/bin/ndo*
sudo chown nagios:nagios /opt/nagios/bin/ndo*
cp ./daemon-init /etc/init.d/ndo2db
chmod +x /etc/init.d/ndo2db
chkconfig --add ndo2db


#######################################
# ---Nagios Configuration Utilties--- #
#######################################
# Uncomment the lines for the desired Nagios configuration utility
# Option 1 - Centreon 2.3.8 -- Package last updated 2012-05-10
#cd /opt
#wget http://download.centreon.com/centreon/centreon-2.3.8.tar.gz
#tar xzf centreon-2.3.8.tar.gz
#mv /opt/centreon-2.3.8 /opt/centreon
#cd centreon
#export PATH="$PATH:/usr/opt/nagios/bin/"
#./install.sh -i
# Here begins the required manual entering of information for installing
#    the Centreon web front, CentCore, Centreon Nagios Plugins, and SNMP
#    Traps process.  Additionally, locations of directories, etc, will
#    need to be input, beginning with the Centreon Web interface.

# Option 2 - NagiosQL 3.2.0 -- Package last updated 2012-04-26
#pear install HTML_Template_IT
#cd /opt
#wget http://sourceforge.net/projects/nagiosql/files/nagiosql/NagiosQL 3.2.0/nagiosql_320.tar.gz
#tar xzf nagiosql_320.tar.gz
#mv /opt/nagiosql_320 /var/www/nagiosql
#cd /var/www/nagiosql
# No clue after this - will have to actually run an installation to see...
#service httpd reload

# Option 3 - NConf 1.3.0-0 -- Package last updated 2011-12-11
#cd /opt
#wget http://sourceforge.net/projects/nconf/files/nconf/1.3.0-0/nconf-1.3.0-0.tar.gz
#tar xzf nconf-1.3.0-0.tar.gz
#mv /opt/nconf-1.3.0-0 /opt/nconf
#cd nconf
# No clue after this - will have to actually run an installation to see...

service httpd reload


#####################################
# ---Nagios Visuals Installation--- #
#####################################
# Package last updated 2011-07-31
cd /opt/
wget http://sourceforge.net/projects/nagvis/files/NagVis 1.7/nagvis-1.7b1.tar.gz
tar xzf nagvis-1.7b1.tar.gz
mv /opt/nagvis-1.7b1 /opt/nagvis/
cd nagvis
chmod +x install.sh
./install.sh


#############################################
# ---Nagios Reporting Tools Installation--- #
#############################################
# Package last updated ????-??-??
cd /opt/
wget http://www.nareto.org/srcs/nareto-1.1.7.tar.bz2
tar xzf nareto-1.1.7.tar.bz2
# Will need to figure out the rest of the installation instructions...


/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
#chcon -R -t httpd_sys_content_t /usr/local/nagios/sbin/
#chcon -R -t httpd_sys_content_t /usr/local/nagios/share/
chkconfig --add nagios
chkconfig nagios on
chkconfig httpd on
service nagios start

#yum -y install cacti

###############################
# ---Ozeki NG SMS Delivery--- #
###############################
# Will need to check to see if this actually works...
yum -y install mono-* libgdiplus-* ibm-* byte-*
cd /opt/
# Download Ozeki NG 3.15.6 package
wget http://ozekisms.com/attachments/524/OzekiNG_SMS_Gateway-3.15.6.tgz
tar xzvf OzekiNG_SMS_Gateway-3.15.6.tgz
ln -s OzekiNG_SMS_Gateway-3.15.6 /opt/ozeking
# Add to ip tables to allow firewall to accept connections on this port
iptables -I INPUT -p tcp --dport 9501 -j ACCEPT
# Added to run Ozeki NG in the background
cp /opt/ozeking/distributions/Fedora/init.d/ozeking /etc/init.d/
/etc/init.d/ozeking start

######################################
# ---Finalization check of Nagios--- #
######################################
/etc/init.d/mysql status
/etc/init.d/apache2 status
/etc/init.d/ndo2db status
/etc/init.d/centstorage status
/etc/init.d/nagios status
/etc/init.d/snmpd status

#Clean up downloaded files, etc, here
cd /opt/
rm -f rpmforge-release-0.5.2-2.el5.rf.*.rpm
rm -f webmin-1.580-1.noarch.rpm
rm -f nagios-3.4.1.tar.gz
rm -f nagios-plugins-1.4.15.tar.gz
rm -f nrpe-2.13.tar.gz
rm -f nsca-2.9.1.tar.gz
rm -f ndoutils-1.5.1.tar.gz
rm -f ndoutils1.4b9_light.patch
rm -f centreon-2.3.8.tar.gz
rm -f nagiosql_320.tar.gz
rm -f nconf-1.3.0-0.tar.gz
rm -f nagvis-1.7b1.tar.gz
rm -f nareto-1.1.7.tar.bz2
rm -f OzekiNG_SMS_Gateway-3.15.6.tgz
