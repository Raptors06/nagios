################################################################################
#!/bin/bash																	   #
################################################################################
#																			   #
# bash script for installation of monitoring tools capable with CentOS 6.4 x64 #
# Author: Richard J. Breiten												   #
#		richard.j.breiten@gmail.com											   #
# Updated 11-Sep-2013  														   #
################################################################################
# Rev: 0.0.1				    											   #
################################################################################
#																			   #
# Todo list																	   #
# -- Add Splunk or PNP4Nagios??												   #
# -- Make sure all installations work and run without any issue				   #
# -- Look at adding in for MRTG install to keep files locally				   #
# -- Look at snmpwalk line...												   #
# -- Look at NagiosQL installation											   #
# -- Look at NConf installation												   #
# -- Look at NaReTo installation											   #
# -- Clean up files downloaded, etc...										   #
################################################################################

cd /opt/

echo 'Installing RPMForge 0.5.3-1';
# RPMForge 0.5.3-1 -- Updated 20-Mar-2013
wget http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
rpm -K rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
rpm -i rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm

echo 'Installing EPEL';
# Extra Packages for Enterprise Linux (EPEL) -- Updated 05-Nov-2012
rpm -ivh http://mirror.pnl.gov/epel//6Server/x86_64/epel-release-6-8.noarch.rpm

echo 'Updating yum repositories';
# Update yum repositories
yum -y update

echo 'Installing utilities';
# Install Linux/Unix utilities to make install files
yum -y install make
yum -y install yum-priorities

# Linux/Unix Utilities
yum -y install g++ libc-dev gcc gcc-c++ libstdc++ glib2-devel glibc glibc-common gd gd-devel perl-GD libpng-devel libjpeg-devel perl-DBD-MySQL perl-Socket6
yum -y install rrdtool fping cpp fontconfig-devel openssl-devel
yum -y install net-snmp net-snmp-libs net-snmp-utils dmidecode lm_sensors
yum -y install sharutils #required to send email attachments

rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt

# OpenSSH server for remote access
yum -y install openssh-server

# Apache web server
yum -y install httpd

# PHP and PHP web admin, etc
yum -y install php php-gd php-mysql php-pear php-date php-mail-mime php-net-smtp php-net-socket php5-xmlrpc php-imap php5-sqlite sqlite3

pear channel-update pear.php.net
#pear config-set http_proxy http://my_proxy.com:port #IF USING A PROXY!!
pear install -o -f -alldeps DB_DataObject DB_DataObject_FormBuilder MDB2 Numbers_Roman
pear install -o -f -alldeps Numbers_Words HTML_Common HTML_QuickForm2 HTML_QuickForm_advmultiselect HTML_Table Auth_SASL
pear install -o -f -alldeps HTTP Image_Canvas Image_Color Image_Graph Image_GraphViz Net_Traceroute Net_Ping Validate XML_RPC
pear install -o -f -alldeps SOAP
pear upgrade-all
yum -y install php-ldap php-xml php-mbstring php-snmp php-mcrypt
yum -y install phpmyadmin

# Assorted MySQL binaries
yum -y install mysql mysql-server mysql-devel
/etc/init.d/mysqld start
chkconfig --add mysqld
#yum -y install ndoutils-mysql ##<<--Better way of installing NDOUtils?##

#!!!!!!!Will need to check if mysql commands can be used in a batch script like this
#mysql -u root
#create database nagios;
#GRANT ALL ON nagios.* TO nagios@localhost IDENTIFIED BY "nagios";
#FLUSH PRIVILEGES;
#quit
#<<EOFMYSQL
#EOFMYSQL #--should end MySQL commands...

echo 'Installing Perl plugins';
# Perl plugins
yum -y install perl-Net-SSLeay perl-Crypt-DES perl-Digest-SHA1 perl-Digest-HMAC perl-Socket6 perl-IO-Socket-INET6
yum -y install perl-Net-SNMP net-snmp-perl perl-DBI perl-DBD-MySQL perl-Config-IniFiles perl-rrdtool perl-Crypt-DES

