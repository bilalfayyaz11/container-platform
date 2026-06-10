# Docker Container Security Hardening

## What This Does

This implementation provides a hardened Docker container deployment pattern for a Python web application using production-grade container security controls.

The system demonstrates non-root container execution, reduced Linux capabilities, read-only container filesystems, temporary writable mounts, Docker image scanning, runtime security options, and secure Compose-based deployment.

This type of implementation helps Platform Engineering, DevSecOps, Cloud Security, and SRE teams reduce container attack surface before workloads are promoted into production environments.

## Architecture

    +----------------------------------+
    | Python Flask Application         |
    | app.py / app_readonly.py         |
    +----------------+-----------------+
                     |
                     v
    +----------------------------------+
    | Hardened Docker Images           |
    | secure-app:v1                    |
    | secure-app:v2                    |
    | readonly-app:v1                  |
    +----------------+-----------------+
                     |
                     v
    +----------------------------------+
    | Runtime Security Controls        |
    | Non-root user                    |
    | Capability drop                  |
    | no-new-privileges                |
    | AppArmor default profile         |
    | Read-only filesystem             |
    | tmpfs writable /tmp              |
    +----------------+-----------------+
                     |
                     v
    +----------------------------------+
    | Secure Compose Deployment        |
    | docker-compose.secure.yml        |
    | Healthcheck                      |
    | Restart policy                   |
    | Log rotation                     |
    +----------------+-----------------+
                     |
                     v
    +----------------------------------+
    | Security Validation              |
    | Docker Scout CVE scan            |
    | Process inspection               |
    | Filesystem verification          |
    | Privilege escalation test        |
    +----------------------------------+

## Prerequisites

- Ubuntu 24.04
- Docker Engine
- Docker Compose V2
- Git
- curl
- tree
- Internet access for pulling base images and installing Docker Scout
- Permission to run Docker containers

## Setup & Installation

sudo apt update

sudo apt install -y docker.io docker-compose-v2 curl tree ca-certificates gnupg

sudo systemctl enable docker

sudo systemctl start docker

sudo usermod -aG docker $USER

newgrp docker

docker --version

docker compose version

## How to Reproduce

Create the working directory:

mkdir -p ~/secure-app

cd ~/secure-app

Create the Flask application and dependency file:

cat > app.py << 'APP'
from flask import Flask
import os

app = Flask(__name__)

@app.route('/')
def hello():
    return f"Hello from secure container! Running as user: {os.getuid()}"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
APP

cat > requirements.txt << 'REQ'
Flask==2.3.3
REQ

Build the non-root container image:

docker build -t secure-app:v1 .

Run and validate non-root execution:

docker run -d -p 8080:8080 --name secure-app-container secure-app:v1

curl http://localhost:8080

docker exec secure-app-container id

docker stop secure-app-container

docker rm secure-app-container

Build the hardened image:

docker build -f Dockerfile.secure -t secure-app:v2 .

Scan the image:

docker scout cves secure-app:v2

Build the read-only filesystem image:

docker build -f Dockerfile.readonly -t readonly-app:v1 .

Run the read-only container:

docker run -d --name readonly-container \
  --read-only \
  --tmpfs /tmp:rw,noexec,nosuid,size=100m \
  --cap-drop=ALL \
  --cap-add=NET_BIND_SERVICE \
  --security-opt=no-new-privileges:true \
  -p 8083:8080 \
  readonly-app:v1

Test allowed and blocked writes:

curl http://localhost:8083/

curl -X POST http://localhost:8083/write-test

curl -X POST http://localhost:8083/illegal-write

docker exec readonly-container touch /app/test-file.txt || true

docker exec readonly-container touch /tmp/test-file.txt

Deploy the full secure runtime profile:

docker compose -f docker-compose.secure.yml up -d

docker compose -f docker-compose.secure.yml ps

curl http://localhost:8084/

curl -X POST http://localhost:8084/write-test

curl -X POST http://localhost:8084/illegal-write

Validate runtime security settings:

CONTAINER_ID=$(docker compose -f docker-compose.secure.yml ps -q secure-web-app)

docker inspect "$CONTAINER_ID" | grep -A 20 "SecurityOpt"

docker exec "$CONTAINER_ID" ps aux

docker exec "$CONTAINER_ID" ls -la /

docker exec "$CONTAINER_ID" su - || true

## Tools Used

- Docker Engine
- Docker Compose V2
- Docker Scout
- Python 3
- Flask
- Alpine Linux
- Debian slim base image
- AppArmor
- Linux capabilities
- tmpfs
- Bash
- curl
- tree
- Git

## Key Skills Demonstrated

- Docker image hardening
- Non-root container execution
- Container privilege reduction
- Linux capability management
- Read-only container filesystem implementation
- Secure temporary filesystem mounting
- Docker Compose security configuration
- Runtime security validation
- Container vulnerability scanning
- Image hardening based on scan feedback
- DevSecOps security controls
- Cloud platform workload hardening
- Production container deployment practices

## Real-World Use Case

A platform engineering team can use this pattern to harden application containers before deploying them into Kubernetes, ECS, Azure Container Apps, or internal container platforms. By enforcing non-root execution, read-only filesystems, restricted capabilities, and vulnerability scanning, the organization reduces the blast radius of compromised workloads and improves alignment with security frameworks such as CIS Docker Benchmark, NIST container security guidance, and SOC 2 infrastructure controls.

## Lessons Learned

- Running containers as non-root is one of the simplest and highest-impact container security controls.
- Dropping all Linux capabilities by default forces the application to run with only the permissions it actually needs.
- Read-only filesystems prevent attackers or broken application logic from writing persistent changes inside the container.
- tmpfs mounts provide a safe writable location for temporary runtime data without weakening the full filesystem.
- Docker Compose security settings can model production runtime controls before moving the workload to a larger orchestration platform.

## Troubleshooting Log

Issue:
The original environment description expected Ubuntu 20.04, but the actual environment was Ubuntu 24.04.3.

Resolution:
Used Ubuntu 24.04-compatible package installation and Docker Compose V2 commands.

Issue:
The original instructions used legacy docker-compose syntax.

Resolution:
Replaced docker-compose with modern Docker Compose V2 syntax using docker compose.

Issue:
Docker Content Trust commands were unreliable for a plain local image name and local registry signing workflow.

Resolution:
Tested Content Trust safely with DOCKER_CONTENT_TRUST enabled, local registry tagging, guarded push commands, and documented trust inspection behavior without blocking the rest of the implementation.

Issue:
The secure Alpine Dockerfile healthcheck used curl but did not install curl.

Resolution:
Added curl to the Alpine package installation step.

Issue:
The read-only container validation required process inspection, but Alpine images do not always include ps by default.

Resolution:
Added procps to the read-only image build so runtime process checks work correctly.

Issue:
The original Compose file used a top-level version field.

Resolution:
Removed the obsolete version field because modern Docker Compose no longer requires it.

Issue:
Read-only containers fail when applications attempt to write inside the application directory.

Resolution:
Mounted /tmp as tmpfs with rw,noexec,nosuid options and verified that /app writes fail while /tmp writes succeed.
