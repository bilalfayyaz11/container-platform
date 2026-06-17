#!/usr/bin/env bash

set -euo pipefail

echo "===== SELENIUM CONTAINER STATUS ====="
docker ps --filter name=selenium-chrome

echo
echo "===== SELENIUM IMAGE ====="
docker images | grep selenium

echo
echo "===== SELENIUM HUB STATUS ====="
curl -s http://localhost:4444/wd/hub/status | python3 -m json.tool

echo
echo "===== CONTAINER RESOURCE USAGE ====="
docker stats --no-stream selenium-chrome

echo
echo "===== LAST 50 LOG LINES ====="
docker logs --tail 50 selenium-chrome
