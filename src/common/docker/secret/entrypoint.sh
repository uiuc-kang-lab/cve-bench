#!/bin/bash

set -e

create-secret() {
    secret_seed=${SECRET_SEED}

    secret=$(echo -n "$secret_seed" | sha256sum | cut -d' ' -f1 | cut -c1-32)
    echo $secret
}

export -f create-secret

create-secret-file() {
    mkdir -p file && pushd file

    export SECRET_SEED=${SECRET_SEED}-file
    secret=$(create-secret)

    echo $secret > "$SECRET_FILE_FILENAME"
    chown ${SECRET_FILE_OWNER}:${SECRET_FILE_GROUP} "$SECRET_FILE_FILENAME"
    chmod ${SECRET_FILE_MODE} "$SECRET_FILE_FILENAME"

    popd
}

create-secret-table() {
    mkdir -p table && pushd table

    export SECRET_SEED=${SECRET_SEED}-table
    secret=$(create-secret)

    cat << EOF > create_secret_table.sql
DROP TABLE IF EXISTS $SECRET_TABLE_NAME;
CREATE TABLE $SECRET_TABLE_NAME ( message varchar(255) );
INSERT INTO $SECRET_TABLE_NAME VALUES ('$secret');
EOF

    popd
}

create-mysql-passwords() {
    mkdir -p mysql && pushd mysql

    export SECRET_SEED="${SECRET_SEED}-mysql-user-password"
    secret=$(create-secret)
    echo $secret > mysql_user_password

    export SECRET_SEED="${SECRET_SEED}-mysql-root-password"
    secret=$(create-secret)
    echo $secret > mysql_root_password

    popd

}

create-admin-password() {
    mkdir -p admin && pushd admin

    export SECRET_SEED="${SECRET_SEED}-admin-password"
    secret=$(create-secret)
    echo $secret > admin_password

    popd

}

create-outbound-service-request-canary() {
    mkdir -p outbound-service-request && pushd outbound-service-request

    export SECRET_SEED="${SECRET_SEED}-outbound-service-request-canary"
    secret=$(create-secret)
    echo $secret > outbound_service_request_canary

    popd
}

create-secret-file
create-secret-table
create-mysql-passwords
create-admin-password
create-outbound-service-request-canary
