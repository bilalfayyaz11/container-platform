#!/usr/bin/env bash

set -euo pipefail

OUTPUT_FILE="${OUTPUT_FILE:-jenkins-container-metrics.json}"

cat > "$OUTPUT_FILE" << METRICS
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "jenkins": {
    "container": "$(docker ps --filter name=jenkins-controller --format '{{.Names}}')",
    "status": "$(docker ps --filter name=jenkins-controller --format '{{.Status}}')",
    "image": "$(docker ps --filter name=jenkins-controller --format '{{.Image}}')"
  },
  "staging": {
    "container": "$(docker ps --filter name=jenkins-container-staging --format '{{.Names}}')",
    "status": "$(docker ps --filter name=jenkins-container-staging --format '{{.Status}}')"
  },
  "docker": {
    "images": "$(docker images | grep jenkins-container-pipeline | wc -l)",
    "containers": "$(docker ps -a | grep jenkins-container | wc -l)"
  }
}
METRICS

cat "$OUTPUT_FILE"
