#!/usr/bin/env bash
set -euo pipefail

AWS_REGION="${AWS_REGION:-us-east-1}"
FUNCTION_NAME="${FUNCTION_NAME:-containerized-lambda-runtime}"

START_TIME="$(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S)"
END_TIME="$(date -u +%Y-%m-%dT%H:%M:%S)"

echo "===== LAMBDA INVOCATIONS ====="
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Invocations \
  --dimensions Name=FunctionName,Value="$FUNCTION_NAME" \
  --start-time "$START_TIME" \
  --end-time "$END_TIME" \
  --period 300 \
  --statistics Sum \
  --region "$AWS_REGION"

echo "===== LAMBDA DURATION ====="
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Duration \
  --dimensions Name=FunctionName,Value="$FUNCTION_NAME" \
  --start-time "$START_TIME" \
  --end-time "$END_TIME" \
  --period 300 \
  --statistics Average Maximum \
  --region "$AWS_REGION"
