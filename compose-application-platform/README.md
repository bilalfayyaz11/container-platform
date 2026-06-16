# Multi Service Application Platform with Docker Compose

## What This Does

This implementation provides a production-style multi-service application platform built with Docker Compose. The platform combines a Flask API, PostgreSQL database, Redis cache, Adminer database administration interface, and Nginx reverse proxy into a single orchestrated environment.

The architecture demonstrates service discovery, health monitoring, persistent storage, inter-container networking, application scaling, load balancing, and dependency management. Each service operates independently while communicating securely through an isolated Docker network.

The platform follows patterns commonly used in development, staging, internal platforms, proof-of-concept environments, and small-scale production deployments where multiple services must operate together as a cohesive application stack.

## Architecture

    +------------------------------------------------------+
    |                    Client Requests                   |
    +-------------------------+----------------------------+
                              |
                              v
    +------------------------------------------------------+
    |                     Nginx Proxy                      |
    |                  Port 8080 External                  |
    +-------------------------+----------------------------+
                              |
                              v
    +------------------------------------------------------+
    |              Flask / Gunicorn Web Layer             |
    |                  Scalable Replicas                  |
    +-----------+---------------------+-------------------+
                |                     |
                v                     v
    +------------------+    +---------------------------+
    | Redis Cache      |    | PostgreSQL Database       |
    | Authenticated    |    | Persistent Storage        |
    | Port 6379        |    | Port 5432                 |
    +------------------+    +---------------------------+
                                      |
                                      v
                         +---------------------------+
                         | Adminer Management UI     |
                         | Port 8081                |
                         +---------------------------+

    Shared Components:
    - Docker Compose V2
    - Custom Bridge Network
    - Named Persistent Volumes
    - Health Checks
    - Service Discovery
    - Environment Configuration

## Prerequisites

- Ubuntu 24.04
- Docker Engine
- Docker Compose V2
- Git
- curl
- jq
- tree

## Setup & Installation

sudo apt-get update -y

sudo apt-get install -y \
  docker.io \
  curl \
  jq \
  tree \
  git

sudo systemctl enable --now docker

docker --version

docker compose version

## How to Reproduce

Create workspace:

mkdir -p ~/compose-application-stack

cd ~/compose-application-stack

Validate Compose configuration:

docker compose config

Build services:

docker compose build --no-cache

Start platform:

docker compose up -d

Verify health:

docker compose ps

Test application:

curl http://localhost:8080

curl http://localhost:8080/health

Retrieve users:

curl http://localhost:8080/users

Write cache entry:

curl http://localhost:8080/cache/demo/test

Read cache entry:

curl http://localhost:8080/cache/demo

Scale application tier:

docker compose up -d --scale web=3

Verify load balancing:

for i in {1..10}; do
  curl -s http://localhost:8080
done

Scale back down:

docker compose up -d --scale web=1

Stop platform:

docker compose stop

Start platform:

docker compose start

Shutdown platform:

docker compose down

## Tools Used

- Docker
- Docker Compose V2
- Flask
- Gunicorn
- PostgreSQL
- Redis
- Adminer
- Nginx
- Python
- Linux
- curl
- jq
- Git

## Key Skills Demonstrated

- Multi-container orchestration
- Docker Compose architecture
- Service discovery and networking
- Redis caching integration
- PostgreSQL integration
- Database initialization automation
- Persistent volume management
- Health check implementation
- Reverse proxy configuration
- Load balancing
- Application scaling
- Environment variable management
- Container troubleshooting
- Runtime observability
- Platform operations

## Real-World Use Case

Organizations commonly deploy application stacks consisting of web applications, databases, caches, and reverse proxies. This architecture demonstrates how multiple independently managed services can be orchestrated through Docker Compose while maintaining persistence, scalability, observability, and service isolation. Similar patterns are frequently used for internal platforms, development environments, staging systems, proof-of-concept deployments, and smaller production workloads.

## Lessons Learned

- Redis authentication must be configured consistently between server and client.
- PostgreSQL initialization scripts should not recreate databases already provisioned by container environment variables.
- Docker Compose service scaling cannot be used when container_name is hardcoded.
- Nginx provides a clean path for routing traffic to scaled application containers.
- Health checks require all referenced binaries to exist inside the image.
- Docker Compose networking simplifies service discovery through DNS-based container names.

## Troubleshooting Log

Issue:
Redis was configured with requirepass but the Flask application did not provide authentication.

Resolution:
Added REDIS_PASSWORD support through environment variables and updated the Redis client configuration.

Issue:
PostgreSQL initialization attempted to create an already existing database.

Resolution:
Removed CREATE DATABASE statements and initialized tables directly.

Issue:
Docker Compose service scaling failed.

Resolution:
Removed fixed container_name declarations to allow Compose-managed replica creation.

Issue:
Container health checks failed.

Resolution:
Installed curl in the web application image so health checks could execute successfully.

Issue:
Legacy Compose version field was used.

Resolution:
Removed version field and adopted Compose Specification format compatible with Docker Compose V2.

Issue:
Direct host port mapping prevented service scaling.

Resolution:
Introduced Nginx reverse proxy and exposed only the proxy service externally.

Issue:
Application load balancing required a shared frontend endpoint.

Resolution:
Configured Nginx upstream routing to distribute traffic across web service replicas.
