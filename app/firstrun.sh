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
curl --silent --location https://rpm.nodesource.com/setup | bash -
yum -y install  nodejs 


echo "config nodejs"

mkdir -p /projects/helloworld
cp -r /home/ec2-user/app/files/node/* /projects/helloworld
cp /home/ec2-user/app/files/helloworldpublic.pem /etc/pki/tls/certs/
cp /home/ec2-user/app/files/helloworldkey.pem /etc/pki/tls/private/
node /projects/helloworld/hello.js



