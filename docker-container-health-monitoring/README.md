# Docker Container Health Monitoring

## What This Does

This implementation builds a container reliability testing environment focused on Docker health checks, unhealthy-state simulation, restart policy behavior, and production-ready health monitoring.

The system includes multiple Dockerfiles for basic, advanced, failing, and production-grade container health check configurations. It also includes scripts that inspect container health state, collect health check history, compare restart policies, and generate operational reports for troubleshooting.

This type of implementation helps DevOps, SRE, Platform Engineering, Cloud Operations, and AIOps teams detect when a container process is running but the application inside it is no longer healthy.

## Architecture

    +--------------------------------+
    | Local Docker Host              |
    | Ubuntu 24.04                   |
    +---------------+----------------+
                    |
                    v
    +--------------------------------+
    | Flask Application Container    |
    | /                              |
    | /health                        |
    | /make-unhealthy                |
    | /make-healthy                  |
    +---------------+----------------+
                    |
                    v
    +--------------------------------+
    | Docker HEALTHCHECK Layer       |
    | curl-based HTTP validation     |
    | interval / timeout / retries   |
    +---------------+----------------+
                    |
        +-----------+------------+
        |                        |
        v                        v
+-------------------+    +----------------------+
| Monitoring Scripts|    | Restart Policies     |
| monitor-health.sh |    | always               |
| health-dashboard  |    | on-failure           |
| reports           |    | unless-stopped       |
+-------------------+    +----------------------+

## Prerequisites

- Ubuntu 24.04
- Docker Engine
- Git
- curl
- tree
- Python 3
- Linux shell access
- Sudo access for installing missing packages

## Setup & Installation

sudo apt update

sudo apt install -y docker.io tree

sudo systemctl enable --now docker

sudo usermod -aG docker ubuntu

newgrp docker

docker --version

docker info >/dev/null 2>&1 && echo "Docker daemon running"

tree --version

## How to Reproduce

Create the implementation directory:

mkdir -p ~/docker-container-health-monitoring

cd ~/docker-container-health-monitoring

Build the basic health check image:

docker build -t healthcheck-app:v1 .

Run the basic container:

docker run -d \
--name healthcheck-test \
-p 5000:5000 \
healthcheck-app:v1

Test the application endpoint:

curl http://localhost:5000/

Test the health endpoint:

curl http://localhost:5000/health

Inspect the container health status:

docker inspect healthcheck-test --format='{{.State.Health.Status}}'

Build the advanced health check image:

docker build \
-f Dockerfile.advanced \
-t healthcheck-app:advanced .

Replace the basic container with the advanced container:

docker stop healthcheck-test

docker rm healthcheck-test

docker run -d \
--name healthcheck-advanced \
--restart=on-failure:3 \
-p 5001:5000 \
healthcheck-app:advanced

Inspect the advanced container health status:

docker inspect healthcheck-advanced --format='{{.State.Health.Status}}'

Simulate an unhealthy application state:

curl http://localhost:5001/make-unhealthy

Inspect runtime container status:

docker ps --format "table {{.Names}}\t{{.Status}}"

Restore application health:

curl http://localhost:5001/make-healthy

Build the intentionally failing health check image:

docker build -f Dockerfile.failing -t failing-app .

Run the failing container:

docker run -d --name failing-container -p 5002:5000 failing-app

Inspect failing container health details:

docker inspect failing-container --format='{{json .State.Health}}' | python3 -m json.tool

Run the health monitor:

./monitor-health.sh

Review the generated health report:

cat health-monitor-report.txt

Run the health dashboard:

./health-dashboard.sh

Review the dashboard report:

cat health-dashboard-report.txt

Create containers with different restart policies:

docker run -d --name no-restart-policy -p 5003:5000 healthcheck-app:advanced

docker run -d --name always-restart --restart=always -p 5004:5000 healthcheck-app:advanced

docker run -d --name restart-on-failure --restart=on-failure:5 -p 5005:5000 healthcheck-app:advanced

docker run -d --name restart-unless-stopped --restart=unless-stopped -p 5006:5000 healthcheck-app:advanced

Analyze restart behavior:

./analyze-restarts.sh

Review the restart policy analysis:

cat restart-policy-analysis.txt

Build the production-grade image:

docker build -f Dockerfile.production -t healthcheck-app:production .

Run the production container:

docker run -d \
--name production-app \
--restart=unless-stopped \
-p 5007:5000 \
healthcheck-app:production

Inspect final container health status:

docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

## Tools Used

- Docker Engine
- Docker HEALTHCHECK
- Python 3.12
- Flask
- curl
- Bash
- Docker inspect
- Docker restart policies
- Linux process utilities
- tree

## Key Skills Demonstrated

- Docker health check implementation
- Application-level health endpoint design
- Container failure simulation
- Runtime health inspection
- Restart policy comparison
- Production Dockerfile hardening
- Non-root container execution
- Bash-based observability scripts
- Health status reporting
- Container reliability troubleshooting

## Real-World Use Case

A platform engineering or SRE team can use this pattern to detect application failures that are not visible from process status alone. In production, a container may still be running while the application endpoint is returning errors, hanging, or failing dependencies. Docker health checks give operators, orchestrators, deployment systems, and monitoring pipelines a reliable signal for whether the application inside the container is actually usable.

## Lessons Learned

- A running container is not always a healthy application.
- Health checks should validate real application behavior, not just process existence.
- Health check tools such as curl must be installed before the HEALTHCHECK command depends on them.
- Random failure behavior makes lab validation unreliable, so deterministic failure endpoints are better for testing.
- Restart policies do not automatically restart a container only because it is unhealthy; the main process must exit for restart policy behavior to trigger.
- Production containers should run as non-root users and use clear health check timing values.

## Troubleshooting Log

Issue:
Docker was missing from the fresh Ubuntu 24.04 environment.

Resolution:
Installed docker.io through apt, enabled the Docker service, and added the ubuntu user to the Docker group.

Issue:
The lab expected Docker to be pre-installed.

Resolution:
Verified dependencies first and installed only Docker and tree because curl, Python 3, and watch were already available.

Issue:
The original Dockerfile installed curl after the HEALTHCHECK directive.

Resolution:
Installed curl before defining the HEALTHCHECK instruction for cleaner image maintenance and predictable behavior.

Issue:
The original application introduced random 10 percent health check failures.

Resolution:
Removed random failure behavior and used explicit /make-unhealthy and /make-healthy endpoints for deterministic testing.

Issue:
The lab used Python 3.9 base images.

Resolution:
Used python:3.12-slim to align with the Ubuntu 24.04 environment and modern Python runtime usage.

Issue:
Restart policies can be misunderstood as automatic recovery from unhealthy status alone.

Resolution:
Validated and documented that Docker restart policies act on container process exit behavior, not only on unhealthy health check state.
