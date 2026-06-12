# Docker Microservices Platform with API Gateway

## What This Does

This implementation delivers a complete containerized microservices platform composed of four independent services: User Service, Product Service, Order Service, and an API Gateway.

Each service owns a single business domain, runs in its own Docker container, and communicates through a shared Docker bridge network using internal DNS-based service discovery. The Order Service performs live inter-service communication to validate users and retrieve product pricing before calculating order totals.

An API Gateway acts as the single public entry point, providing request routing, reverse proxying, rate limiting, structured error handling, and centralized request logging.

This architecture mirrors real-world cloud-native application deployments and provides a strong foundation for future migration to Kubernetes and service mesh platforms.

## Architecture

    Internet Clients
           |
           v
    +----------------------+
    |      API Gateway     |
    | Port 3000            |
    | Rate Limiting        |
    | Request Logging      |
    | Reverse Proxy        |
    +----------+-----------+
               |
     +---------+---------+---------+
     |                   |         |
     v                   v         v

+----------------+ +----------------+ +----------------+
| User Service   | | Product Service| | Order Service  |
| Port 3001      | | Port 3002      | | Port 3003      |
| User APIs      | | Product APIs   | | Order APIs     |
+--------+-------+ +--------+-------+ +--------+-------+
         |                  |                  |
         +------------------+------------------+
                            |
                            v

              Docker Bridge Network
                 microservices-net

## Prerequisites

- Ubuntu 24.04 LTS
- Docker Engine
- Docker Compose Plugin
- Node.js
- npm
- Git
- curl
- jq
- tree

## Setup & Installation

docker compose build

docker compose up -d

docker compose ps

## Tools Used

- Docker
- Docker Compose
- Docker Networking
- Node.js
- Express.js
- HTTP Proxy Middleware
- Express Rate Limit
- REST APIs
- Microservices

## Key Skills Demonstrated

- Microservices architecture design
- API Gateway implementation
- Service discovery using Docker DNS
- Docker Compose orchestration
- Reverse proxy configuration
- HTTP rate limiting
- Inter-service communication
- Graceful degradation
- Health check implementation
- Horizontal scaling readiness

## Real-World Use Case

Organizations frequently split large applications into independent services to improve scalability, deployment flexibility, fault isolation, and team ownership. This implementation demonstrates how user management, product catalog management, and order processing can operate as independent services while remaining connected through an API Gateway.

The same architecture pattern is widely used in SaaS platforms, e-commerce systems, fintech applications, internal developer platforms, and cloud-native enterprise systems before moving workloads into Kubernetes clusters.

## Lessons Learned

- Service boundaries should align with business domains.
- Docker DNS eliminates the need for hardcoded IP addresses.
- API Gateways provide centralized routing and security controls.
- Graceful degradation prevents cascading failures.
- Docker Compose provides an effective orchestration layer before Kubernetes adoption.

## Troubleshooting Log

Issue:
Docker containers could not communicate initially.

Resolution:
Attached all services to a shared user-defined bridge network.

Issue:
Order Service depended on external services.

Resolution:
Implemented graceful degradation and structured fallback behavior.

Issue:
Scaling product-service failed when container names were fixed.

Resolution:
Removed container_name usage and relied on Compose service discovery.

Issue:
Backend service failures produced proxy errors.

Resolution:
Implemented custom API Gateway error handling with HTTP 503 JSON responses.
