# Secure Container Delivery Pipeline

## What This Does

This implementation builds a secure CI/CD delivery system for a containerized Python web service. It automates Docker image builds, semantic version tagging, container registry publishing, multi-service testing, vulnerability scanning, and manual deployment approval.

The system uses Docker, Docker Compose, GitLab CI/CD, Redis, Nginx, and Trivy to model a production-grade DevSecOps workflow. Secrets are injected through CI/CD variables instead of being stored in source control.

This helps platform and DevSecOps teams deliver containerized applications faster while enforcing security, testing, and auditability at every stage.

## Architecture

    +-----------------------------+
    | Git Push to Main Branch     |
    +-------------+---------------+
                  |
                  v
    +-----------------------------+
    | GitLab CI/CD Pipeline       |
    | build -> test -> scan       |
    | deploy manual approval      |
    +-------------+---------------+
                  |
                  v
    +-----------------------------+
    | Docker Image Build          |
    | SHA Tag + VERSION Tag       |
    | GitLab Container Registry   |
    +-------------+---------------+
                  |
                  v
    +-----------------------------+
    | Compose Test Stack          |
    | Nginx -> Flask App -> Redis |
    +-------------+---------------+
                  |
                  v
    +-----------------------------+
    | Security Scan               |
    | Trivy JSON Artifact         |
    +-------------+---------------+
                  |
                  v
    +-----------------------------+
    | Manual Deployment Gate      |
    | Production Variables        |
    +-----------------------------+

## Prerequisites

- Ubuntu 24.04
- Docker Engine
- Docker Compose standalone binary
- Git
- Trivy
- GitLab account
- GitLab project with Container Registry enabled
- GitLab personal access token
- GitLab CI/CD masked variable named REDIS_PASSWORD

## Setup & Installation

sudo apt-get update

sudo apt-get install -y ca-certificates curl gnupg git tree jq

docker --version

docker-compose --version

git --version

trivy --version

docker run --rm hello-world

## How to Reproduce

Clone the repository:

git clone https://gitlab.com/YOUR_GITLAB_USERNAME/container-cicd-delivery.git

cd container-cicd-delivery

Set local runtime variables:

export APP_NAME="container-cicd-service"

export APP_VERSION="$(cat VERSION)"

export APP_ENV="local"

export REDIS_PASSWORD="local-dev-redis-password"

export REDIS_URL="redis://:${REDIS_PASSWORD}@redis:6379/0"

export APP_IMAGE="container-cicd-service:local"

Build the application image:

docker build -t "$APP_IMAGE" .

Run a single-container validation:

docker run -d --name local-app-test -p 8080:8080 \
  -e APP_NAME="$APP_NAME" \
  -e APP_VERSION="$APP_VERSION" \
  -e APP_ENV="$APP_ENV" \
  "$APP_IMAGE"

curl http://localhost:8080/

curl http://localhost:8080/health

docker stop local-app-test

docker rm local-app-test

Run the full Compose stack:

docker-compose up -d

curl http://localhost/

curl http://localhost/health

docker-compose down -v

Run a local vulnerability scan:

trivy image --format json --output trivy-report.json "$APP_IMAGE"

Verify the report:

grep -q '"Results"' trivy-report.json

## Tools Used

- Docker Engine
- Docker Compose
- GitLab CI/CD
- GitLab Container Registry
- Trivy
- Python Flask
- Gunicorn
- Redis
- Nginx
- Alpine Linux
- Git
- Bash
- jq

## Key Skills Demonstrated

- CI/CD pipeline design
- Docker image build automation
- Semantic container image tagging
- GitLab Container Registry integration
- Multi-service orchestration with Docker Compose
- Runtime secret injection
- Vulnerability scanning with Trivy
- Pipeline artifact generation
- Manual deployment gates
- Non-root container hardening
- Reverse proxy validation through Nginx
- Redis-backed service integration
- DevSecOps workflow implementation

## Real-World Use Case

A platform engineering team could use this pattern to standardize how application teams build, test, scan, and deploy containerized services. Every commit to the main branch produces traceable image tags, validates the service through its real runtime stack, scans the image for known vulnerabilities, and keeps production deployment behind a manual approval gate.

## Lessons Learned

- CI/CD pipelines should validate the same multi-service behavior expected in production.
- Secrets must be injected at runtime through CI/CD variables instead of committed into repository files.
- Image tags should include both immutable commit references and readable semantic versions.
- Trivy artifacts provide an auditable vulnerability report for security review.
- Manual deployment gates protect production while keeping build, test, and scan automation fast.

## Troubleshooting Log

Issue:
The original Docker installation instructions used a hardcoded Ubuntu Jammy repository.

Resolution:
Used the already available Docker installation on Ubuntu 24.04 Noble and verified Docker before proceeding.

Issue:
Using newgrp docker inside a heredoc closed the SSH session after execution.

Resolution:
Removed newgrp from the final execution flow and used the fresh environment where Docker permissions were already working.

Issue:
The lab required standalone docker-compose rather than only the modern Docker Compose plugin.

Resolution:
Used the available standalone Docker Compose binary and validated it with docker-compose --version.

Issue:
Secrets could not be written into committed files.

Resolution:
Used environment variable substitution in docker-compose.yml and GitLab masked variables for REDIS_PASSWORD.

Issue:
The application needed to prove Redis connectivity through Nginx rather than direct app access.

Resolution:
Added a Redis-backed request counter and tested the root endpoint through Nginx on port 80.

Issue:
The pipeline needed a downloadable vulnerability artifact.

Resolution:
Configured Trivy to export trivy-report.json and saved it as a GitLab pipeline artifact.
