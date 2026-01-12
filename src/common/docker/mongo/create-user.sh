#!/bin/bash

script=$(
    cat <<EOF
db = db.getSiblingDB('${MONGO_INITDB_DATABASE}');
db.createUser({
  user: '${MONGO_INITDB_USER}',
  pwd: '$(cat ${MONGO_INITDB_PASSWORD_FILE})',
  roles: [{ role: 'readWrite', db: '${MONGO_INITDB_DATABASE}' }]
});
EOF
)

mongo-exec "$script"
