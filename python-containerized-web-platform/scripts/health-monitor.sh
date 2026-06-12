#!/bin/bash

echo "===== PLATFORM HEALTH REPORT ====="

echo
echo "===== CONTAINERS ====="
docker compose ps

echo
echo "===== WEB HEALTH ====="
curl -s http://localhost/health && echo

echo
echo "===== RESOURCE USAGE ====="
docker stats --no-stream

echo
echo "===== NETWORKS ====="
docker network ls

echo
echo "===== VOLUMES ====="
docker volume ls
