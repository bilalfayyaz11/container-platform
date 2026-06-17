#!/usr/bin/env bash
set -euo pipefail

AWS_REGION="${AWS_REGION:-us-east-1}"
FUNCTION_NAME="${FUNCTION_NAME:-containerized-lambda-runtime}"
API_NAME="${API_NAME:-containerized-lambda-runtime-api}"

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"

API_ID="$(aws apigateway create-rest-api \
  --name "$API_NAME" \
  --description "REST endpoint for containerized Lambda runtime" \
  --region "$AWS_REGION" \
  --query 'id' \
  --output text)"

ROOT_RESOURCE_ID="$(aws apigateway get-resources \
  --rest-api-id "$API_ID" \
  --region "$AWS_REGION" \
  --query 'items[0].id' \
  --output text)"

RESOURCE_ID="$(aws apigateway create-resource \
  --rest-api-id "$API_ID" \
  --parent-id "$ROOT_RESOURCE_ID" \
  --path-part hello \
  --region "$AWS_REGION" \
  --query 'id' \
  --output text)"

aws apigateway put-method \
  --rest-api-id "$API_ID" \
  --resource-id "$RESOURCE_ID" \
  --http-method GET \
  --authorization-type NONE \
  --region "$AWS_REGION"

LAMBDA_ARN="$(aws lambda get-function \
  --function-name "$FUNCTION_NAME" \
  --region "$AWS_REGION" \
  --query 'Configuration.FunctionArn' \
  --output text)"

aws apigateway put-integration \
  --rest-api-id "$API_ID" \
  --resource-id "$RESOURCE_ID" \
  --http-method GET \
  --type AWS_PROXY \
  --integration-http-method POST \
  --uri "arn:aws:apigateway:$AWS_REGION:lambda:path/2015-03-31/functions/$LAMBDA_ARN/invocations" \
  --region "$AWS_REGION"

aws lambda add-permission \
  --function-name "$FUNCTION_NAME" \
  --statement-id "api-gateway-invoke-$API_ID" \
  --action lambda:InvokeFunction \
  --principal apigateway.amazonaws.com \
  --source-arn "arn:aws:execute-api:$AWS_REGION:$ACCOUNT_ID:$API_ID/*/GET/hello" \
  --region "$AWS_REGION"

aws apigateway create-deployment \
  --rest-api-id "$API_ID" \
  --stage-name prod \
  --region "$AWS_REGION"

API_URL="https://$API_ID.execute-api.$AWS_REGION.amazonaws.com/prod/hello"

cat > api-endpoint.txt << ENDPOINT
$API_URL
ENDPOINT

echo "API Endpoint: $API_URL"
