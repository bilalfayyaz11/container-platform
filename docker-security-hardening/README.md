# Docker Container Security Hardening Platform

## What This Does

This implementation demonstrates a layered container security architecture that combines non-root execution, read-only filesystems, dropped Linux capabilities, AppArmor mandatory access control, resource limits, automatic restart policies, and image distribution through a private registry.

The platform includes a hardened Python HTTP service that exposes runtime security validation endpoints, allowing verification that filesystem protections, privilege restrictions, and policy enforcement are active during execution.

The deployment follows a defense-in-depth model where multiple independent controls work together to reduce the impact of container compromise. Rather than relying on a single security mechanism, each layer protects against a different attack path.

This approach mirrors production container security practices used by DevSecOps, Platform Engineering, Cloud Security, Kubernetes Security, and Site Reliability Engineering teams.

## Architecture

    +---------------------------------------------------+
    | Ubuntu 24.04 Host                                |
    +----------------------+----------------------------+
                           |
                           v
    +---------------------------------------------------+
    | Docker Engine                                     |
    | Container Runtime                                 |
    +----------------------+----------------------------+
                           |
                           v
    +---------------------------------------------------+
    | AppArmor Enforcement Layer                        |
    | docker-hardened-python                            |
    | Deny /etc/shadow                                  |
    | Deny /proc/sys writes                             |
    +----------------------+----------------------------+
                           |
                           v
    +---------------------------------------------------+
    | Hardened Runtime Container                        |
    | Non-root UID 10001                                |
    | Read-only Root Filesystem                         |
    | No New Privileges                                 |
    | All Linux Capabilities Dropped                    |
    | CPU Limited                                       |
    | Memory Limited                                    |
    +----------------------+----------------------------+
                           |
                           v
    +---------------------------------------------------+
    | Python Security Validation Service               |
    | Runtime Identity Endpoint                         |
    | Shadow Access Test Endpoint                       |
    | Kernel Write Test Endpoint                        |
    +----------------------+----------------------------+
                           |
                           v
    +---------------------------------------------------+
    | Local Registry                                    |
    | registry:2                                        |
    | Internal Image Distribution                       |
    +---------------------------------------------------+

## Prerequisites

- Ubuntu 24.04
- Docker Engine
- AppArmor
- apparmor-utils
- libcap2-bin
- Python 3
- pip
- curl
- jq
- tree
- Git

## Setup & Installation

sudo apt-get update -y

sudo apt-get install -y \
  ca-certificates \
  curl \
  gnupg \
  lsb-release \
  apparmor \
  apparmor-utils \
  libcap2-bin \
  python3 \
  python3-pip \
  git \
  tree \
  jq

sudo systemctl enable --now docker

sudo systemctl enable --now apparmor

sudo usermod -aG docker $USER

newgrp docker

docker --version

sudo aa-status

## How to Reproduce

Build the hardened image:

docker build -t hardened-python-runtime:local .

Run the container with security controls:

docker run -d \
  --name hardened-python-runtime \
  -p 8080:8080 \
  --read-only \
  --tmpfs /tmp:rw,noexec,nosuid,size=32m \
  --cap-drop ALL \
  --security-opt no-new-privileges:true \
  --memory 256m \
  --cpus 0.5 \
  --restart unless-stopped \
  hardened-python-runtime:local

Verify non-root execution:

docker exec hardened-python-runtime id

Verify read-only filesystem:

docker exec hardened-python-runtime sh -c 'touch /bin/probe'

Verify writable tmpfs:

docker exec hardened-python-runtime sh -c 'touch /tmp/probe'

Load AppArmor profile:

sudo cp apparmor/docker-hardened-python /etc/apparmor.d/

sudo apparmor_parser -r /etc/apparmor.d/docker-hardened-python

Verify profile status:

sudo aa-status

Run container with AppArmor:

docker run -d \
  --security-opt apparmor=docker-hardened-python \
  hardened-python-runtime:local

Verify endpoint protection:

curl http://localhost:8080/read-shadow

curl http://localhost:8080/write-proc-sys

Deploy local registry:

docker run -d \
  --name local-secure-registry \
  -p 5000:5000 \
  registry:2

Push image:

docker tag hardened-python-runtime:local localhost:5000/hardened-python-runtime:1.0.0

docker push localhost:5000/hardened-python-runtime:1.0.0

## Tools Used

- Docker
- AppArmor
- Linux Capabilities
- Python
- HTTPServer
- Registry v2
- Bash
- Linux
- jq
- Git
- tree

## Key Skills Demonstrated

- Container hardening
- Linux privilege reduction
- Mandatory access control
- AppArmor policy design
- Non-root container execution
- Read-only filesystem enforcement
- Runtime capability management
- Container security validation
- Resource governance
- Private registry deployment
- Security evidence collection
- Defense-in-depth architecture

## Real-World Use Case

Organizations running workloads in Docker, Kubernetes, OpenShift, Amazon ECS, Azure Container Apps, or managed Kubernetes platforms must assume containers may eventually be compromised. A hardened deployment reduces attacker options by restricting filesystem access, removing Linux capabilities, enforcing mandatory access control policies, limiting available resources, and preventing privilege escalation. These controls are commonly required in regulated environments, security-sensitive workloads, and enterprise platform engineering teams.

## Lessons Learned

- Running containers as root remains one of the most common container security mistakes.
- Read-only filesystems significantly reduce attacker persistence opportunities.
- AppArmor provides meaningful containment even after application compromise.
- Linux capabilities should be removed unless explicitly required.
- Security controls must be verified through inspection and testing rather than assumptions.
- Private registries improve control over image distribution and provenance.

## Troubleshooting Log

Issue:
The lab instructions used a hardcoded Ubuntu jammy repository while the environment used Ubuntu noble.

Resolution:
Generated the Docker repository configuration dynamically from the operating system codename.

Issue:
Docker CE installation may fail when repository configuration or GPG keys are missing.

Resolution:
Validated repository configuration and Docker package availability before installation.

Issue:
Container runtime evidence files were initially verified from the wrong directory.

Resolution:
Verified files from the actual workspace path and tracked them throughout execution.

Issue:
Docker Content Trust was expected to work with only a registry:2 container.

Resolution:
Documented that a registry alone does not provide the Notary trust service required by classic Docker Content Trust workflows.

Issue:
Containers can regain privileges through inherited capabilities.

Resolution:
Dropped all capabilities and enabled no-new-privileges enforcement.

Issue:
Applications frequently require temporary writable storage.

Resolution:
Provided a constrained tmpfs mount while keeping the root filesystem read-only.

Issue:
AppArmor policy violations can be difficult to verify.

Resolution:
Implemented dedicated validation endpoints and captured AppArmor audit evidence from kernel logs.
