# Docker Compose Multi-Service Application Platform

## What This Does

This implementation provides a complete multi-container application platform using Docker Compose. It runs a Python Flask API, PostgreSQL database, Redis cache, and Nginx reverse proxy as one coordinated application stack.

The platform demonstrates service orchestration, internal container networking, persistent database storage, cache integration, reverse proxy routing, health validation, horizontal scaling, log inspection, resource monitoring, load testing, and backup generation.

This type of setup is commonly used by DevOps, Platform Engineering, Cloud Engineering, SRE, and AIOps teams to run production-like application environments with repeatable infrastructure configuration.

## Architecture

    +-------------------------------+
    | External User / Local Client  |
    | curl / browser / ab testing   |
    +---------------+---------------+
                    |
                    v
    +-------------------------------+
    | Nginx Reverse Proxy           |
    | Port 80                       |
    | Routes traffic to Flask API   |
    +---------------+---------------+
                    |
                    v
    +-------------------------------+
    | Flask Web Application         |
    | Gunicorn workers              |
    | Health endpoint               |
    | User API                      |
    +-----------+-------------------+
                |
        +-------+--------+
        |                |
        v                v
+----------------+   +----------------+
| PostgreSQL     |   | Redis Cache    |
| User records   |   | Page views     |
| Persistent Vol |   | Persistent Vol |
+----------------+   +----------------+

## Prerequisites

- Ubuntu 24.04
- Docker Engine
- Docker Compose v2
- Git
- curl
- tree
- Apache Bench
- Linux shell access
- Internet access for pulling container images

## Setup & Installation

sudo apt update

sudo apt install -y docker.io docker-compose-v2 git curl tree apache2-utils

sudo systemctl enable --now docker

sudo usermod -aG docker ubuntu

newgrp docker

docker --version

docker compose version

## How to Reproduce

Clone or copy the implementation files into a working directory:

cd ~

cd docker-compose-platform

Validate the Compose configuration:

docker compose config

Build and start the full stack:

docker compose up -d --build

Verify running services:

docker compose ps

Test the health endpoint through Nginx:

curl http://localhost/health

Test the main application endpoint:

curl http://localhost/

Create a user through the API:

curl -X POST http://localhost/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com"}'

List users from PostgreSQL:

curl http://localhost/users

Inspect service logs:

docker compose logs --tail=50

Inspect the application network:

docker network inspect docker-compose-platform_app-network

Inspect persistent volumes:

docker volume inspect docker-compose-platform_postgres_data

docker volume inspect docker-compose-platform_redis_data

Scale the web service:

docker compose up -d --scale web=3

Run a basic load test:

ab -n 500 -c 10 http://localhost/

Create a PostgreSQL backup:

docker compose exec db pg_dump -U postgres webapp > webapp_backup.sql

Create a compressed database volume backup:

docker run --rm \
-v docker-compose-platform_postgres_data:/data \
-v $(pwd):/backup \
alpine \
tar czf /backup/postgres_backup.tar.gz -C /data .

## Tools Used

- Docker Engine
- Docker Compose v2
- Python 3.11
- Flask
- Gunicorn
- PostgreSQL 15
- Redis 7
- Nginx
- Apache Bench
- Bash
- Linux networking
- Docker volumes
- Docker bridge networks

## Key Skills Demonstrated

- Multi-container application orchestration
- Docker Compose service dependency management
- Reverse proxy configuration
- Container networking
- Persistent storage with Docker volumes
- PostgreSQL initialization and backup
- Redis cache integration
- Health check implementation
- Horizontal service scaling
- Runtime log inspection
- Resource monitoring
- Load testing
- Production-style troubleshooting

## Real-World Use Case

A software engineering team could use this platform to run a production-like local or staging environment for a web application that depends on an API service, database, cache, and reverse proxy. This reduces environment drift, makes onboarding easier for developers, and gives platform teams a repeatable blueprint for testing service connectivity, storage persistence, scaling behavior, and operational troubleshooting before moving workloads to Kubernetes or cloud container services.

## Lessons Learned

- Docker Compose v2 should be used with the modern docker compose syntax instead of legacy docker-compose.
- Container health checks must include the tools they depend on inside the image.
- Publishing a web container directly to a fixed host port prevents horizontal scaling.
- Persistent volumes allow database data to survive container restarts.
- Nginx provides a cleaner production-style entry point than exposing application containers directly.
- Backup artifacts should be generated before destructive cleanup commands are used.

## Troubleshooting Log

Issue:
Docker and Docker Compose were not installed in the fresh Ubuntu 24.04 environment.

Resolution:
Installed docker.io and docker-compose-v2 through apt, enabled the Docker service, and added the ubuntu user to the docker group.

Issue:
The original workflow used legacy docker-compose syntax.

Resolution:
Used Docker Compose v2 syntax with docker compose for all build, launch, scaling, logging, and inspection commands.

Issue:
The Flask container Dockerfile used curl in the health check but did not install curl inside the image.

Resolution:
Added curl to the Dockerfile system package installation step so container health checks can run successfully.

Issue:
The web service originally exposed port 5000 directly on the host.

Resolution:
Removed direct host port publishing from the web service so docker compose up -d --scale web=3 can work without port binding conflicts.

Issue:
The platform needed persistent database backups before cleanup.

Resolution:
Generated both a logical PostgreSQL backup using pg_dump and a compressed Docker volume backup using an Alpine helper container.
