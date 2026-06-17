# Jenkins Container Delivery Platform

## What This Does

This implementation builds a complete Jenkins-driven container delivery platform using Docker, Jenkins, Node.js, automated testing, security scanning, webhook integration, deployment automation, and operational monitoring.

The platform automatically validates application code, executes automated tests, builds container images, performs vulnerability scanning, deploys application containers, exposes monitoring artifacts, and supports webhook-triggered build workflows.

The solution demonstrates how modern DevOps and Platform Engineering teams automate software delivery using container-native CI/CD pipelines while maintaining reproducibility, observability, and deployment consistency.

## Architecture

    +------------------------------------------------------+
    | Developer Workflow                                   |
    | Source Code Changes                                  |
    | Git Commits                                          |
    +-------------------------+----------------------------+
                              |
                              v
    +------------------------------------------------------+
    | Jenkins Controller                                   |
    | jenkins/jenkins:lts-jdk21                            |
    | Port 8080                                            |
    +-------------------------+----------------------------+
                              |
                              v
    +------------------------------------------------------+
    | Build Pipeline                                       |
    | npm ci                                               |
    | npm test                                             |
    | Jest                                                 |
    | Supertest                                            |
    +-------------------------+----------------------------+
                              |
                              v
    +------------------------------------------------------+
    | Container Build Layer                                |
    | Docker                                               |
    | Node 20 Alpine                                       |
    | Jenkinsfile                                          |
    +-------------------------+----------------------------+
                              |
                              v
    +------------------------------------------------------+
    | Security Validation                                  |
    | Trivy Container Scan                                 |
    | High/Critical Vulnerability Review                   |
    +-------------------------+----------------------------+
                              |
                              v
    +------------------------------------------------------+
    | Integration Testing                                  |
    | Runtime Health Checks                                |
    | Container Verification                               |
    +-------------------------+----------------------------+
                              |
                              v
    +------------------------------------------------------+
    | Deployment Layer                                     |
    | Staging Container                                    |
    | Port 3002                                            |
    +-------------------------+----------------------------+
                              |
                              v
    +------------------------------------------------------+
    | Operations Layer                                     |
    | Webhook Listener                                     |
    | Metrics Collection                                   |
    | Build Monitoring                                     |
    | Jenkins Audit Evidence                               |
    +------------------------------------------------------+

## Prerequisites

- Ubuntu 24.04
- Docker Engine
- Docker Compose v2
- Git
- Node.js
- npm
- Java 21
- Jenkins LTS
- curl
- tree
- Internet access
- Docker Hub account (optional for publishing)

## Setup & Installation

sudo apt update

sudo apt install -y \
  docker.io \
  docker-compose-v2 \
  git \
  curl \
  tree \
  nodejs \
  npm \
  openjdk-21-jre-headless

sudo systemctl enable --now docker

sudo usermod -aG docker ubuntu

newgrp docker

docker volume create jenkins_home

docker run -d \
  --name jenkins-controller \
  --restart unless-stopped \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /usr/bin/docker:/usr/bin/docker:ro \
  jenkins/jenkins:lts-jdk21

## How to Reproduce

Create the working directory:

mkdir -p ~/jenkins-container-pipeline

cd ~/jenkins-container-pipeline

Install dependencies:

npm install

Run tests:

npm test

Build application image:

docker build -t jenkins-container-pipeline:local .

Run application container:

docker run -d \
  --name jenkins-container-pipeline-test \
  -p 3001:3000 \
  jenkins-container-pipeline:local

Verify endpoints:

curl http://localhost:3001/

curl http://localhost:3001/health

Create local Git repository:

git init

git branch -M main

git add .

git commit -m "Create Jenkins container pipeline service"

Create Jenkins Pipeline:

Use Jenkinsfile

Create Docker Hub pipeline:

Use Jenkinsfile.dockerhub

Run validation:

./validate-jenkins-platform.sh

Collect metrics:

./collect-metrics.sh

Monitor builds:

./monitor-builds.sh

## Tools Used

- Jenkins LTS
- Docker
- Docker Compose
- Node.js
- npm
- Express
- Jest
- Supertest
- Trivy
- Bash
- Git
- Java 21
- Python 3
- curl
- Ubuntu 24.04

## Key Skills Demonstrated

- Jenkins pipeline engineering
- CI/CD automation
- Docker image build automation
- Container deployment workflows
- Automated testing pipelines
- Security scanning integration
- Trivy vulnerability assessment
- Webhook-driven automation
- Build monitoring and metrics collection
- Infrastructure troubleshooting
- Jenkins container administration
- Docker-in-Docker style pipeline execution
- Platform engineering workflow design

## Real-World Use Case

This platform mirrors how software engineering organizations automate application delivery. Developers commit code, Jenkins validates quality, builds containers, performs security analysis, runs integration tests, and deploys tested images into controlled environments. Similar workflows are used by Platform Engineering, DevOps, SRE, and Cloud Infrastructure teams to reduce deployment risk and improve delivery velocity.

## Lessons Learned

- Running Jenkins in Docker simplifies infrastructure portability.
- Docker socket permissions are one of the most common Jenkins deployment issues.
- Security scanning should be integrated directly into the delivery pipeline.
- Jenkins credentials should be used instead of hardcoded registry secrets.
- Automated validation scripts reduce troubleshooting effort during deployments.

## Troubleshooting Log

Issue:
The Jenkins apt repository failed with GPG signature verification errors.

Resolution:
Switched to the official Jenkins LTS Docker image instead of relying on the broken repository path.

Issue:
The Jenkins service was unavailable after package installation attempts.

Resolution:
Deployed Jenkins as a containerized service using jenkins/jenkins:lts-jdk21.

Issue:
Jenkins could not access Docker.

Resolution:
Mapped the Docker socket into the Jenkins container and aligned Docker socket group permissions.

Issue:
The original lab assumed Docker and Jenkins were pre-installed.

Resolution:
Verified all dependencies and installed only missing components.

Issue:
The original pipeline used older Node runtimes.

Resolution:
Updated container builds and test execution to Node 20.

Issue:
The original implementation stored Docker Hub identity information directly.

Resolution:
Moved Docker Hub integration to Jenkins credential-based authentication.

Issue:
Docker Compose version fields were outdated.

Resolution:
Removed deprecated Compose version declarations for Compose v2 compatibility.

Issue:
Webhook examples relied on hardcoded credentials.

Resolution:
Created a credential-independent webhook listener implementation.
