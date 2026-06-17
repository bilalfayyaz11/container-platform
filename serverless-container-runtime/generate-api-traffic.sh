#!/usr/bin/env bash
set -euo pipefail

if [ ! -f api-endpoint.txt ]; then
  echo "api-endpoint.txt not found. Deploy API Gateway first."
  exit 1
fi

API_URL="$(cat api-endpoint.txt)"

for i in {1..5}; do
  echo "Making request $i..."
  curl -s "$API_URL?request=$i&timestamp=$(date +%s)" | python3 -m json.tool
  sleep 2
done
