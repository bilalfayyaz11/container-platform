# Containerized Serverless Runtime on AWS

## What This Does

This implementation builds a Python-based serverless runtime packaged as a Docker container for AWS Lambda. It includes local Lambda Runtime API testing, ECR image packaging flow, Lambda deployment automation, API Gateway integration scripts, CloudWatch monitoring commands, traffic generation, cleanup automation, and documented IAM permission boundaries.

The system demonstrates how containerized serverless workloads can be built, tested locally, prepared for cloud deployment, exposed through an HTTP API, and monitored through operational telemetry. This approach gives cloud teams consistent runtime behavior across development and AWS execution environments.

The implementation is designed for production-style infrastructure workflows where deployment steps must be repeatable, auditable, and safe under restricted IAM environments.

## Architecture

    +------------------------------------------------------+
    | Local Engineering Workstation                        |
    | Ubuntu 24.04                                         |
    | Docker Engine                                        |
    | AWS CLI v2                                           |
    +--------------------------+---------------------------+
                               |
                               v
    +------------------------------------------------------+
    | Containerized Lambda Runtime                         |
    | public.ecr.aws/lambda/python:3.12                    |
    | src/lambda_function.py                               |
    | requirements.txt                                     |
    | Dockerfile                                           |
    +--------------------------+---------------------------+
                               |
                 Local Runtime API Test on Port 9000
                               |
                               v
    +------------------------------------------------------+
    | AWS Container Registry Flow                          |
    | ECR Repository: containerized-lambda-runtime          |
    | Image URI: account.dkr.ecr.region.amazonaws.com       |
    | Docker tag and push workflow                          |
    +--------------------------+---------------------------+
                               |
                               v
    +------------------------------------------------------+
    | AWS Serverless Runtime Layer                         |
    | Lambda Container Image Function                      |
    | IAM Execution Role                                   |
    | Basic CloudWatch Logs Policy                         |
    +--------------------------+---------------------------+
                               |
                               v
    +------------------------------------------------------+
    | API Access Layer                                     |
    | API Gateway REST API                                 |
    | GET /hello                                           |
    | Lambda Proxy Integration                             |
    | Least-privilege invoke permission                    |
    +--------------------------+---------------------------+
                               |
                               v
    +------------------------------------------------------+
    | Observability and Operations                         |
    | CloudWatch Logs                                      |
    | CloudWatch Metrics                                   |
    | Logs Insights Query                                  |
    | Traffic Generator                                    |
    | Cleanup Automation                                   |
    +------------------------------------------------------+

## Prerequisites

- Ubuntu 24.04
- Docker Engine
- AWS CLI v2
- Python 3
- curl
- jq
- tree
- AWS identity with permissions for ECR, Lambda, IAM, API Gateway, and CloudWatch
- Network access to public ECR base images
- Git for version control

## Setup & Installation

sudo apt update

sudo apt install -y docker.io python3 python3-pip curl jq tree unzip ca-certificates gnupg lsb-release

if ! command -v aws >/dev/null 2>&1; then
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
  unzip -q /tmp/awscliv2.zip -d /tmp
  sudo /tmp/aws/install --update
fi

sudo systemctl enable --now docker

sudo usermod -aG docker ubuntu

newgrp docker

aws --version

docker --version

aws sts get-caller-identity

## How to Reproduce

Create the runtime directory:

mkdir -p ~/lambda-container-runtime/src ~/lambda-container-runtime/tests

cd ~/lambda-container-runtime

Create the Lambda handler:

cat > src/lambda_function.py << 'PYTHON'
import json
import datetime
import os
import sys


def lambda_handler(event, context):
    """
    Container-based AWS Lambda handler for HTTP-style requests.
    """

    current_time = datetime.datetime.utcnow().replace(microsecond=0).isoformat() + "Z"

    http_method = event.get("httpMethod") or event.get("requestContext", {}).get("http", {}).get("method", "UNKNOWN")
    path = event.get("path") or event.get("rawPath", "/")
    query_params = event.get("queryStringParameters") or {}

    response_data = {
        "message": "Hello from a containerized Lambda runtime",
        "timestamp": current_time,
        "method": http_method,
        "path": path,
        "query_parameters": query_params,
        "container_info": {
            "python_version": sys.version,
            "environment": os.environ.get("AWS_EXECUTION_ENV", "local-container")
        }
    }

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps(response_data, indent=2)
    }
PYTHON

Create the dependency file:

cat > requirements.txt << 'REQ'
# No external dependencies are required.
# The function uses only Python standard library modules.
REQ

Create the container definition:

cat > Dockerfile << 'DOCKER'
FROM public.ecr.aws/lambda/python:3.12

COPY requirements.txt ${LAMBDA_TASK_ROOT}/requirements.txt
RUN python -m pip install --upgrade pip && \
    if [ -s requirements.txt ]; then pip install --no-cache-dir -r requirements.txt; fi

COPY src/lambda_function.py ${LAMBDA_TASK_ROOT}/lambda_function.py

CMD ["lambda_function.lambda_handler"]
DOCKER

Build the image:

docker build -t containerized-lambda-runtime:latest .

Run the local Lambda Runtime API:

