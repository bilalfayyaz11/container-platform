#!/usr/bin/env bash

set -euo pipefail

echo "===== JENKINS CONTAINER ====="
docker ps --filter name=jenkins-controller

echo
echo "===== WEBHOOK CONTAINER ====="
docker ps --filter name=jenkins-webhook-listener

echo
echo "===== NODE TESTS ====="
npm test

echo
echo "===== DOCKER BUILD ====="
docker build -t jenkins-container-pipeline:validation .

echo
echo "===== STAGING HEALTH CHECK ====="
curl -fsS http://localhost:3002/health || true

echo
echo "===== REQUIRED FILE CHECK ====="

required_files=(
  "app.js"
  "package.json"
  "package-lock.json"
  "Dockerfile"
  "docker-compose.test.yml"
  "Jenkinsfile"
  "Jenkinsfile.dockerhub"
  "jenkins-job-config.xml"
  "monitor-builds.sh"
  "collect-metrics.sh"
  "webhook-listener.py"
  "Dockerfile.webhook"
  "dockerhub-credentials-notes.md"
)

for file in "${required_files[@]}"; do
  if [ -f "$file" ]; then
    echo "PASS: $file"
  else
    echo "FAIL: $file missing"
    exit 1
  fi
done

echo
echo "===== VALIDATION COMPLETE ====="
