# AWS ECS Container Orchestration Readiness

## What This Does

This implementation validates whether an AWS lab environment is ready to deploy containerized workloads on Amazon ECS using EC2 launch type, task definitions, services, load balancing, scaling, and CloudWatch monitoring.

The environment was tested for AWS identity, ECS access, EC2 networking permissions, task execution role availability, Docker readiness, and local container runtime status. The validation found that the active AWS role did not include the required ECS and EC2 permissions to create or inspect ECS infrastructure.

Because the cloud role blocked live ECS provisioning, this package preserves the operational evidence and includes production-style ECS artifacts: a task definition blueprint, ECS service blueprint, CloudWatch monitoring plan, and a reusable permission validation script.

## Architecture

    +--------------------------------+
    | AWS Lab Instance               |
    | Ubuntu 24.04                   |
    | AWS CLI                        |
    | Docker Engine                  |
    +---------------+----------------+
                    |
                    v
    +--------------------------------+
    | ECS Readiness Validation       |
    | Identity Check                 |
    | EC2 Permission Check           |
    | ECS Permission Check           |
    | IAM Role Check                 |
    +---------------+----------------+
                    |
                    v
    +--------------------------------+
    | Blocker Detected               |
    | ec2:DescribeVpcs denied        |
    | ec2:DescribeSubnets denied     |
    | ecs:ListClusters denied        |
    | ecsTaskExecutionRole missing   |
    +---------------+----------------+
                    |
                    v
    +--------------------------------+
    | Preserved Deployment Artifacts |
    | ECS Task Definition JSON       |
    | ECS Service Blueprint JSON     |
    | CloudWatch Monitoring Plan     |
    | Readiness Report               |
    +--------------------------------+

## Prerequisites

- Ubuntu 24.04
- AWS CLI v2
- Valid AWS credentials
- Docker Engine
- jq
- tree
- IAM permissions for ECS, EC2, IAM role lookup, Elastic Load Balancing, Auto Scaling, and CloudWatch
- Existing VPC and public subnets
- ecsTaskExecutionRole or permission to create it

## Setup & Installation

sudo apt update

sudo apt install -y docker.io jq tree

sudo systemctl enable --now docker

sudo usermod -aG docker ubuntu

newgrp docker

aws --version

aws sts get-caller-identity

docker --version

docker ps

## How to Reproduce

Create the working directory:

mkdir -p ~/aws-ecs-container-orchestration

cd ~/aws-ecs-container-orchestration

Run the ECS readiness validation:

./ecs-permission-validation.sh

Review the generated report:

cat ecs-readiness-report.txt

Review the ECS task definition blueprint:

cat ecs-task-definition-nginx.json

Review the ECS service blueprint:

cat ecs-service-blueprint.json

Review the CloudWatch monitoring plan:

cat cloudwatch-monitoring-plan.md

If the required AWS permissions are later granted, register the task definition:

aws ecs register-task-definition \
  --cli-input-json file://ecs-task-definition-nginx.json

Create or use an ECS cluster:

aws ecs create-cluster \
  --cluster-name container-orchestration-cluster

Deploy the service after replacing the target group ARN:

aws ecs create-service \
  --cli-input-json file://ecs-service-blueprint.json

## Tools Used

- AWS CLI v2
- Amazon ECS
- Amazon EC2
- Elastic Load Balancing
- AWS IAM
- Amazon CloudWatch
- Docker Engine
- Bash
- JSON
- jq
- tree

## Key Skills Demonstrated

- AWS ECS readiness validation
- Cloud permission troubleshooting
- IAM blocker identification
- ECS task definition design
- ECS service blueprinting
- Application Load Balancer planning
- CloudWatch monitoring design
- Production deployment planning
- Infrastructure dependency validation
- Container orchestration troubleshooting
- Evidence-based operational reporting

## Real-World Use Case

In real cloud engineering work, not every deployment failure is caused by bad application code or incorrect commands. Many failures happen because IAM permissions, networking resources, execution roles, or account-level prerequisites are missing. This implementation demonstrates how a platform engineer validates the AWS environment before attempting an ECS rollout, captures the blocker clearly, and preserves reusable deployment artifacts so provisioning can continue immediately when the required access is granted.

## Lessons Learned

- ECS deployments depend on EC2 networking, IAM roles, load balancers, CloudWatch, and service permissions.
- AWS lab environments may expose AWS CLI credentials but still restrict ECS and EC2 actions.
- A valid AWS identity does not guarantee permission to create or inspect infrastructure.
- Permission validation should happen before attempting cluster creation.
- Deployment artifacts can still be prepared even when provisioning is blocked by IAM.
- Clear blocker reports are valuable portfolio evidence because they show real troubleshooting maturity.

## Troubleshooting Log

Issue:
Docker was missing from the fresh Ubuntu 24.04 environment.

Resolution:
Installed docker.io, jq, and tree through apt, enabled Docker, and verified the daemon with docker ps.

Issue:
AWS CLI was installed and credentials were active, but no default region was configured.

Resolution:
Captured the missing region state as part of the readiness report and avoided region-dependent resource creation until permissions were verified.

Issue:
The active AWS role could call sts:GetCallerIdentity but could not inspect VPCs.

Resolution:
Validated that ec2:DescribeVpcs was denied, proving the environment lacked the networking read permissions required for ECS cluster and load balancer setup.

Issue:
The active AWS role could not inspect subnets.

Resolution:
Validated that ec2:DescribeSubnets was denied, confirming subnet discovery for ECS and ALB placement was blocked.

Issue:
The active AWS role could not list ECS clusters.

Resolution:
Validated that ecs:ListClusters was denied, confirming ECS access was not granted in the lab role.

Issue:
ecsTaskExecutionRole was missing or inaccessible.

Resolution:
Captured the missing execution role condition and prepared a task definition blueprint that can be used once the role exists.

Issue:
The original workflow assumes console-driven ECS creation with older EC2 launch type screens.

Resolution:
Prepared CLI-compatible ECS JSON blueprints that document the same architecture in a reproducible, version-controlled format.
