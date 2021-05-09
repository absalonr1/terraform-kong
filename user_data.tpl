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
#touch test
#kong config init
#echo "admin_listen = 0.0.0.0:8001" >> /etc/kong/kong.conf
#echo "database = off" >> /etc/kong/kong.conf
#echo "declarative_config = /kong.yml"  >> /etc/kong/kong.conf
# FIN  

#Plugin keycloak - https://github.com/gbbirkisson/kong-plugin-jwt-keycloak
sudo /usr/local/bin/luarocks install kong-plugin-jwt-keycloak
export KONG_PLUGINS="bundled,jwt-keycloak"
export JWT_KEYCLOAK_PRIORITY="900"
echo "plugins = bundled,jwt-keycloak" >> /etc/kong/kong.conf

# Permite llamadas desde el LbaaS a las APIs de admin
echo "admin_listen = 0.0.0.0:8001" >> /etc/kong/kong.conf

#DB Postgres
export KONG_PASSWORD=kong
export KONG_LOG_LEVEL=error
echo "database = postgres" >> /etc/kong/kong.conf
echo "pg_host = ${db_ip}" >> /etc/kong/kong.conf
echo "pg_port = 5432" >> /etc/kong/kong.conf
echo "pg_user = ${db_pg_user}" >> /etc/kong/kong.conf
echo "pg_password =${db_pg_password}" >> /etc/kong/kong.conf
echo "pg_database =${db_pg_database}" >> /etc/kong/kong.conf


#-------------------------------------------------------------------
#---- a este punto ya debe estar el setup de postress antes de proceder 
#---- con el start de kong
#---- tarea manual mientras se ve como automatizar
#-------------------------------------------------------------------
sudo /usr/local/bin/kong migrations bootstrap [-c /etc/kong/kong.conf]
#/usr/local/bin/kong start [-c /etc/kong/kong.conf]