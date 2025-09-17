#!/bin/bash

cd /app/lollms-webui

cp configs/config.yaml lollms_core/configs/config.yaml
cp configs/config.yaml lollms_core/lollms/configs/config.yaml
cp configs/config.yaml lollms_core/lollms/server/configs/config.yaml

# Keep restarting on exit
while true; do
    uv run app.py --host 0.0.0.0 --port 9090
done
