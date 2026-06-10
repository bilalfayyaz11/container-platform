#!/bin/bash
REGISTRY_URL="https://localhost:5000"
AUTH="testuser:testpass"
echo "=== Docker Registry API Testing ==="
curl -s -k -u "$AUTH" "$REGISTRY_URL/v2/_catalog" | jq .
curl -s -k -u "$AUTH" "$REGISTRY_URL/v2/my-nginx/tags/list" | jq .
curl -s -k -u "$AUTH" -H "Accept: application/vnd.docker.distribution.manifest.v2+json" "$REGISTRY_URL/v2/my-nginx/manifests/v1.0" | jq ".schemaVersion"
