# Docker Swarm Service Orchestration

## What This Does

This implementation builds a Docker Swarm orchestration environment on Ubuntu and deploys replicated services through Docker’s native clustering system.

The system initializes a Swarm manager, deploys replicated Nginx and long-running API-style services, scales workloads, creates an overlay network, manages secrets, performs service updates and rollbacks, and generates an operational monitoring report.

This demonstrates core container orchestration skills used by DevOps, Platform Engineering, SRE, Cloud Operations, and infrastructure teams responsible for running distributed container workloads.

## Architecture

    +--------------------------------+
    | Docker Swarm Manager Node      |
    | Ubuntu 24.04                   |
    | Swarm Leader                   |
    +---------------+----------------+
                    |
                    v
    +--------------------------------+
    | Swarm Control Plane            |
    | Scheduling                     |
    | Service State                  |
    | Rolling Updates                |
    | Secrets Management             |
    +---------------+----------------+
                    |
        +-----------+------------+
        |                        |
        v                        v
+-------------------+    +----------------------+
| Replicated Web    |    | Replicated API        |
| nginx:alpine      |    | alpine long-running   |
| Published 8080    |    | Resource limits       |
+-------------------+    +----------------------+
        |
        v
+------------------------------+
| Overlay Network              |
| swarm-overlay-network        |
+------------------------------+

## Prerequisites

- Ubuntu 24.04
- Docker Engine
- Git
- curl
- tree
- Linux shell access
- Docker daemon running
- Sudo access for package installation

## Setup & Installation

sudo apt update

sudo apt install -y docker.io tree

sudo systemctl enable --now docker

sudo usermod -aG docker ubuntu

newgrp docker

docker --version

docker info | grep -i swarm

## How to Reproduce

Create the working directory:

mkdir -p ~/docker-swarm-service-orchestration

cd ~/docker-swarm-service-orchestration

Initialize Docker Swarm:

docker swarm init --advertise-addr $(hostname -I | awk '{print $1}')

Verify manager status:

docker node ls

docker node inspect self --pretty

Create a replicated web service:

docker service create \
  --name web-service \
  --publish 8080:80 \
  --replicas 2 \
  nginx:alpine

Verify the service:

docker service ls

docker service ps web-service

curl -I http://localhost:8080

Create a long-running API-style service:

docker service create \
  --name api-service \
  --replicas 3 \
  --limit-cpu 0.5 \
  --limit-memory 512M \
  --update-delay 10s \
  --update-parallelism 1 \
  --restart-condition on-failure \
  --restart-max-attempts 3 \
  alpine:latest sh -c "while true; do echo 'API Service Running'; sleep 30; done"

Scale services:

docker service scale web-service=5

docker service scale api-service=4

docker service ls

Scale services down:

docker service scale web-service=2 api-service=2

Create an overlay network:

docker network create --driver overlay swarm-overlay-network

Deploy a service on the overlay network:

docker service create \
  --name networked-service \
  --network swarm-overlay-network \
  --replicas 2 \
  nginx:alpine

Create a Docker secret:

echo "production-db-password" | docker secret create db_password -

Deploy a service using the secret:

docker service create \
  --name secure-service \
  --secret db_password \
  --replicas 1 \
  alpine:latest sleep 3600

Update the web service image:

docker service update --image nginx:1.27-alpine web-service

Rollback the service:

docker service rollback web-service

Run the monitoring script:

./monitor_swarm.sh

Review the generated report:

cat swarm-status-report.txt

## Tools Used

- Docker Engine
- Docker Swarm Mode
- Docker Services
- Docker Overlay Networks
- Docker Secrets
- Nginx
- Alpine Linux
- Bash
- Linux networking
- tree

## Key Skills Demonstrated

- Docker Swarm cluster initialization
- Manager node operation
- Service deployment across Swarm mode
- Replica scaling
- Rolling service updates
- Service rollback
- Overlay network creation
- Secret management
- Runtime service inspection
- Swarm monitoring automation
- Container orchestration troubleshooting

## Real-World Use Case

A platform engineering team could use this pattern to run small-to-medium containerized workloads without introducing the operational complexity of Kubernetes. Docker Swarm can coordinate replicated services, manage service discovery, handle rolling updates, expose services through published ports, and provide a simpler orchestration layer for internal tools, edge deployments, staging systems, and lightweight production workloads.

## Lessons Learned

- Docker Swarm can be initialized and tested on a single manager node when a multi-node environment is not available.
- Swarm services behave differently from standalone containers because the desired state is managed by the orchestration layer.
- Published ports expose services through Swarm routing mesh.
- Overlay networks allow services to communicate through Swarm-native networking.
- Docker secrets provide a safer way to inject sensitive values than hardcoding credentials in commands.
- Rolling updates and rollbacks are core operational features for safe service changes.

## Troubleshooting Log

Issue:
The lab guide expected Docker to be pre-installed, but Docker was missing from the fresh Ubuntu 24.04 environment.

Resolution:
Installed docker.io through apt and enabled the Docker service before initializing Swarm.

Issue:
The lab guide referenced Ubuntu 20.04, but the actual environment was Ubuntu 24.04.3.

Resolution:
Adapted installation and validation commands for Ubuntu 24.04 while keeping Swarm commands unchanged.

Issue:
The lab was written for a multi-node Swarm cluster, but the available environment provided only one machine.

Resolution:
Completed the orchestration workflow as a single-node Swarm manager while still validating services, scaling, overlay networking, secrets, updates, rollback, and monitoring.

Issue:
The original API service example used node:16-alpine.

Resolution:
Replaced it with alpine:latest for a lightweight long-running demo service because Node.js 16 is outdated and unnecessary for this orchestration-focused workflow.

Issue:
Operational output needed to be preserved for portfolio evidence.

Resolution:
Created monitor_swarm.sh and generated swarm-status-report.txt containing node, service, task, network, secret, and Docker system usage information.
