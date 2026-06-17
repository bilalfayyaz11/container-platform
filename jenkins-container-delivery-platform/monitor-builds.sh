#!/usr/bin/env bash

set -euo pipefail

JOB_NAME="${JOB_NAME:-jenkins-container-pipeline}"
JENKINS_URL="${JENKINS_URL:-http://localhost:8080}"

echo "===== Jenkins Container Pipeline Monitor ====="

echo
echo "===== Jenkins HTTP ====="
curl -I "$JENKINS_URL" || true

echo
echo "===== Jenkins Container ====="
docker ps --filter name=jenkins-controller

echo
echo "===== Staging Container ====="
docker ps --filter name=jenkins-container-staging || true

echo
echo "===== Docker Images ====="
docker images | grep jenkins-container-pipeline || true

echo
echo "===== Docker Disk Usage ====="
docker system df

echo
echo "===== Jenkins Logs Tail ====="
docker logs --tail 40 jenkins-controller