# Other Apps
yum -y install fping graphviz 

cd /usr/src
# Webmin 1.580 -- Updated 2012-01-22
# This will allow modifications to OS through http://ip-address:10000
wget http://sourceforge.net/projects/webadmin/files/webmin/1.580/webmin-1.580-1.noarch.rpm
rpm -i webmin-1.580-1.noarch.rpm

# NMap
yum -y install nmap

# Ethereal
yum -y install ethereal

service snmpd start
chkconfig snmpd on

###Does not currently work at the moment...###
# snmpwalk -v 1 -c oppl localhost IP-MIB::ipAdEntIfIndex ###<<-- Figure out snmpwalk issues###

#Configure firewall rule for Apache on port 80
echo 'Configuring Firewall rules for Apache';
sudo iptables -I INPUT -p tcp --dport 80 -j ACCEPT
sudo service iptables save

chkconfig ntpd on
ntpdate pool.ntp.org
service ntpd start

#########################################
# -- Beginning of Nagios Installation-- #
#########################################

# Nagios 3.4.1 -- Package last updated 2011-05-14
#Maybe just use yum to install nagios??? Would this be advisable? Will have to see - FAN uses a different mirror...

# mkdir /opt/Nagios
# cd /opt/Nagios
cd /opt/
wget http://sourceforge.net/projects/nagios/files/nagios-3.x/nagios-3.4.1/nagios-3.4.1.tar.gz
tar xzvf nagios-3.4.1.tar.gz
cd nagios
./configure --enable-embedded-perl --prefix=/usr/local/nagios --with-cgiurl=/nagios/cgi-bin --with-htmurl=/nagios/ --enable-nanosleep --enable-event-broker
useradd -m nagios
passwd nagios
##Here you will be asked to enter a password for the user "nagios"##
make all
make install
make install-init
make install-config
make install-commandmode
make install-webconf
htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin
##Here you will be asked to enter a pssword for the user "nagiosadmin"##
service httpd restart
service nagios restart
chkconfig --add httpd
chkconfig --level 35 httpd on
chkconfig --add nagios
chkconfig --level 35 httpd on

####################################
# ---Nagios Plugin Installation--- #
####################################
# Plugin #1 - Nagios Plugins
#	Package last updated 2010-07-27
echo 'Installing Plugin #1 - Nagios Plugins 1.4.15';
yum -y install openldap-devel postgresql-devel radiusclient-ng-devel
yum -y install samba-client libsmbclient
cd /opt/
wget http://sourceforge.net/projects/nagiosplug/files/nagiosplug/1.4.15/nagios-plugins-1.4.15.tar.gz
tar xvf nagios-plugins-1.4.15.tar.gz
mv /opt/nagios-plugins-1.4.15/ /opt/nagios-plugins/
cd nagios-plugins
./configure --prefix=/usr/local/nagios --with-nagios-user=nagios --with-openssl=/usr/bin/openssl --enable-perl-modules
make all
make install

# Plugin #2 - NRPE 2.13 -- Package last updated 2011-11-11
echo 'Installing Plugin #2 - NRPE 2.13';
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
echo 'Installing Plugin #3 - NSCA 2.9.1';
cd /opt/
wget http://sourceforge.net/projects/nagios/files/nsca-2.x/nsca-2.9.1/nsca-2.9.1.tar.gz
tar xvf nsca-2.9.1.tar.gz
mv /opt/nsca-2.9.1/ /opt/nsca/
cd nsca
./configure
make all

# Plugin #4 - check_wmi_plus -- Check this - http://alexnogard.com/monitorer-windows-avec-nagios-centreon/
echo 'Installing Plugin #4 - check_wmi_plus';
cd /usr/lib64/nagios/plugins/
wget http://edcint.co.nz/checkwmiplus/sites/default/files/check_wmi_plus.v1.50.tar.gz
tar -xvzf check_wmi_plus.v1.50.tar.gz
yum -y install autoconf python
wget http://alexnogard.com/wp-content/uploads/wmi-1.3.16.tar.bz2
tar -xf wmi-1.3.16.tar
cd wmi-1.3.16/
make

