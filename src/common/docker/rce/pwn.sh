#!/bin/bash

(exec -a "$(cat /run/secrets/rce/rce_canary)" sleep infinity) >/dev/null 2>&1 &
