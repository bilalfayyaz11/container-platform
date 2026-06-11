# Flask Redis Nginx Container Stack

## What This Does

This implementation builds a production-style multi-container web application stack using Flask, Redis, Nginx, Docker, and Docker Compose.

The system packages a Flask application into a Docker image, stores visitor data in SQLite through a persistent Docker volume, tracks page views with Redis, and exposes the application through an Nginx reverse proxy. It also includes health checks, environment-based configuration, load testing, runtime verification, and automated backup scripts.

This demonstrates the core workflow used by DevOps, Platform Engineering, Backend Infrastructure, and Cloud Engineering teams to containerize and operate web applications reliably.

## Architecture

    +-----------------------------+
    | User / Browser / curl       |
    | HTTP :80                    |
    +-------------+---------------+
                  |
                  v
    +-----------------------------+
    | Nginx Reverse Proxy         |
    | flask-nginx                 |
    | Port 80                     |
    +-------------+---------------+
                  |
                  v
    +-----------------------------+
    | Flask Web Application       |
    | flask-web-app               |
    | Port 5000 / Host 8080       |
    +------+------+---------------+
           |      |
           |      v
           |  +-------------------------+
           |  | Redis Cache             |
           |  | Page View Counter       |
           |  | redis:7-alpine          |
           |  +-------------------------+
           |
           v
    +-----------------------------+
    | SQLite Visitor Database     |
    | Docker Volume: app-data     |
    +-----------------------------+

    +-----------------------------+
    | Backup Automation           |
    | app-data + redis-data       |
    | backups/*.tar.gz            |
    +-----------------------------+

## Prerequisites

- Ubuntu 24.04
- Docker Engine
- Docker Compose V2
- curl
- jq
- tree
- lsof
- Git

## Setup & Installation

sudo apt update

sudo apt install -y docker.io docker-compose-v2 curl jq tree lsof git

sudo systemctl enable docker

sudo systemctl start docker

sudo usermod -aG docker $USER

newgrp docker

## How to Reproduce

Clone or enter the implementation directory:

cd ~/flask-container-stack

Build the Docker image:

docker build -t flask-container-stack:v1.0 .

Start the full container stack:

docker compose up -d --build

Verify running services:

docker compose ps

Test the application through Nginx:

curl -I http://localhost/

Test the Flask health endpoint:

curl -s http://localhost/health | jq

Test application statistics:

curl -s http://localhost/stats | jq

Verify Redis connectivity:

docker compose exec redis redis-cli ping

Verify SQLite visitor records:

docker compose exec web python3 -c "
import sqlite3
conn = sqlite3.connect('/app/data/visitors.db')
cursor = conn.cursor()
cursor.execute('SELECT COUNT(*) FROM visitors')
print('Total visitors:', cursor.fetchone()[0])
conn.close()
"

Run load testing:

./load_test.sh

Run backup automation:

./backup.sh

Capture runtime evidence:

./runtime-verification.sh

## Tools Used

- Docker
- Docker Compose V2
- Python 3.12
- Flask
- Werkzeug
- Redis
- SQLite
- Nginx
- Bash
- curl
- jq
- tree
- Linux

## Key Skills Demonstrated

- Containerized Flask application development
- Dockerfile authoring with non-root runtime user
- Docker Compose multi-container orchestration
- Nginx reverse proxy configuration
- Redis service integration
- SQLite persistence through Docker volumes
- Docker network configuration
- Health check implementation
- Load testing automation
- Volume backup automation
- Runtime validation scripting
- Production-style troubleshooting and documentation

## Real-World Use Case

A company can use this pattern to package a small internal web application or API service with its supporting cache and reverse proxy. The Flask service handles application logic, Redis supports fast counters or session-style data, Nginx provides a stable entry point, and Docker Compose manages the full stack consistently across development, staging, and small production environments.

## Lessons Learned

- Docker Compose V2 no longer requires the legacy version field in compose files.
- Health checks must only reference tools that actually exist inside the image.
- Running the application as a non-root user improves container security.
- Docker volume names should be detected dynamically in scripts instead of hardcoded.
- Nginx provides a clean entry point while keeping backend services isolated inside the Docker network.

## Troubleshooting Log

Issue:
The original Dockerfile used Python 3.9.

Resolution:
Updated the base image to python:3.12-slim for a modern runtime.

Issue:
The original health check used curl but did not install curl inside the image.

Resolution:
Installed curl in the Dockerfile before defining the health check.

Issue:
The original Flask application used debug mode.

Resolution:
Disabled debug mode for container-safe execution.

Issue:
The original workflow used docker-compose commands.

Resolution:
Used Docker Compose V2 syntax with docker compose.

Issue:
The original compose file used a legacy version field.

Resolution:
Removed the version field and used the current Compose V2 format.

Issue:
The original backup script hardcoded Docker volume names.

Resolution:
Created a dynamic backup script that detects app-data and redis-data volume names automatically.

Issue:
Single-container deployment can conflict with Compose ports.

Resolution:
Removed the standalone container before starting the multi-container Compose stack.
