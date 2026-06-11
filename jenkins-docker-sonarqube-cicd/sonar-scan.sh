#!/bin/bash

set -e

SONAR_HOST_URL="${SONAR_HOST_URL:-http://localhost:9000}"
SONAR_PROJECT_KEY="container-cicd-node-service"

if [ -z "$SONAR_TOKEN" ]; then
  echo "SONAR_TOKEN is not set."
  echo "Create a token in SonarQube, then run:"
  echo "export SONAR_TOKEN=your-token"
  exit 1
fi

docker run --rm \
  --network docker-cicd-automation_cicd-network \
  -e SONAR_HOST_URL="http://sonarqube:9000" \
  -e SONAR_TOKEN="$SONAR_TOKEN" \
  -v "$(pwd)/sample-app:/usr/src" \
  sonarsource/sonar-scanner-cli:latest \
  -Dsonar.projectKey="$SONAR_PROJECT_KEY" \
  -Dsonar.sources=. \
  -Dsonar.exclusions=node_modules/**,coverage/**,.git/**
