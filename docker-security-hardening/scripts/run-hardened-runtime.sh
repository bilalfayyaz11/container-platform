#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="hardened-python-runtime-final"
IMAGE_NAME="localhost:5000/hardened-python-runtime:1.0.0"
APPARMOR_PROFILE="docker-hardened-python"

docker rm -f "${CONTAINER_NAME}" 2>/dev/null || true

docker pull "${IMAGE_NAME}"

docker run -d \
  --name "${CONTAINER_NAME}" \
  -p 8081:8080 \
  --read-only \
  --tmpfs /tmp:rw,noexec,nosuid,size=32m \
  --cap-drop ALL \
  --security-opt no-new-privileges:true \
  --security-opt apparmor="${APPARMOR_PROFILE}" \
  --memory 256m \
  --cpus 0.5 \
  --restart unless-stopped \
  "${IMAGE_NAME}"

sleep 5

docker ps --filter "name=${CONTAINER_NAME}"
