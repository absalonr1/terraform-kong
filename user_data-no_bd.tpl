#! /bin/bash
wget https://bintray.com/kong/kong-rpm/download_file?file_path=amazonlinux/amazonlinux2/kong-2.4.0.aws.amd64.rpm -o kong-2.4.0.aws.amd64.rpm
sudo yum install kong-2.4.0.aws.amd64.rpm --nogpgcheck
sudo yum update -y
sudo yum install -y wget
wget https://bintray.com/kong/kong-rpm/rpm -O bintray-kong-kong-rpm.repo
sed -i -e 's/baseurl.*/&\/amazonlinux\/amazonlinux'/ bintray-kong-kong-rpm.repo
sudo mv bintray-kong-kong-rpm.repo /etc/yum.repos.d/
sudo yum update -y
sudo yum install -y kong
sudo yum install -y git
cp /etc/kong/kong.conf.default /etc/kong/kong.conf

# INICIO : lo siguiente es solo para pruebas. No usa BD
touch test
kong config init
echo "admin_listen = 0.0.0.0:8001" >> /etc/kong/kong.conf
echo "database = off" >> /etc/kong/kong.conf
echo "declarative_config = /kong.yml"  >> /etc/kong/kong.conf
# FIN  

/usr/local/bin/kong start [-c /etc/kong/kong.conf]