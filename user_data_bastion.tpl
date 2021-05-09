#! /bin/bash
sudo yum install -y postgresql-libs-9.2.24-1.amzn2.0.1.x86_64 postgresql-9.2.24-1.amzn2.0.1.x86_64

export PGHOST=${db_ip} 
export PGPORT=5432
export PGUSER=${pg_admin_user} 
export PGPASSWORD=${pg_admin_password}


psql -h ${db_ip} -p 5432 -U ${pg_admin_user} -w -c 'CREATE USER ${kong_bd_user}'
psql -h ${db_ip} -p 5432 -U ${pg_admin_user} -w -c "ALTER USER ${kong_bd_user} with password '${kong_bd_user_pass}'"
psql -h ${db_ip} -p 5432 -U ${pg_admin_user} -w -c 'GRANT ${kong_bd_user} TO postgres'
psql -h ${db_ip} -p 5432 -U ${pg_admin_user} -w -c 'CREATE DATABASE ${kong_bd_name} OWNER ${kong_bd_user}'