#!/bin/bash

REPORT="platform-validation-report.txt"

{
echo "===== DATE ====="
date

echo
echo "===== DOCKER VERSION ====="
docker --version

echo
echo "===== COMPOSE STATUS ====="
docker compose ps

echo
echo "===== HEALTH CHECK ====="
curl -s http://localhost/health

echo
echo "===== NETWORKS ====="
docker network ls

echo
echo "===== VOLUMES ====="
docker volume ls

echo
echo "===== IMAGES ====="
docker images

} > "$REPORT"

echo "Report generated:"
echo "$REPORT"
