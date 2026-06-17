# Automated Container Delivery Pipeline

## What This Does

This implementation builds a complete automated container delivery pipeline using GitHub Actions, Docker, Docker Compose, Node.js, and Docker Hub publishing controls.

The pipeline validates application code, runs local service tests, builds a Docker image, verifies the image through container execution, tests a multi-service Compose stack with Nginx, and prepares image publishing to Docker Hub through secure GitHub repository secrets.

This workflow models how production engineering teams move application changes from source code to tested container images without relying on manual build and release steps.

## Architecture

    +--------------------------------------------------+
    | Developer Workflow                               |
    | Git Commit                                       |
    | Git Push                                         |
    +-----------------------+--------------------------+
                            |
                            v
    +--------------------------------------------------+
    | GitHub Actions                                  |
    | .github/workflows/container-pipeline.yml        |
    +-----------------------+--------------------------+
                            |
                            v
    +--------------------------------------------------+
    | Build and Test Stage                            |
    | Node.js 20                                      |
    | npm ci                                          |
    | npm test                                        |
    +-----------------------+--------------------------+
                            |
                            v
    +--------------------------------------------------+
    | Container Build Stage                           |
    | Docker Buildx                                   |
    | Dockerfile                                      |
    | github-actions-container-pipeline:test          |
    +-----------------------+--------------------------+
                            |
                            v
    +--------------------------------------------------+
    | Container Runtime Validation                    |
    | docker run                                      |
    | /health endpoint                                |
    | Root API response                               |
    +-----------------------+--------------------------+
                            |
                            v
    +--------------------------------------------------+
    | Docker Compose Integration Layer                |
    | Node.js App Container                           |
    | Nginx Reverse Proxy                             |
    | scripts/integration-test.sh                     |
    +-----------------------+--------------------------+
                            |
                            v
    +--------------------------------------------------+
    | Image Publishing Layer                          |
    | Docker Hub                                      |
    | GitHub Secrets                                  |
    | DOCKER_USERNAME                                 |
    | DOCKER_PASSWORD                                 |
    | latest, main, and commit-based tags             |
    +--------------------------------------------------+

## Prerequisites

- Ubuntu 24.04
- Git
- Docker Engine
- Docker Compose v2
- Node.js
- npm
- curl
- tree
- GitHub account
- Docker Hub account
- GitHub repository secrets named DOCKER_USERNAME and DOCKER_PASSWORD
- Docker Hub access token recommended instead of account password

## Setup & Installation

sudo apt update

sudo apt install -y docker.io docker-compose-v2 nodejs npm curl tree git ca-certificates

sudo systemctl enable --now docker

sudo usermod -aG docker ubuntu

newgrp docker

docker --version

docker compose version

node --version

npm --version

git --version

## How to Reproduce

Create the working directory:

mkdir -p ~/github-actions-container-pipeline

cd ~/github-actions-container-pipeline

Create the Node.js service:

cat > package.json << 'PACKAGE'
{
  "name": "github-actions-container-pipeline",
  "version": "1.0.1",
  "description": "Node.js service with Docker build automation and GitHub Actions CI/CD",
  "main": "app.js",
  "scripts": {
    "start": "node app.js",
    "test": "node test.js"
  },
  "dependencies": {
    "express": "^4.18.3"
  },
  "devDependencies": {},
  "author": "Bilal Fayyaz",
  "license": "MIT"
}
PACKAGE

Create the application:

cat > app.js << 'APP'
const express = require("express");

const app = express();
const port = process.env.PORT || 3000;

app.get("/", (req, res) => {
  res.json({
    message: "Hello from an automated container delivery pipeline",
    timestamp: new Date().toISOString(),
    version: "1.0.1"
  });
});

app.get("/health", (req, res) => {
  res.status(200).json({
    status: "healthy",
    uptime: process.uptime()
  });
});

if (require.main === module) {
  app.listen(port, () => {
    console.log(`Server running on port ${port}`);
  });
}

module.exports = app;
APP

Create the service test:

cat > test.js << 'TEST'
const http = require("http");
const { spawn } = require("child_process");

const appProcess = spawn("node", ["app.js"], {
  env: { ...process.env, PORT: "3000" },
  stdio: "inherit"
});

