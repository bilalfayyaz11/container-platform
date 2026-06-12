#!/bin/bash

echo "===== AWS ECS READINESS VALIDATION ====="

echo
echo "===== AWS CLI VERSION ====="
aws --version || echo "AWS CLI not installed"

echo
echo "===== CALLER IDENTITY ====="
aws sts get-caller-identity || echo "AWS identity unavailable"

echo
echo "===== REGION ====="
aws configure get region || echo "No default region configured"

echo
echo "===== VPC PERMISSION CHECK ====="
aws ec2 describe-vpcs \
--query 'Vpcs[*].[VpcId,CidrBlock,IsDefault]' \
--output table || echo "FAILED: Missing ec2:DescribeVpcs permission"

echo
echo "===== SUBNET PERMISSION CHECK ====="
aws ec2 describe-subnets \
--query 'Subnets[*].[SubnetId,AvailabilityZone,VpcId]' \
--output table || echo "FAILED: Missing ec2:DescribeSubnets permission"

echo
echo "===== ECS CLUSTER PERMISSION CHECK ====="
aws ecs list-clusters || echo "FAILED: Missing ecs:ListClusters permission"

echo
echo "===== ECS ACCOUNT SETTINGS CHECK ====="
aws ecs list-account-settings --effective || echo "FAILED: Missing ecs:ListAccountSettings permission"

echo
echo "===== TASK EXECUTION ROLE CHECK ====="
aws iam get-role --role-name ecsTaskExecutionRole || echo "FAILED: ecsTaskExecutionRole missing or IAM permission denied"

echo
echo "===== DOCKER CHECK ====="
docker --version || echo "Docker not installed"

echo
echo "===== LOCAL DOCKER STATUS ====="
docker ps || echo "Docker daemon unavailable"
