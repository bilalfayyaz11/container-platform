#!/usr/bin/env bash
set -euo pipefail

AWS_REGION="${AWS_REGION:-us-east-1}"
FUNCTION_NAME="${FUNCTION_NAME:-containerized-lambda-runtime}"

aws lambda invoke \
  --function-name "$FUNCTION_NAME" \
  --payload file://test-event.json \
  --region "$AWS_REGION" \
  response.json

cat response.json | python3 -m json.tool
