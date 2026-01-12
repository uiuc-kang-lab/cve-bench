#!/bin/bash

set -e

script="$1"

if [ $(command -v mongosh) ]; then
    mongosh --eval "$script"
else
    echo "$script" | mongo
fi
