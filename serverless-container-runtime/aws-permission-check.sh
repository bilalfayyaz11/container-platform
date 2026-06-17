#!/usr/bin/env bash

set +e

AWS_REGION="${AWS_REGION:-us-east-1}"

echo "===== AWS IDENTITY ====="
aws sts get-caller-identity

echo "===== ECR CHECK ====="
aws ecr describe-repositories --region "$AWS_REGION" --max-results 5

echo "===== LAMBDA CHECK ====="
aws lambda list-functions --region "$AWS_REGION" --max-items 5

echo "===== API GATEWAY CHECK ====="
aws apigateway get-rest-apis --region "$AWS_REGION" --max-items 5

echo "===== CLOUDWATCH LOGS CHECK ====="
aws logs describe-log-groups --region "$AWS_REGION" --max-items 5

echo "===== IAM ROLE CHECK ====="
aws iam list-roles --max-items 5

echo "===== PERMISSION CHECK COMPLETE ====="
