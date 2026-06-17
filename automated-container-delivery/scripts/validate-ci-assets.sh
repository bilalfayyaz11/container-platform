#!/usr/bin/env bash
set -euo pipefail

echo "===== REQUIRED FILE CHECK ====="

required_files=(
  "package.json"
  "package-lock.json"
  "app.js"
  "test.js"
  "Dockerfile"
  "docker-compose.yml"
  "nginx.conf"
  ".github/workflows/container-pipeline.yml"
  "scripts/integration-test.sh"
  "scripts/update-version.sh"
  "docker-hub-secrets.md"
  "docker-hub-publishing-readiness.md"
  ".gitignore"
  ".dockerignore"
)

for file in "${required_files[@]}"; do
  if [ -f "$file" ]; then
    echo "PASS: $file"
  else
    echo "FAIL: $file missing"
    exit 1
  fi
done

echo "===== NODE TEST ====="
npm test

echo "===== DOCKER BUILD ====="
docker build -t github-actions-container-pipeline:validation .

echo "===== COMPOSE CONFIG ====="
docker compose config >/tmp/compose-validation.yml
echo "PASS: Docker Compose configuration is valid"

echo "===== WORKFLOW YAML PRESENCE ====="
grep -q "Container Delivery Pipeline" .github/workflows/container-pipeline.yml
grep -q "docker/build-push-action@v6" .github/workflows/container-pipeline.yml
grep -q "docker compose up -d" .github/workflows/container-pipeline.yml
echo "PASS: Workflow includes build, compose test, and publish actions"

echo "===== VALIDATION COMPLETE ====="