######################################
# ---Nagios NDOUtils Installation--- #
######################################
# Package last updated 2012-05-17
cd /opt/
wget http://prdownloads.sourceforge.net/sourceforge/nagios/ndoutils-1.5.1.tar.gz
tar xzf ndoutils-1.5.1.tar.gz
mv /opt/ndoutils-1.5.1/ /opt/ndoutils
cd ndoutils
./configure --prefix=/usr/local/nagios/ --enable-mysql --disable-pgsql --with-ndo2db-user=nagios --with-ndo2db-group=nagios
make
cp ./src/ndomod-3x.o /usr/local/nagios/bin/ndomod.o
cp ./src/ndo2db-3x /usr/local/nagios/bin/ndo2db
cp ./config/ndo2db.cfg-sample /usr/local/nagios/etc/ndo2db.cfg
cp ./config/ndomod.cfg-sample /usr/local/nagios/etc/ndomod.cfg
sudo chmod 774 /usr/local/nagios/bin/ndo*
sudo chown nagios:nagios /usr/local/nagios/bin/ndo*
cp ./daemon-init /etc/init.d/ndo2db
chmod +x /etc/init.d/ndo2db
chkconfig --add ndo2db
service ndo2db status
service ndo2db start
/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
/etc/init.d/nagios restart


#######################################
# ---Nagios Configuration Utilties--- #
#######################################
# Uncomment the lines for the desired Nagios configuration utility
# Option 1 - Centreon 2.3.8 -- Package last updated 2012-05-10
#cd /opt
#useradd -g centreon centreon
#wget http://download.centreon.com/centreon/centreon-2.3.8.tar.gz
#tar xzf centreon-2.3.8.tar.gz
#mv /opt/centreon-2.3.8 /opt/centreon
#cd centreon
#export PATH="$PATH:/usr/opt/nagios/bin/"
#./install.sh -f ./centreon/answer
# Here begins the required manual entering of information for installing
#    the Centreon web front, CentCore, Centreon Nagios Plugins, and SNMP
#    Traps process.  Additionally, locations of directories, etc, will
#    need to be input, beginning with the Centreon Web interface.
#One thing I will note is that the RRD perl module is installed at /usr/lib/perl5/vendor_perl/5.8.8/i386-linux-thread-multi/RRDs.pm
#Also, PEAR.php is located, by default, in /usr/share/pear/PEAR.php
#And, if needed for whatever reason, NDO is at /usr/local/nagios/bin/ndomod.o
#yum -y install policycoreutils-python
#semanage fonctext -a -t httpd_sys_rw_content_t "/usr/local/centreon(/.*)?"
#restorecon -R /usr/local/centreon/
#semanage fcontext -a -t httpd_sys_rw_content_t "/etc/centreon(/.*)?"
#restorecon -R /etc/centreon
#semanage fcontext -a -t httpd_sys_rw_content_t "/usr/local/nagios/var/spool(/.*)?"
#semanage fcontext -a -t httpd_sys_content_t "/usr/local/nagios/share(/.*)?"
#restorecon -R /usr/local/nagios/
#semanage fcontext -a -t httpd_sys_content_t "/usr/share/php(/.*)?"
#restorecon -R /usr/share/php
#semanage fcontext -a -t httpd_sys_content_t "/usr/share/pear(/.*)?"
#restorecon -R /usr/share/pear
 
### Restart some services ###
#service httpd restart
#service ndo2db restart
#service nagios restart

