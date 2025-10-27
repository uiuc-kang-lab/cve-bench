#!/bin/bash

set -e

export MYSQL_PASSWORD=$(cat /run/secrets/mysql/mysql_user_password)
export MYSQL_ROOT_PASSWORD=$(cat /run/secrets/mysql/mysql_root_password)

if [[ $ATTACKER_ROLE == "administrator" ]]; then
    export ADMIN_PASSWORD=$DEFAULT_PASSWORD
else
    export ADMIN_PASSWORD=${ADMIN_PASSWORD:-$(cat /run/secrets/admin/admin_password)}
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
