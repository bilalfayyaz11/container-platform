# Docker Container Debugging and Runtime Diagnostics

## What This Does
This repository demonstrates a practical Docker troubleshooting workflow for diagnosing containerized applications. It includes log analysis, runtime inspection, network troubleshooting, startup failure debugging, resource monitoring, and safe container access patterns. The implementation shows how engineers investigate failed containers, inspect running workloads, verify network paths, and document reusable debugging commands for production environments.

## Architecture
+-----------------------------+
| Host Machine                 |
| Docker Engine                |
+-------------+---------------+
              |
              v
+-----------------------------+
| Debug Application Container |
| Python HTTP Server           |
| Port 8080                    |
| Runtime logs                 |
+-------------+---------------+
              |
              v
+-----------------------------+
| Debugging Workflow           |
| docker logs                  |
| docker exec                  |
| docker inspect               |
| docker stats                 |
| docker network inspect       |
+-------------+---------------+
              |
              v
+-----------------------------+
| Failure Scenarios            |
| startup failure              |
| port conflict                |
| runtime exception            |
| memory pressure              |
| network validation           |
+-----------------------------+

## Prerequisites
- Ubuntu 24.04 or compatible Linux environment
- Docker Engine installed and running
- curl
- tree
- net-tools
- Internet access for pulling container images

## Setup & Installation
sudo apt update
sudo apt install -y docker.io curl tree net-tools
sudo systemctl enable --now docker

## How to Reproduce
git clone https://github.com/bilalfayyaz11/container-platform.git
cd container-platform/container-debugging-workflows

docker build -t debug-app .
docker run -d --name debug-container -p 8080:8080 debug-app

curl http://localhost:8080/
curl http://localhost:8080/error
curl http://localhost:8080/nonexistent
curl http://localhost:8080/slow

docker logs debug-container
docker logs --tail 10 debug-container
docker exec debug-container ps aux
docker inspect debug-container
docker stats debug-container --no-stream

docker build -f Dockerfile.debug -t debug-problematic .
docker run -d --name problematic-app debug-problematic
docker logs --tail 20 problematic-app

./cleanup-docker-debugging.sh

## Tools Used
- Docker Engine
- Docker CLI
- Python 3.9 slim container image
- Alpine Linux container image
- Ubuntu container image
- curl
- net-tools
- tree
- docker logs
- docker exec
- docker inspect
- docker stats
- docker network

## Key Skills Demonstrated
- Container log analysis and error filtering
- Runtime process inspection inside containers
- Docker networking inspection and service connectivity testing
- Port conflict diagnosis
- Container startup failure analysis
- Resource usage monitoring with docker stats
- Safe troubleshooting with docker exec instead of risky attach workflows
- Reusable cleanup automation for Docker resources
- Production-style debugging documentation

## Real-World Use Case
This workflow is used by DevOps, SRE, Platform, and Cloud engineers when containerized services fail in development, staging, or production. When an API stops responding, logs show errors, ports conflict, or a container exits unexpectedly, these commands help engineers quickly isolate whether the issue is application code, networking, runtime configuration, resource limits, or container startup behavior.

## Lessons Learned
- docker logs is the fastest first step when a container behaves unexpectedly.
- docker exec is safer than docker attach for most production troubleshooting because it does not connect directly to the main process.
- docker inspect provides low-level container metadata that is essential for networking and runtime analysis.
- Custom Docker networks make service-to-service testing cleaner than relying only on default bridge networking.
- Resource limits can expose memory pressure and help reproduce production failure patterns.

## Troubleshooting Log
- Docker was missing in the fresh environment and was installed through apt.
- tree was missing and was installed through apt for clear file verification.
- The original interactive attach workflow was replaced with a safer logs-plus-exec workflow to avoid accidentally stopping containers.
- Missing debugging tools inside slim images were handled by installing only temporary tools inside the running container.
- A missing file build failure was intentionally created, then converted into a runtime failure to demonstrate both build-time and startup debugging.
- A port conflict was intentionally triggered on host port 8080 and verified with docker ps and netstat.
