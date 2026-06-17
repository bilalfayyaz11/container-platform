#!/usr/bin/env bash
set -euo pipefail

if [ ! -f api-endpoint.txt ]; then
  echo "api-endpoint.txt not found. Deploy API Gateway first."
  exit 1
fi

API_URL="$(cat api-endpoint.txt)"

curl -s "$API_URL?name=Docker&environment=AWS" | python3 -m json.tool
curl -s "$API_URL?message=Success&test=true" | python3 -m json.tool
