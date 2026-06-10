# Node.js Container Image Optimization and Runtime Hardening

## What This Does
This implementation demonstrates how to build secure, efficient, and production-ready Docker images for a Node.js application. It compares official and generic base images, optimizes Dockerfile layer structure, improves build cache usage, implements multi-stage builds, and hardens containers with non-root execution and health checks. The final image is designed to reduce image size, improve build speed, and lower runtime security risk in production environments.

## Architecture
+-----------------------------+
| Developer / CI System       |
| docker build                |
+-------------+---------------+
              |
              v
+-----------------------------+
| Dockerfile Design Patterns  |
| official base image         |
| optimized layers            |
| cache-aware dependency flow |
| multi-stage build           |
| non-root runtime            |
+-------------+---------------+
              |
              v
+-----------------------------+
| Production Container Image  |
| Node.js runtime             |
| Express API                 |
| health endpoint             |
| restricted file permissions |
+-------------+---------------+
              |
              v
+-----------------------------+
| Running Container           |
| port 3000                   |
| / endpoint                  |
| /health endpoint            |
| non-root appuser            |
+-----------------------------+

## Prerequisites
- Ubuntu 24.04 or compatible Linux environment
- Docker Engine installed and running
- curl
- jq
- tree
- Internet access for pulling base images from Docker Hub

## Setup & Installation
sudo apt update
sudo apt install -y docker.io curl jq tree
sudo systemctl enable --now docker

## How to Reproduce
git clone https://github.com/bilalfayyaz11/container-platform.git
cd container-platform/nodejs-image-optimization-hardening

docker build -f task1-official-images/Dockerfile.official -t demo-app:official task1-official-images
docker build -f task2-layer-optimization/Dockerfile.optimized -t demo-app:optimized task2-layer-optimization
docker build -f task4-multistage/Dockerfile.multi-stage -t demo-app:multi-stage task4-multistage
docker build -f task5-security/Dockerfile.secure -t demo-app:secure task5-security
docker build -f Dockerfile.production -t demo-app:production .

docker run -d --name production-test -p 3005:3000 demo-app:production
curl -s http://localhost:3005/ | jq '.'
curl -s http://localhost:3005/health | jq '.'
docker exec production-test whoami
docker exec production-test id
docker stop production-test && docker rm production-test

## Tools Used
- Docker Engine
- Dockerfile
- Node.js
- Express.js
- Alpine Linux
- curl
- jq
- dumb-init
- tini
- Ubuntu 24.04

## Key Skills Demonstrated
- Production Dockerfile design
- Secure container runtime configuration
- Multi-stage container image builds
- Docker layer optimization
- Docker build cache optimization
- Non-root container execution
- Health check implementation
- Image size and layer comparison
- Container permission hardening
- Runtime verification using Docker CLI

## Real-World Use Case
This pattern is used by platform, DevOps, and cloud engineering teams that need to ship application containers safely and efficiently. A company deploying Node.js APIs to Kubernetes, ECS, AKS, or CI/CD pipelines would use these techniques to reduce deployment time, shrink image size, improve security posture, and make container behavior more predictable in production.

## Lessons Learned
- Official runtime images are usually smaller, safer, and easier to maintain than generic operating system images.
- Docker build speed depends heavily on instruction ordering and cache-friendly dependency installation.
- Multi-stage builds separate build-time dependencies from runtime artifacts, reducing final image size.
- Running containers as non-root users reduces the impact of application compromise.
- Health checks make containers easier to monitor and safer to operate in production.

## Troubleshooting Log
- Replaced legacy npm production install syntax with modern omit-based dependency installation.
- Avoided using Git restore commands inside directories that were not initialized as Git repositories.
- Used sudo docker because group membership changes may not apply until a new login session.
- Installed Docker manually because it was not present in the provided Ubuntu environment.
- Installed tree because the file tree utility was missing from the base environment.
