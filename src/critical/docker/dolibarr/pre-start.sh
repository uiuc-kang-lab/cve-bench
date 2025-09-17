#!/bin/bash

MYSQL_REGULAR_USER=$MYSQL_USER
export MYSQL_USER=root
export MYSQL_PWD=$MYSQL_ROOT_PASSWORD

for f in /var/www/html/install/mysql/tables/*.sql; do
  if [[ $f != *.key.sql ]]; then
    echo "Importing table from `basename $f`..."
    sed -i 's/--.*//g;' $f # remove all comment
    mysql $MYSQL_DATABASE < $f
  fi
done

for f in /var/www/html/install/mysql/tables/*.key.sql; do
  echo "Importing table key from `basename $f`..."
  sed -i 's/--.*//g;' $f
  mysql $MYSQL_DATABASE < $f
done

for f in /var/www/html/install/mysql/functions/*.sql; do
  echo "Importing `basename $f`..."
  sed -i 's/--.*//g;' $f
  mysql $MYSQL_DATABASE < $f
done

for f in /var/www/html/install/mysql/data/*.sql; do
  echo "Importing data from `basename $f`..."
  sed -i 's/--.*//g;' $f
  mysql $MYSQL_DATABASE < $f
done

echo "Create SuperAdmin account ..."
admin_pass_crypted=`echo -n $ADMIN_PASSWORD | md5sum | awk '{print $1}'`
mysql $MYSQL_DATABASE -e "INSERT INTO llx_user (entity, login, pass_crypted, lastname, admin, statut) VALUES (0, '${ADMIN_USERNAME}', '${admin_pass_crypted}', 'SuperAdmin', 1, 1);"

echo "Create user account ..."
user_pass_crypted=`echo -n $DEFAULT_PASSWORD | md5sum | awk '{print $1}'`
mysql $MYSQL_DATABASE -e "INSERT INTO llx_user (entity, login, pass_crypted, lastname, statut) VALUES (1, '${DEFAULT_USERNAME}', '${user_pass_crypted}', 'Default', 1);"

echo "Set some default const ..."
mysql $MYSQL_DATABASE -e "DELETE FROM llx_const WHERE name='MAIN_VERSION_LAST_INSTALL';"
mysql $MYSQL_DATABASE -e "DELETE FROM llx_const WHERE name='MAIN_NOT_INSTALLED';"
mysql $MYSQL_DATABASE -e "DELETE FROM llx_const WHERE name='MAIN_LANG_DEFAULT';"
mysql $MYSQL_DATABASE -e "INSERT INTO llx_const(name,value,type,visible,note,entity) values('MAIN_VERSION_LAST_INSTALL', '${DOLI_VERSION}', 'chaine', 0, 'Dolibarr version when install', 0);"
mysql $MYSQL_DATABASE -e "INSERT INTO llx_const(name,value,type,visible,note,entity) VALUES ('MAIN_LANG_DEFAULT', 'auto', 'chaine', 0, 'Default language', 1);"

export MYSQL_USER=$MYSQL_REGULAR_USER

cat <<EOF > /usr/local/etc/php/php.ini
date.timezone = UTC
sendmail_path = /usr/sbin/sendmail -t -i
EOF

cat <<EOF > /var/www/html/conf/conf.php
<?php
\$dolibarr_main_url_root='http://0.0.0.0';
\$dolibarr_main_document_root='/var/www/html';
\$dolibarr_main_url_root_alt='/custom';
\$dolibarr_main_document_root_alt='/var/www/html/custom';
\$dolibarr_main_data_root='/var/www/documents';
\$dolibarr_main_db_host='${MYSQL_HOST}';
\$dolibarr_main_db_port='3306';
\$dolibarr_main_db_name='${MYSQL_DATABASE}';
\$dolibarr_main_db_prefix='llx_';
\$dolibarr_main_db_user='${MYSQL_USER}';
\$dolibarr_main_db_pass='${MYSQL_PASSWORD}';
\$dolibarr_main_db_type='mysqli';
\$dolibarr_main_prod='0';
EOF

chown www-data:www-data /var/www/html/conf/conf.php
chmod 400 /var/www/html/conf/conf.php

touch /var/www/documents/install.lock
chown www-data:www-data /var/www/documents/install.lock
chmod 400 /var/www/documents/install.lock
