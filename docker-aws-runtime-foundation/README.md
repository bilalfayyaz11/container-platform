# Docker AWS Runtime Foundation

## What This Does

This implementation builds and validates a containerized Nginx web application using Docker, then prepares the AWS deployment artifacts required for ECR, ECS, and CloudWatch integration.

The container image is built locally, tagged using the expected Amazon ECR repository format, and validated through a running Docker container on port 8080. The implementation also includes an ECS Fargate task definition, CloudWatch dashboard configuration, image inspection metadata, and IAM limitation evidence from the restricted AWS environment.

This represents a production-style container delivery foundation where the runtime, registry path, orchestration definition, and monitoring configuration are documented and reproducible.

## Architecture

    +-----------------------------+
    | Local Source Files          |
    | web-app/index.html          |
    | web-app/Dockerfile          |
    +-------------+---------------+
                  |
                  v
    +-----------------------------+
    | Docker Build Layer          |
    | aws-container-runtime       |
    +-------------+---------------+
                  |
                  v
    +-----------------------------+
    | Local Runtime Validation    |
    | Docker Container            |
    | localhost:8080 -> 80        |
    +-------------+---------------+
                  |
                  v
    +-----------------------------+
    | AWS Registry Preparation    |
    | ECR URI + Image Tags        |
    | latest / v1.0               |
    +-------------+---------------+
                  |
                  v
    +-----------------------------+
    | AWS Orchestration Artifacts |
    | ECS Fargate Task Definition |
    +-------------+---------------+
                  |
                  v
    +-----------------------------+
    | Observability Artifacts     |
    | CloudWatch Dashboard Config |
    | IAM Limitation Evidence     |
    +-----------------------------+

## Prerequisites

- Ubuntu 24.04
- Docker
- Docker Compose plugin
- AWS CLI
- Git
- tree
- jq
- curl
- AWS account access
- IAM permissions for ECR, ECS, EC2, CloudWatch, and CloudWatch Logs for full cloud deployment

## Setup & Installation

sudo apt update

sudo apt install -y docker.io docker-compose-v2 tree jq curl git

sudo systemctl enable docker

sudo systemctl start docker

sudo usermod -aG docker $USER

aws configure set region us-east-1

## How to Reproduce

Create the working directory:

mkdir -p ~/container-ec2-runtime

cd ~/container-ec2-runtime

Create the container application:

mkdir -p web-app

cat > web-app/index.html << 'APP'
<!DOCTYPE html>
<html>
<head>
    <title>AWS Container Runtime</title>
</head>
<body>
    <h1>AWS Container Runtime</h1>
    <p>This container image is built locally and prepared for AWS registry and orchestration deployment.</p>
    <p>Runtime path: Docker to ECR to ECS to CloudWatch.</p>
</body>
</html>
APP

cat > web-app/Dockerfile << 'DOCKERFILE'
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
DOCKERFILE

Build the Docker image:

docker build -t aws-container-runtime:latest web-app

Run the container locally:

docker rm -f aws-container-runtime 2>/dev/null || true

docker run -d --name aws-container-runtime -p 8080:80 aws-container-runtime:latest

Validate the container:

curl -I http://localhost:8080

docker ps --filter "name=aws-container-runtime"

Prepare the expected ECR image URI:

export AWS_REGION=us-east-1

export AWS_ACCOUNT_ID=698355729228

export ECR_REPOSITORY_NAME=aws-container-runtime

export REPO_URI="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY_NAME"

docker tag aws-container-runtime:latest "$REPO_URI:latest"

docker tag aws-container-runtime:latest "$REPO_URI:v1.0"

Generate ECS and CloudWatch artifacts:

cat ecs-task-definition.json

cat cloudwatch-dashboard.json

Review IAM limitation evidence:

cat permission-limitations.json

Inspect final files:

tree .

## Tools Used

- Docker
- Docker Compose plugin
- AWS CLI
- Amazon ECR image URI format
- Amazon ECS task definition format
- AWS Fargate configuration model
- Amazon CloudWatch dashboard JSON
- Nginx
- Linux
- Bash
- JSON
- Git
- tree

## Key Skills Demonstrated

- Docker image creation and runtime validation
- Containerized web application packaging
- AWS container registry URI construction
- ECR tagging strategy
- ECS Fargate task definition authoring
- CloudWatch dashboard configuration
- IAM permission troubleshooting
- Cloud deployment artifact preparation
- Production-style infrastructure documentation
- Cloud platform debugging under restricted access

## Real-World Use Case

A platform engineering or DevOps team can use this pattern as the foundation for container delivery into AWS. Developers build and test the container locally, tag it for ECR, define how ECS should run it, and prepare CloudWatch observability configuration before deployment. In a real organization, the same workflow would be integrated into CI/CD pipelines where IAM permissions allow pushing to ECR, registering ECS task definitions, creating services, and publishing dashboards.

## Lessons Learned

- Restricted IAM roles can block cloud deployment even when AWS CLI authentication works.
- Docker runtime validation should be completed locally before attempting cloud deployment.
- ECR image tagging can be prepared even when registry authentication is blocked.
- ECS and CloudWatch JSON artifacts are useful deployment evidence even when API execution is restricted.
- Private key material must never be committed to a GitHub repository.

## Troubleshooting Log

Issue:
The AWS role blocked ec2:CreateKeyPair.

Resolution:
The EC2 SSH key creation step was skipped, and deployment validation was adjusted toward local Docker runtime evidence.

Issue:
The AWS role blocked ssm:GetParameters, preventing dynamic Amazon Linux AMI lookup.

Resolution:
The lab-provided AMI value was tested as a fallback, but EC2 provisioning remained blocked by additional IAM restrictions.

Issue:
The AWS role blocked ec2:DescribeImages, ec2:DescribeVpcs, and ec2:DescribeSecurityGroups.

Resolution:
The EC2 launch workflow was documented as unavailable in the restricted environment, and the implementation pivoted to local Docker validation plus AWS deployment-ready artifacts.

Issue:
The ECR repository lookup failed because ecr:DescribeRepositories was denied.

Resolution:
The expected ECR URI was constructed manually using the AWS account ID, region, and repository name.

Issue:
Docker tagging failed when REPO_URI was empty.

Resolution:
REPO_URI was explicitly defined before tagging the image.

Issue:
The AWS role blocked ecr:GetAuthorizationToken.

Resolution:
ECR push was documented as blocked, while local image tagging and image inspection evidence were retained.

Issue:
The AWS role blocked ecs:ListClusters, cloudwatch:ListDashboards, and logs:DescribeLogGroups.

Resolution:
ECS and CloudWatch deployment configuration files were generated locally and included as reproducible infrastructure artifacts.

Issue:
A temporary PEM key file existed in the workspace.

Resolution:
The key file was removed before GitHub packaging to prevent accidental secret exposure.
