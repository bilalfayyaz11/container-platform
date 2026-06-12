# Python Containerized Web Platform

## What This Does

This implementation builds a containerized Python Flask web platform with persistent visitor tracking, Docker image packaging, health checks, Nginx reverse proxy routing, Docker Compose orchestration, operational monitoring, and database backup automation.

The platform starts as a standalone Flask application and evolves into a multi-container application stack managed through Docker Compose. It includes a non-root container image, persistent SQLite storage through Docker volumes, application health validation, reverse proxy routing, backup scripts, and platform validation reports.

This mirrors how DevOps, Platform Engineering, Cloud Engineering, SRE, and Python Backend teams package and operate Python services in containerized environments.

## Architecture

    +--------------------------------+
    | User / Browser / curl          |
    +---------------+----------------+
                    |
                    v
    +--------------------------------+
    | Nginx Reverse Proxy            |
    | Port 80                        |
    | Routes / and /health           |
    +---------------+----------------+
                    |
                    v
    +--------------------------------+
    | Python Flask Web Service       |
    | Visitor Tracker API            |
    | Health Endpoint                |
    | Non-root Container User        |
    +---------------+----------------+
                    |
                    v
    +--------------------------------+
    | Persistent SQLite Volume       |
    | visitors.db                    |
    +---------------+----------------+
                    |
                    v
    +--------------------------------+
    | Operations Tooling             |
    | health-monitor.sh              |
    | backup-database.sh             |
    | platform-report.sh             |
    +--------------------------------+

## Prerequisites

- Ubuntu 24.04
- Docker Engine
- Docker Compose v2
- Python 3
- pip
- curl
- tree
- Git
- Linux shell access

## Setup & Installation

sudo apt update

sudo apt install -y docker.io docker-compose-v2 python3-pip tree

sudo systemctl enable --now docker

sudo usermod -aG docker ubuntu

newgrp docker

docker --version

docker compose version

python3 --version

pip3 --version

tree --version

## How to Reproduce

Create the working directory:

mkdir -p ~/python-containerized-web-platform

cd ~/python-containerized-web-platform

Build and run the standalone Flask container:

cd app

docker build -t python-flask-app:v1.0 .

docker run -d \
  --name flask-app-container \
  -p 8080:5000 \
  -v $(pwd)/data:/app/data \
  python-flask-app:v1.0

Test the standalone container:

curl http://localhost:8080/health

docker logs flask-app-container

Stop the standalone container before Compose deployment:

docker rm -f flask-app-container

Start the multi-container platform:

cd ..

docker compose up -d --build

Verify service status:

docker compose ps

Test the Nginx-routed health endpoint:

curl http://localhost/health

Test the web application:

curl http://localhost

Generate sample visitor data:

for i in {1..10}
do
curl -s -X POST \
-F "name=user_$i" \
http://localhost/add_visitor >/dev/null
done

Run the health monitor:

./scripts/health-monitor.sh

Create a database backup:

./scripts/backup-database.sh

Generate a platform validation report:

./scripts/platform-report.sh

Review generated artifacts:

ls -lh backups

cat platform-validation-report.txt

cat health-monitor-report.txt

## Tools Used

- Python 3.12
- Flask
- Werkzeug
- Docker Engine
- Docker Compose v2
- Nginx
- SQLite
- Bash
- curl
- Docker volumes
- Docker bridge networks
- Docker health checks

## Key Skills Demonstrated

- Python application containerization
- Dockerfile design
- Non-root container execution
- Docker health check implementation
- Persistent storage with Docker volumes
- Docker Compose orchestration
- Reverse proxy configuration
- Container networking
- Application readiness validation
- Backup automation
- Runtime health monitoring
- Platform validation reporting
- Production-style container operations

## Real-World Use Case

A backend or platform engineering team can use this pattern to package a Python Flask service into a repeatable container image, expose it through a reverse proxy, persist application data, validate service health, and automate operational checks. This type of containerized deployment pattern is common in internal tools, staging environments, small production services, developer platforms, and migration paths toward Kubernetes or managed container services.

## Lessons Learned

- Docker health checks must include the tools they depend on inside the image.
- Non-root containers reduce security risk and are preferred for production workloads.
- Docker Compose v2 should be used through the modern docker compose syntax.
- Reverse proxies provide a cleaner entry point than exposing application containers directly.
- Persistent volumes prevent application data from disappearing when containers are recreated.
- Backup and validation scripts turn a simple app into an operational platform artifact.

## Troubleshooting Log

Issue:
Docker, Docker Compose v2, pip, and tree were missing from the fresh Ubuntu 24.04 environment.

Resolution:
Installed only the missing dependencies with apt and enabled the Docker service.

Issue:
The original workflow used pip3 install globally.

Resolution:
Used a Python virtual environment for local application testing to avoid Ubuntu 24.04 externally managed Python package restrictions.

Issue:
The original Dockerfile used python:3.9-slim.

Resolution:
Updated the base image to python:3.12-slim to align with the current Ubuntu 24.04 Python runtime.

Issue:
The Dockerfile health check used curl but did not install curl inside the image.

Resolution:
Installed curl before defining the HEALTHCHECK instruction.

Issue:
The original Compose workflow used legacy docker-compose syntax.

Resolution:
Used Docker Compose v2 syntax with docker compose.

Issue:
Older Compose examples only wait for container startup.

Resolution:
Used depends_on with service_healthy so Nginx waits for Flask readiness.

Issue:
Directly copying SQLite files from an active host volume can risk inconsistent backups.

Resolution:
Copied the database from inside the running web container before exporting it into the backups directory.
