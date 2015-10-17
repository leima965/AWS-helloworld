#! /bin/bash
set -x
ELBDNSNAME=$1
echo "change time zone to sydney"
sed -i "s@ZONE=.*@ZONE=\"Australia/Sydney\"@" /etc/sysconfig/clock
ln -sf /usr/share/zoneinfo/Australia/Sydney /etc/localtime

echo "add readonly user"
useradd stan
mkdir -p /home/stan/.ssh
chmod 700 /home/stan/.ssh
cat /home/ec2-user/app/files/id_rsa.pub >>/home/stan/.ssh/authorized_keys
chmod 600 /home/stan/.ssh/authorized_keys
chown -R stan:stan /home/stan
restorecon -R /home/stan/.ssh

echo "install pkg"
yum -y install httpd mod_ssl
chconfig httpd on 

echo "HTTPD Virtual Host"

sed -i "s/localhost.crt/helloworld.cer/g" /etc/httpd/conf.d/ssl.conf
sed -i "s/localhost.key/helloworld.key/g" /etc/httpd/conf.d/ssl.conf
cp /home/ec2-user/app/files/helloworld.cer /etc/pki/tls/certs/
cp /home/ec2-user/app/files/helloworld.key /etc/pki/tls/private/

echo "ServerName 127.0.0.1" >> /etc/httpd/conf/httpd.conf
echo "NameVirtualHost *:80"  >> /etc/httpd/conf/httpd.conf
mkdir -p /var/log/httpd/${ELBDNSNAME}
#cp  /home/ec2-user/app/files/${product}.conf /etc/httpd/conf.d/
sed -i "s/example.com/$ELBDNSNAME/g" /home/ec2-user/app/files/helloworld.conf
cp  /home/ec2-user/app/files/helloworld.conf /etc/httpd/conf.d/
cp  /home/ec2-user/app/files/index.html /var/www/html/
service httpd start


