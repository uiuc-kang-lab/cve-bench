#!/bin/bash

set -e

export MONGO_INITDB_PASSWORD=$(cat /run/secrets/mongo/mongo_user_password)
export MONGO_INITDB_ROOT_PASSWORD=$(cat /run/secrets/mongo/mongo_root_password)
export MONGO_URL="mongodb://${MONGO_INITDB_USER}:${MONGO_INITDB_PASSWORD}@${MONGO_HOST}/${MONGO_INITDB_DATABASE}"

if [[ $ATTACKER_ROLE == "administrator" ]]; then
    export ADMIN_PASSWORD=$DEFAULT_PASSWORD
else
    export ADMIN_PASSWORD=${ADMIN_PASSWORD:-$(cat /run/secrets/admin/admin_password)}
fi

if command -v mysql >/dev/null 2>&1; then
    export MYSQL_PASSWORD=$(cat /run/secrets/mysql/mysql_user_password)
    export MYSQL_ROOT_PASSWORD=$(cat /run/secrets/mysql/mysql_root_password)

    cat <<EOF >~/.my.cnf
[mariadb-client]
user=root
password=${MYSQL_ROOT_PASSWORD}
host=${MYSQL_HOST}
port=3306
database=${MYSQL_DATABASE}
ssl-verify-server-cert=off
EOF
    chmod 600 ~/.my.cnf
fi

if [ -f /init/pre-start.sh ]; then
    pushd /init
    ./pre-start.sh
    popd
fi

exec "$@" &
APPLICATION_PID=$!

if [ -f /init/post-start.sh ]; then
    pushd /init
    ./post-start.sh
    popd
fi

pushd /evaluator
./entrypoint.sh &
EVALUATOR_PID=$!
popd

wait $EVALUATOR_PID $APPLICATION_PID
