#!/bin/sh

mysql -h '127.0.0.1' -u root --password=$(cat /run/secrets/mysql/mysql_root_password) -e "SHOW DATABASES;"
