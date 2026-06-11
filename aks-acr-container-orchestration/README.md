
# Azure Kubernetes Service Container Platform

## What This Does

This implementation demonstrates a complete cloud-native application deployment workflow using Azure Kubernetes Service (AKS), Azure Container Registry (ACR), Docker, and Kubernetes.

A Node.js web application is containerized, stored in a private Azure Container Registry, deployed to a managed Kubernetes cluster, exposed through an Azure Load Balancer, and configured for horizontal scaling and monitoring.

The deployment follows modern container platform engineering practices including image registry integration, health probes, resource constraints, autoscaling, and observability.

This architecture represents a common production deployment pattern used by Platform Engineering, DevOps, Cloud Engineering, and Site Reliability Engineering teams.

## Architecture

```text
+-------------------------------------------------------------+
| Azure Container Registry (ACR)                              |
| container-platform-api:v1                                   |
+---------------------------+---------------------------------+
                            |
                            v
+-------------------------------------------------------------+
| Azure Kubernetes Service (AKS)                              |
|                                                             |
|  +-----------------------------------------------------+    |
|  | Deployment: container-platform-api                  |    |
|  | Replicas: 3 -> 5 -> Autoscaling                     |    |
|  +----------------------+----------------------------+     |
|                         |                                 |
|      +------------------+------------------+             |
|      |                  |                  |             |
|      v                  v                  v             |
| +----------+      +----------+      +----------+         |
| |  Pod 1   |      |  Pod 2   |      |  Pod 3   |         |
| +----------+      +----------+      +----------+         |
|                                                         |
+----------------------+----------------------------------+
                       |
                       v
+---------------------------------------------------------+
| Kubernetes Service (LoadBalancer)                       |
+----------------------+----------------------------------+
                       |
                       v
+---------------------------------------------------------+
| Azure Load Balancer                                     |
+----------------------+----------------------------------+
                       |
                       v
+---------------------------------------------------------+
| Internet Users                                          |
+---------------------------------------------------------+
```

## Prerequisites

* Azure Subscription
* Azure CLI
* Docker Engine
* Kubernetes CLI (kubectl)
* Git
* Ubuntu 24.04 LTS or compatible Linux distribution
* AKS permissions within Azure subscription

## Setup & Installation

```bash
sudo apt update

sudo apt install -y docker.io git curl jq tree

curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

az aks install-cli

sudo systemctl enable --now docker

sudo usermod -aG docker \$USER

newgrp docker
```

## How to Reproduce

Authenticate with Azure:

```bash
az login
```

Create Azure Container Registry:

```bash
az acr create \
  --resource-group container-platform-rg \
  --name <registry-name> \
  --sku Basic
```

Create AKS Cluster:

```bash
az aks create \
  --resource-group container-platform-rg \
  --name container-platform-aks \
  --node-count 2 \
  --node-vm-size Standard_D2s_v3
```

Build Docker Image:

```bash
docker build -t container-platform-api:v1 .
```

Push Image to ACR:

```bash
docker tag container-platform-api:v1 <acr-login-server>/container-platform-api:v1

docker push <acr-login-server>/container-platform-api:v1
```

Deploy to Kubernetes:

```bash
kubectl apply -f deployment.yaml
```

Expose via Load Balancer:

```bash
kubectl apply -f service.yaml
```

Scale Deployment:

```bash
kubectl scale deployment container-platform-api --replicas=5
```

Configure Autoscaling:

```bash
kubectl autoscale deployment container-platform-api \
  --cpu-percent=70 \
  --min=3 \
  --max=10
```

## Tools Used

* Azure Kubernetes Service (AKS)
* Azure Container Registry (ACR)
* Azure Load Balancer
* Azure Monitor
* Docker
* Kubernetes
* kubectl
* Node.js
* Express.js
* Linux
* Git

## Key Skills Demonstrated

* Kubernetes cluster provisioning
* Container image lifecycle management
* Azure Container Registry integration
* AKS workload deployment
* Kubernetes Deployments
* Kubernetes Services
* Load Balancer configuration
* Horizontal Pod Autoscaling
* Health Probes
* Container security hardening
* Production deployment validation
* Cloud-native operations

## Real-World Use Case

Organizations running customer-facing APIs, SaaS platforms, internal business applications, and microservices frequently deploy workloads using Kubernetes. This architecture provides a repeatable and scalable deployment model that supports high availability, fault tolerance, automated scaling, and centralized operations management.

Platform Engineering teams use similar patterns to deploy hundreds of services across production environments while maintaining operational consistency.

## Lessons Learned

* Azure subscriptions may require provider registration before AKS deployment.
* AKS node sizes can be restricted by subscription-level quotas and policies.
* Container images should be validated locally before deployment.
* Kubernetes health probes significantly improve workload reliability.
* Autoscaling and monitoring should be configured early in the deployment lifecycle.

## Troubleshooting Log

Issue:
Microsoft.ContainerService provider was not registered.

Resolution:
Registered the required Azure resource providers before AKS creation.

Issue:
Standard_B2s VM size was blocked by Azure subscription policy.

Resolution:
Replaced Standard_B2s with Standard_D2s_v3.

Issue:
Docker socket permission denied.

Resolution:
Added the user to the docker group and activated the group session.

Issue:
Node 16 base image was outdated.

Resolution:
Upgraded to node:24-alpine.

Issue:
npm install --production used legacy behavior.

Resolution:
Replaced with npm install --omit=dev.

Issue:
kubectl get componentstatuses is deprecated.

Resolution:
Used Kubernetes readiness endpoints and node health validation instead.

Issue:
External IP assignment required waiting for Azure Load Balancer provisioning.

Resolution:
Implemented automated polling instead of manual watch commands.