function wait(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function requestHealth() {
  return new Promise((resolve, reject) => {
    const req = http.request(
      {
        hostname: "localhost",
        port: 3000,
        path: "/health",
        method: "GET",
        timeout: 5000
      },
      (res) => {
        let data = "";

        res.on("data", (chunk) => {
          data += chunk;
        });

        res.on("end", () => {
          try {
            const response = JSON.parse(data);
            if (res.statusCode === 200 && response.status === "healthy") {
              resolve();
            } else {
              reject(new Error(`Unexpected response: ${data}`));
            }
          } catch (error) {
            reject(new Error(`Invalid JSON response: ${data}`));
          }
        });
      }
    );

    req.on("error", reject);
    req.on("timeout", () => {
      req.destroy(new Error("Request timed out"));
    });

    req.end();
  });
}

(async () => {
  try {
    console.log("Starting health check test...");
    await wait(3000);
    await requestHealth();
    console.log("Health check passed.");
    appProcess.kill();
    process.exit(0);
  } catch (error) {
    console.error("Health check failed:", error.message);
    appProcess.kill();
    process.exit(1);
  }
})();
TEST

Install dependencies and create the lock file:

npm install

Create the Dockerfile:

cat > Dockerfile << 'DOCKER'
FROM node:20-alpine

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm ci --omit=dev

COPY app.js test.js ./

EXPOSE 3000

RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup

USER appuser

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) }).on('error', () => process.exit(1))"

CMD ["npm", "start"]
DOCKER

Create the Nginx reverse proxy configuration:

cat > nginx.conf << 'NGINX'
events {
    worker_connections 1024;
}

http {
    upstream app_backend {
        server app:3000;
    }

    server {
        listen 80;

        location / {
            proxy_pass http://app_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        location /health {
            proxy_pass http://app_backend/health;
        }
    }
}
NGINX

Create the Compose stack:

cat > docker-compose.yml << 'COMPOSE'
services:
  app:
    build: .
    image: github-actions-container-pipeline:local
    ports:
      - "3000:3000"
    environment:
      NODE_ENV: production
    healthcheck:
      test: ["CMD-SHELL", "node -e \"require('http').get('http://localhost:3000/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) }).on('error', () => process.exit(1))\""]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 20s
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      app:
        condition: service_healthy
    healthcheck:
      test: ["CMD-SHELL", "wget -q --spider http://localhost/health || exit 1"]
      interval: 10s
      timeout: 5s
      retries: 3
    restart: unless-stopped
COMPOSE

Create the integration test script:

mkdir -p scripts

cat > scripts/integration-test.sh << 'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail

echo "Starting integration tests..."

wait_for_service() {
  local url="$1"
  local service_name="$2"
  local max_attempts=30
  local attempt=1

  echo "Waiting for $service_name..."

  while [ "$attempt" -le "$max_attempts" ]; do
    if curl -fsS "$url" >/dev/null 2>&1; then
      echo "$service_name is ready."
      return 0
    fi

    echo "Attempt $attempt/$max_attempts: $service_name not ready yet."
    sleep 2
    attempt=$((attempt + 1))
  done

  echo "$service_name failed readiness check."
  return 1
}

echo "Test 1: App health endpoint"
wait_for_service "http://localhost:3000/health" "App"

echo "Test 2: App root endpoint"
response="$(curl -fsS http://localhost:3000/)"

if echo "$response" | grep -q "automated container delivery pipeline"; then
  echo "App root endpoint passed."
else
  echo "App root endpoint failed."
  echo "Response: $response"
  exit 1
fi

echo "Test 3: Nginx proxy health endpoint"
wait_for_service "http://localhost:8080/health" "Nginx proxy"

echo "Test 4: Simple load check"
for i in {1..10}; do
  curl -fsS http://localhost:3000/ >/dev/null
done

echo "All integration tests passed."
SCRIPT

chmod +x scripts/integration-test.sh

Create the GitHub Actions workflow:

mkdir -p .github/workflows

cat > .github/workflows/container-pipeline.yml << 'WORKFLOW'
name: Container Delivery Pipeline

on:
  push:
    branches:
      - main
      - master
  pull_request:
    branches:
      - main
      - master

env:
  IMAGE_NAME: github-actions-container-pipeline

