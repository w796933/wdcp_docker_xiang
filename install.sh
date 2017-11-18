#!/bin/bash
#
# Author:wdlinux QQ:12571192
# Url:http://www.wdlinux.cn
# Last Updated 2016.05
#

yum install -y gcc gcc-c++ make autoconf libtool-ltdl-devel sudo bzip2 libxml2-devel ntp vixie-cron curl crontabs vixie-cron
ntpdate tiger.sina.com.cn
hwclock -w

Cur=`pwd`
DL_URL="http://dl.wdlinux.cn/"
W_URL="http://www.wdlinux.cn/"
R7=0
grep -q 'release 7' /etc/redhat-release && R7=1
cd $Cur
if [ ! -f squid-3.1.23.tar.gz ];then
wget -c ${DL_URL}/files/squid/squid-3.1.23.tar.gz
$? != 0 && exit
fi
tar zxvf squid-3.1.23.tar.gz
cd squid-3.1.23
./configure \
        --prefix=/www/wdlinux/squid \
        --with-pthreads \
        --enable-storeio="aufs,ufs" \
        --enable-async-io \
        --disable-internal-dns \
        --enable-stacktraces \
        --disable-ident-lookups \
        --enable-removal-policies='heap,lru' \
        --with-aio \
        --with-filedescriptors=65536 \
	--enable-async-io=240 \
	--enable-poll \
	--enable-large-cache-files \
	--enable-delay-pools \
	--enable-snmp \
	--enable-underscore \
	--enable-cache-digests \
	--enable-dlmalloc \
	--enable-gnuregex \
	--enable-err-language="Simplify_Chinese" \
	--enable-default-err-languages="Simplify_Chinese"
[ $? != 0 ] && exit
make
[ $? != 0 ] && exit
make install
[ $? != 0 ] && exit
/usr/sbin/groupadd -g 23 squid
/usr/sbin/useradd -g 23 -u 23 -d /var/spool/squid -r -s /sbin/nologin squid
if [[ -f /usr/sbin/squid ]];then
        rm -f /usr/sbin/squid
        rm -f /etc/rc.d/init.d/squid
        mv /etc/squid/squid.conf /etc/squid/squid.conf.old
fi

cd /www/wdlinux/squid/etc
mv squid.conf squid.conf.1
cd $Cur
mkdir /www/wdlinux/squid/etc/conf
mkdir /www/wdlinux/squid/etc/site
wget -cq ${W_URL}conf/squid/squid3.conf -O /www/wdlinux/squid/etc/squid.conf
wget -cq ${W_URL}conf/squid/disk.conf -O /www/wdlinux/squid/etc/conf/disk.conf
wget -cq ${W_URL}conf/squid/refresh_pattern.conf -O /www/wdlinux/squid/etc/conf/refresh_pattern.conf
touch /www/wdlinux/squid/etc/site/site.conf
touch /www/wdlinux/squid/etc/site/domainlist.txt
echo "wdcdn.com" > /www/wdlinux/squid/etc/site/domainlist.txt

cd $Cur
wget -cq ${W_URL}conf/init.d/squid -O /etc/rc.d/init.d/squid
chmod 755 /etc/rc.d/init.d/squid
chkconfig --add squid
chkconfig --level 35 squid on
ln -sf /www/wdlinux/squid/sbin/squid /usr/sbin/squid
#cd /etc/sysconfig/
cd $Cur
wget -cq ${W_URL}conf/sysconfig/squid -O /etc/sysconfig/squid
chown -R squid.squid /www/wdlinux/squid/var
/www/wdlinux/squid/sbin/squid -k parse
/www/wdlinux/squid/sbin/squid -z
service squid restart

##wdcdn
cd $Cur
ver="v2.0"
bit=`getconf LONG_BIT`
filename=wdcdn_${ver}_${bit}.tar.gz
ind="/www/wdlinux/wdcdn"
if [ ! -d $ind ];then
mkdir -p $ind
fi
cd $ind
wget -c ${DL_URL}/files/wdcdn/$filename
if [ $? == 0 ];then
tar zxvf $filename
mkdir {conf,logs,data,tmp}
ln -sf bin/wdcdn_${ver}_${bit} wdcdn
chown root.root bin favicon.ico html static conf -R
chmod 700 data conf bin html
if [ $R7 == 1 ];then
    cp -f /www/wdlinux/wdcdn/wdcdn.sh /etc/init.d/wdcdn
else
    ln -sf /www/wdlinux/wdcdn/wdcdn.sh /etc/init.d/wdcdn
fi
chkconfig --add wdcdn
chkconfig --level 35 wdcdn on
#service wdcdn start
#rm -f $filename
fi
cd -

###iptables
#/sbin/iptables -I INPUT -p tcp --dport 80 -j ACCEPT
#/sbin/iptables -I INPUT -p tcp --dport 8090 -j ACCEPT
#/sbin/iptables-save > /etc/sysconfig/iptables

###