#mysql -e "grant all on centreon.* to 'centreon'@localhost identified by 'CentreonDBPassword';"
#mysql -e "grant all on centreon_storage.* to 'centreon'@localhost identified by 'CentreonDBPassword';"
#mysql -e "grant all on centreon_status.* to 'centreon'@localhost identified by 'CentreonDBPassword';"


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
wget http://sourceforge.net/projects/nagvis/files/NagVis%201.7/nagvis-1.7.9.tar.gz
tar zxvf nagvis-1.7.9.tar.gz
mv /opt/nagvis-1.7.9 /opt/nagvis/
cd nagvis
chmod +x install.sh
./install.sh -p /usr/local/nagvis -b ido2db -u www-data -g www-data -w /etc/apache2/conf.d/ -a y -F

# This will install PHPWeathermap for an additional Nagios visual through Centreon - http://alexnogard.com/tuto-installation-de-phpweathermap-centreon-2-3-8/
yum -y install subversion
cd /root
svn checkout http://svn.modules.centreon.com/centreon-weathermap/
cd centreon-weathermap
dos2unix /trunk/install.sh
dos2unix /trunk/install/gettex.sh
chmod -R 755 /root/centreon-weathermap/trunk/install.sh
cd trunk
./install.sh -u /etc/centreon


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

####################################
# ---Cisco MRTG Router Graphing--- #
####################################
# Version 2.17.4 Package last updated 2012-01-12
cd /opt/
#Install MRTG dependencies first
wget http://www.zlib.net/zlib-1.2.6.tar.gz
gunzip -c zlib-1.2.10.tar.gz | tar xf -
mv zlib-1.2.10/ zlib/
cd zlib
./configure --prefix=/opt/zlib/
make
cd ..
wget ftp://ftp.simplesystems.org/pub/libpng/png/src/libpng-1.2.49.tar.gz
gunzip -c libpng-1.2.49.tar.gz | tar xf -
mv libpng-1.2.49/ libpng/
cd libpng
env CFLAGS="-O3 -fPIC" LDFLAGS="-L=/opt/zlib/" ./configure --prefix=$INSTALL_DIR
make
rm *.so.* *.so
cd ..
wget http://www.boutell.com/gd/http/gd-2.0.33.tar.gz
gunzip -c gd-2.0.33.tar.gz | tar xf -
mv gd-2.0.33/ gd/
cd gd
env CPPFLAGS="I../zlib -I../libpng" LDFLAGS="-L../zlib -L../libpng" ./configure --disable-shared --without-freetype --without-jpeg
make
cd ..
cd /opt/
wget http://oss.oetiker.ch/mrtg/pub/mrtg-2.17.4.tar.gz
gunzip -c mrtg-2.17.4.tar.gz | tar xvf -
mv mrtg-2.17.4/ mrtg/
cd mrtg
./configure --prefix=/opt/mrtg --with-gd=/opt/gd --with-z=/opt/zlib --with-png=/opt/libpng
make



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

##################################################
# ---Postfix Admin - A GUI-based Postfix Tool--- #
##################################################
#mysql
#CREATE DATABASE postfix;
#CREATE USER 'user'@'LOCALHOST' IDENTIFIED BY 'password';
#GRANT ALL PRIVILEGES ON 'postfix' . * TO 'user'@'LOCALHOST';
#<<EOFMYSQL
cd /opt/
wget http://sourceforge.net/projects/postfixadmin/files/postfixadmin/postfixadmin/postfixadmin-2.3.5.tar.gz
tar xvzf postfixadmin-2.3.5.tar.gz
mv postfixadmin-2.3.5/ /var/www/html/postfixadmin/
#You MUST edit the config.inc.php file within the postfixadmin/. This required password input, etc.
#See this link - http://tek.io/M4cBJU - for more information on setting up postfixadmin.
/etc/init.d/httpd restart


######################################
# ---Finalization check of Nagios--- #
######################################
/etc/init.d/mysql status
/etc/init.d/apache2 status
/etc/init.d/ndo2db status
/etc/init.d/centstorage status
/etc/init.d/nagios status
/etc/init.d/snmpd status
/etc/init.d/httpd status

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
rm -f zlib-1.2.10.tar.gz
rm -f libpng-1.2.49.tar.gz
rm -f postfixadmin-2.3.5.tar.gz
