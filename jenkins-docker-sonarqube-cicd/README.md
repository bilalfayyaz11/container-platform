# Jenkins Docker SonarQube CI/CD Automation

## What This Does

This implementation builds a containerized CI/CD automation platform using Jenkins, Docker, SonarQube, and a Node.js service.

The system runs Jenkins and SonarQube as containers, builds a Docker image for a Node.js application, runs automated tests, validates service health endpoints, prepares SonarQube static analysis configuration, and captures runtime evidence for containers, images, networks, volumes, and pipeline files.

This demonstrates a practical CI/CD workflow where application code, pipeline logic, Docker packaging, quality scanning, and deployment validation are managed through repeatable automation.

## Architecture

    +-----------------------------+
    | Node.js Application Source  |
    | app.js / package.json       |
    | test.js / Dockerfile        |
    +-------------+---------------+
                  |
                  v
    +-----------------------------+
    | Jenkins Pipeline            |
    | Jenkinsfile                 |
    | Build / Test / Deploy       |
    +-------------+---------------+
                  |
                  v
    +-----------------------------+
    | Docker Build Layer          |
    | container-cicd-node-service |
    | Versioned Image Tags        |
    +-------------+---------------+
                  |
                  v
    +-----------------------------+
    | Automated Container Tests   |
    | Health Endpoint             |
    | Root Endpoint               |
    +-------------+---------------+
                  |
                  v
    +-----------------------------+
    | Deployment Container        |
    | container-cicd-prod         |
    | Port 3000                   |
    +-----------------------------+

    +-----------------------------+
    | SonarQube Quality Platform  |
    | Static Analysis Config      |
    | sonar-project.properties    |
    +-----------------------------+

    +-----------------------------+
    | Runtime Evidence            |
    | evidence/*.txt              |
    | pipeline-verification.sh    |
    +-----------------------------+

## Prerequisites

- Ubuntu 24.04
- Docker Engine
- Docker Compose V2
- Java 17
- Node.js
- npm
- Git
- curl
- jq
- tree
- lsof

## Setup & Installation

sudo apt update

sudo apt install -y docker.io docker-compose-v2 openjdk-17-jdk nodejs npm curl jq tree lsof unzip git

sudo systemctl enable docker

sudo systemctl start docker

sudo usermod -aG docker $USER

newgrp docker

## How to Reproduce

Enter the implementation directory:

cd ~/docker-cicd-automation

Start Jenkins and SonarQube:

docker compose up -d --build

Verify services:

docker compose ps

Access Jenkins:

http://localhost:8080

Get the Jenkins initial password:

docker exec container-cicd-jenkins cat /var/jenkins_home/secrets/initialAdminPassword

Access SonarQube:

http://localhost:9000

Build and test the Node.js service locally:

cd sample-app

npm install

npm test

docker build -t container-cicd-node-service:v1.0 .

docker run -d --name container-cicd-node-service-test -p 3001:3000 container-cicd-node-service:v1.0

curl -s http://localhost:3001/health | jq

curl -s http://localhost:3001/ | jq

docker rm -f container-cicd-node-service-test

Create the Jenkins pipeline job:

cd ~/docker-cicd-automation

./create-jenkins-job.sh

Run pipeline verification:

./pipeline-verification.sh

Capture runtime evidence:

mkdir -p evidence

docker compose ps > evidence/compose-services.txt

docker ps > evidence/docker-containers.txt

docker images > evidence/docker-images.txt

docker volume ls > evidence/docker-volumes.txt

docker network ls > evidence/docker-networks.txt

tree . > evidence/file-tree.txt

## Tools Used

- Jenkins
- Docker
- Docker Compose V2
- SonarQube
- SonarQube Scanner configuration
- Node.js
- Express.js
- npm
- Jenkins Pipeline
- Groovy pipeline syntax
- Bash
- Git
- curl
- jq
- tree

## Key Skills Demonstrated

- Docker-based CI/CD automation
- Jenkins container deployment
- Jenkins plugin preloading
- Pipeline-as-code implementation
- Docker image build automation
- Automated container testing
- Health endpoint validation
- Container deployment automation
- SonarQube static analysis preparation
- CI/CD evidence capture
- Runtime debugging and verification
- DevSecOps workflow documentation

## Real-World Use Case

A platform engineering team can use this pattern to create an internal CI/CD foundation for containerized services. Developers commit application code and a Jenkinsfile, Jenkins builds and tests the Docker image, SonarQube prepares quality analysis, and the pipeline deploys a validated container. This reduces manual deployment work, improves reliability, and creates a repeatable path from source code to running service.

## Lessons Learned

- Jenkins and SonarQube are easier to reproduce as containers than as manually installed host services.
- Pipeline logic should be stored as code instead of only configured through a web interface.
- Docker socket access allows Jenkins to build images but must be controlled carefully in real production.
- Old runtime images such as Node 16 should be replaced with supported versions.
- Pipeline stages need cleanup logic to avoid port conflicts and stale containers.

## Troubleshooting Log

Issue:
The original workflow used OpenJDK 11.

Resolution:
Updated the runtime expectation to Java 17 for modern Jenkins compatibility.

Issue:
The original Dockerfile used node:16-alpine.

Resolution:
Updated the application image to node:22-alpine.

Issue:
Manual Jenkins and SonarQube host installation is slow and fragile.

Resolution:
Implemented Jenkins and SonarQube through Docker Compose.

Issue:
The original pipeline used emailext without guaranteeing the Email Extension plugin.

Resolution:
Removed the email notification step to prevent avoidable pipeline failures.

Issue:
Test and deployment containers can fail when old containers already exist.

Resolution:
Added cleanup commands before starting test and deployment containers.

Issue:
SonarQube manual installation required downloading and managing service files.

Resolution:
Used the sonarqube:lts-community container and created sonar-project.properties plus a scanner script.

Issue:
Jenkins UI-only setup slows repeatability.

Resolution:
Created create-jenkins-job.sh to bootstrap the Jenkins pipeline job from config XML.

Issue:
Pipeline evidence can disappear after service restarts.

Resolution:
Generated evidence files for Compose services, containers, images, volumes, networks, and file tree.
