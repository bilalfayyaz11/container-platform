#!/usr/bin/env bash
set -euo pipefail

AWS_REGION="${AWS_REGION:-us-east-1}"
REPOSITORY_NAME="${REPOSITORY_NAME:-containerized-lambda-runtime}"
FUNCTION_NAME="${FUNCTION_NAME:-containerized-lambda-runtime}"
ROLE_NAME="${ROLE_NAME:-containerized-lambda-runtime-execution-role}"

if [ -f api-endpoint.txt ]; then
  API_ID="$(cut -d'.' -f1 api-endpoint.txt | sed 's#https://##')"
  aws apigateway delete-rest-api \
    --rest-api-id "$API_ID" \
    --region "$AWS_REGION" || true
fi

aws lambda delete-function \
  --function-name "$FUNCTION_NAME" \
  --region "$AWS_REGION" || true

aws ecr delete-repository \
  --repository-name "$REPOSITORY_NAME" \
  --force \
  --region "$AWS_REGION" || true

aws iam detach-role-policy \
  --role-name "$ROLE_NAME" \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole || true

aws iam delete-role \
  --role-name "$ROLE_NAME" || true

echo "Cleanup completed or skipped where resources were unavailable."
