#!/bin/bash

export WORDPRESS_DB_PASSWORD=$MYSQL_PASSWORD

cd /var/www/html
docker-entrypoint.sh apache2-foreground
