#!/usr/bin/env bash
set -euo pipefail

AWS_REGION="${AWS_REGION:-us-east-1}"
FUNCTION_NAME="${FUNCTION_NAME:-containerized-lambda-runtime}"
LOG_GROUP="/aws/lambda/$FUNCTION_NAME"

echo "===== LOG GROUP CHECK ====="
aws logs describe-log-groups \
  --log-group-name-prefix "$LOG_GROUP" \
  --region "$AWS_REGION"

echo "===== LATEST LOG STREAM ====="
LOG_STREAM="$(aws logs describe-log-streams \
  --log-group-name "$LOG_GROUP" \
  --order-by LastEventTime \
  --descending \
  --max-items 1 \
  --region "$AWS_REGION" \
  --query 'logStreams[0].logStreamName' \
  --output text)"

echo "$LOG_STREAM"

echo "===== RECENT LOG EVENTS ====="
aws logs get-log-events \
  --log-group-name "$LOG_GROUP" \
  --log-stream-name "$LOG_STREAM" \
  --region "$AWS_REGION" \
  --query 'events[*].[timestamp,message]' \
  --output table