jobs:
  build-test-and-package:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up Node.js
        uses: actions/setup-node@v4
        with:
          node-version: "20"
          cache: npm

      - name: Install dependencies
        run: npm ci

      - name: Run application tests
        run: npm test

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Build container image
        uses: docker/build-push-action@v6
        with:
          context: .
          push: false
          load: true
          tags: ${{ env.IMAGE_NAME }}:test
          cache-from: type=gha
          cache-to: type=gha,mode=max

      - name: Test container image
        run: |
          docker run -d -p 3000:3000 --name app-container ${{ env.IMAGE_NAME }}:test
          sleep 10
          curl -fsS http://localhost:3000/health
          curl -fsS http://localhost:3000/
          docker rm -f app-container

      - name: Run Docker Compose integration tests
        run: |
          docker compose up -d
          ./scripts/integration-test.sh

      - name: Collect Docker Compose logs
        if: always()
        run: |
          docker compose logs app || true
          docker compose logs nginx || true

      - name: Cleanup Docker Compose
        if: always()
        run: |
          docker compose down -v || true
          docker system prune -f || true

  publish-image:
    needs: build-test-and-package
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main' || github.ref == 'refs/heads/master'

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Generate Docker image metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ secrets.DOCKER_USERNAME }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=sha,prefix={{branch}}-
            type=raw,value=latest,enable={{is_default_branch}}

      - name: Build and publish image
        uses: docker/build-push-action@v6
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

      - name: Verify published image
        run: |
          docker pull ${{ secrets.DOCKER_USERNAME }}/${{ env.IMAGE_NAME }}:latest
          docker run -d -p 3001:3000 --name published-image-check ${{ secrets.DOCKER_USERNAME }}/${{ env.IMAGE_NAME }}:latest
          sleep 10
          curl -fsS http://localhost:3001/health
          docker rm -f published-image-check
WORKFLOW

Run local validation:

npm test

docker build -t github-actions-container-pipeline:local .

docker compose up -d

./scripts/integration-test.sh

docker compose down -v

## Tools Used

- GitHub Actions
- Docker
- Docker Buildx
- Docker Compose v2
- Docker Hub
- GitHub repository secrets
- Node.js 20
- npm
- Express
- Nginx
- Bash
- curl
- Git
- Ubuntu 24.04

## Key Skills Demonstrated

- CI/CD pipeline design
- Automated container image builds
- Docker image runtime validation
- Docker Compose integration testing
- GitHub Actions workflow engineering
- Secure registry publishing with repository secrets
- Docker Hub image tagging strategy
- Healthcheck-driven service validation
- Nginx reverse proxy testing
- Build cache optimization
- Reproducible container delivery automation
- Local and pipeline-based test parity
- Production-style troubleshooting documentation

## Real-World Use Case

This workflow can be used by a platform engineering team to automate container delivery for backend services before deployment to Kubernetes, ECS, Docker Swarm, or any container runtime platform. Each code push triggers validation, application tests, image builds, runtime checks, Compose-based integration tests, and optional publishing to Docker Hub. This prevents broken images from reaching downstream environments and gives teams a repeatable delivery path from source code to deployable container artifact.

## Lessons Learned

- CI/CD workflows must test both the application code and the container image because a passing app can still fail after packaging.
- Docker Buildx requires load: true when a locally runnable image is needed inside the same GitHub Actions job.
- Docker Compose v2 uses docker compose, not the older docker-compose command.
- Alpine-based images may not contain curl, so healthchecks should use tools guaranteed to exist inside the image.
- Publishing containers should use repository secrets and Docker Hub access tokens instead of hardcoded credentials.

## Troubleshooting Log

Issue:
The original application name and repository name were generic and weak for professional portfolio use.

Resolution:
Renamed the implementation around the outcome: automated container delivery pipeline.

Issue:
The original test expected the application server to already be running.

Resolution:
Created a test script that starts the Node.js application process, waits for readiness, calls /health, and exits cleanly.

Issue:
The original Dockerfile used node:18-alpine.

Resolution:
Updated the runtime to node:20-alpine for a stronger modern LTS baseline.

Issue:
The original Dockerfile used npm install --only=production.

Resolution:
Used npm ci --omit=dev with a committed package-lock.json for deterministic container builds.

Issue:
The original Compose examples used the version field.

Resolution:
Removed the top-level version key because Compose v2 no longer requires it.

Issue:
The original app healthcheck used curl inside the Node Alpine container.

Resolution:
Replaced the healthcheck with a Node.js HTTP command so it works without installing curl.

Issue:
The original workflow used docker/build-push-action@v5.

Resolution:
Updated the workflow to docker/build-push-action@v6.

Issue:
The original workflow built a test image but did not explicitly load it into the Docker daemon.

Resolution:
Added load: true so docker run can execute the test image inside the same workflow job.

Issue:
The original workflow used docker-compose.

Resolution:
Changed all workflow commands to docker compose for Docker Compose v2 compatibility.

Issue:
The original version update command used a brittle sed replacement.

Resolution:
Created scripts/update-version.sh to update package.json, package-lock.json, and app.js consistently.

Issue:
The original workflow did not include a local asset validation script.

Resolution:
Created scripts/validate-ci-assets.sh to verify required files, run tests, build the image, validate Compose configuration, and check workflow content.