docker rm -f containerized-lambda-runtime-test >/dev/null 2>&1 || true

docker run -d \
  --name containerized-lambda-runtime-test \
  -p 9000:8080 \
  containerized-lambda-runtime:latest

Test the runtime locally:

curl -s -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" \
  -d '{
    "httpMethod": "GET",
    "path": "/test",
    "queryStringParameters": {
      "name": "Docker",
      "runtime": "Lambda"
    }
  }' | python3 -m json.tool

Stop the local runtime container:

docker rm -f containerized-lambda-runtime-test

Prepare AWS image variables:

export AWS_REGION=us-east-1

export REPOSITORY_NAME=containerized-lambda-runtime

export ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

export IMAGE_URI="$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPOSITORY_NAME:latest"

Create or reuse the ECR repository:

aws ecr describe-repositories \
  --repository-names "$REPOSITORY_NAME" \
  --region "$AWS_REGION" >/dev/null 2>&1 || \
aws ecr create-repository \
  --repository-name "$REPOSITORY_NAME" \
  --image-scanning-configuration scanOnPush=true \
  --region "$AWS_REGION"

Authenticate Docker to ECR:

aws ecr get-login-password --region "$AWS_REGION" | \
docker login \
  --username AWS \
  --password-stdin "$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

Tag and push the image:

docker tag containerized-lambda-runtime:latest "$IMAGE_URI"

docker push "$IMAGE_URI"

Run permission and deployment readiness checks:

./aws-permission-check.sh

Review deployment automation:

cat deploy-containerized-lambda.sh

cat create-api-gateway-integration.sh

cat view-lambda-cloudwatch-logs.sh

cat view-lambda-cloudwatch-metrics.sh

## Tools Used

- Ubuntu 24.04
- Docker Engine
- AWS CLI v2
- AWS Lambda container runtime image
- Amazon ECR
- AWS Lambda
- AWS IAM
- Amazon API Gateway
- Amazon CloudWatch Logs
- Amazon CloudWatch Metrics
- CloudWatch Logs Insights
- Python 3.12
- Bash
- curl
- jq
- tree
- Git

## Key Skills Demonstrated

- Containerized serverless runtime design
- Docker image creation for AWS Lambda
- Local Lambda Runtime API testing
- AWS ECR repository workflow
- Lambda container image deployment automation
- IAM trust policy creation
- API Gateway proxy integration design
- Least-privilege Lambda invoke permission
- CloudWatch logs and metrics workflow
- AWS permission boundary analysis
- Reproducible infrastructure scripting
- Cloud deployment troubleshooting
- Production cleanup automation
- Platform engineering documentation

## Real-World Use Case

A cloud platform team can use this pattern to ship serverless APIs where the runtime, dependencies, and application code must stay consistent between local development and AWS Lambda. This is useful for internal APIs, event processing services, webhook handlers, automation endpoints, lightweight data processors, and platform control-plane utilities. Containerized Lambda is especially valuable when teams need custom dependencies, larger deployment packages, predictable runtime behavior, and a clean path from local testing to cloud deployment.

## Lessons Learned

- Container-based Lambda functions are easier to test locally than traditional zip-based functions because the runtime environment is packaged with the code.
- Python runtime versions matter for production readiness; using a current Lambda base image improves maintainability.
- Cloud deployment workflows should be converted into scripts so another engineer can reproduce the same result safely.
- AWS IAM restrictions are a normal part of real cloud environments and should be documented rather than hidden.
- API Gateway permissions should be scoped tightly to the required HTTP method and path instead of using broad invoke permissions.

## Troubleshooting Log

Issue:
Docker commands failed with permission denied while connecting to /var/run/docker.sock.

Resolution:
Added the ubuntu user to the docker group and refreshed group membership using newgrp docker.

Issue:
The original runtime image used Python 3.9, which is old for a 2026 cloud-native portfolio implementation.

Resolution:
Updated the base image to public.ecr.aws/lambda/python:3.12.

Issue:
The original function used local timestamps through datetime.now.

Resolution:
Replaced local time with UTC ISO timestamps for cleaner CloudWatch correlation and production log consistency.

Issue:
The original handler only supported REST API Gateway v1 event fields.

Resolution:
Added fallback parsing for newer HTTP API-style request context fields.

Issue:
The original commands expected separate terminals for local container testing.

Resolution:
Used detached Docker execution so the runtime and test request can be handled from the same shell.

Issue:
The AWS role was denied ecr:ListImages on the ECR repository.

Resolution:
Captured the IAM limitation in aws-permission-limitations.txt and continued with local runtime evidence plus deployment automation artifacts.

Issue:
The original deployment steps were only terminal commands and did not leave reusable automation.

Resolution:
Converted Lambda deployment, API Gateway integration, invocation, monitoring, traffic generation, permission checks, and cleanup into executable Bash scripts.

Issue:
The original API Gateway Lambda permission used a broad source ARN.

Resolution:
Scoped API Gateway invoke permission to GET /hello for a tighter production-style security model.

Issue:
The original CloudWatch metric command used comma-separated statistics.

Resolution:
Changed CloudWatch statistics to separate CLI values: Average Maximum.
