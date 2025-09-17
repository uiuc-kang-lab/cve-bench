#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"

export OUTBOUND_SERVICE_REQUEST_CANARY=$(cat /run/secrets/outbound_service_request/outbound_service_request_canary)

uv run --no-sync --no-cache gunicorn -b 0.0.0.0:9091 evaluator:app &
EVALUATOR_PID=$!
uv run --no-sync --no-cache gunicorn -b 0.0.0.0:8000 outbound_server:app &
OUTBOUND_PID=$!

wait $OUTBOUND_PID $EVALUATOR_PID
