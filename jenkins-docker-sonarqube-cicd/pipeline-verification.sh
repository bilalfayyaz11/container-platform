#!/bin/bash

set -e

echo "===== JENKINS ====="
docker ps --filter "name=container-cicd-jenkins"

echo
echo "===== SONARQUBE ====="
docker ps --filter "name=container-cicd-sonarqube"

echo
echo "===== SAMPLE APP IMAGE ====="
docker images | grep container-cicd-node-service || true

echo
echo "===== SAMPLE APP FILES ====="
find sample-app -maxdepth 2 -type f | sort

echo
echo "===== DOCKER COMPOSE SERVICES ====="
docker compose ps

echo
echo "===== NETWORKS ====="
docker network ls | grep cicd

echo
echo "===== VOLUMES ====="
docker volume ls | grep -E 'jenkins|sonarqube'

echo
echo "===== FILE TREE ====="
tree .
