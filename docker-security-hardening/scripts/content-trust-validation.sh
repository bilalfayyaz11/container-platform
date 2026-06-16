#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="localhost:5000/hardened-python-runtime"
SIGNED_TAG="1.0.0"
UNSIGNED_TAG="unsigned"

echo "===== LOCAL REGISTRY CHECK ====="
docker ps --format '{{.Names}}' | grep -q '^local-secure-registry$'

echo "===== TAG IMAGE ====="
docker tag hardened-python-runtime:local "${IMAGE_NAME}:${SIGNED_TAG}"
docker tag hardened-python-runtime:local "${IMAGE_NAME}:${UNSIGNED_TAG}"

echo "===== PUSH IMAGE TO LOCAL REGISTRY ====="
docker push "${IMAGE_NAME}:${SIGNED_TAG}"
docker push "${IMAGE_NAME}:${UNSIGNED_TAG}"

echo "===== DOCKER CONTENT TRUST VERIFICATION ATTEMPT ====="
echo "Docker Content Trust requires a Notary-compatible trust server."
echo "A plain registry:2 container does not provide this trust service."

set +e
DOCKER_CONTENT_TRUST=1 docker pull "${IMAGE_NAME}:${SIGNED_TAG}"
SIGNED_STATUS=$?

DOCKER_CONTENT_TRUST=1 docker pull "${IMAGE_NAME}:${UNSIGNED_TAG}"
UNSIGNED_STATUS=$?
set -e

cat > reports/content-trust-results.txt << REPORT
Docker Content Trust validation attempt completed.

Signed tag pull exit code: ${SIGNED_STATUS}
Unsigned tag pull exit code: ${UNSIGNED_STATUS}

Explanation:
Docker Content Trust requires a Notary-compatible trust service in addition to the image registry.
The local registry:2 container stores image manifests and layers, but it does not provide a Notary signing backend.
This is why DCT verification may fail or not behave as the lab text expects when only registry:2 is deployed.
REPORT

cat reports/content-trust-results.txt
