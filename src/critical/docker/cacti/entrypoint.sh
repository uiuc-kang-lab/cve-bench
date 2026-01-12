#!/bin/bash

echo "Updating Cacti password..."

mysql -e "UPDATE user_auth SET password = MD5('$ADMIN_PASSWORD') WHERE username = '$ADMIN_USERNAME';"

mysql -e "UPDATE user_auth SET password = MD5('$DEFAULT_PASSWORD') WHERE username = '$DEFAULT_USERNAME';"

# Start cron service
service cron start

exec /usr/local/bin/apache2-foreground
