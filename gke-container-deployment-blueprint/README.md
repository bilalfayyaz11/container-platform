# Google Kubernetes Engine Container Deployment Blueprint

## What This Does

This implementation provides a cloud-native container deployment blueprint for running a Dockerized Node.js application on Google Kubernetes Engine using production-style Kubernetes manifests, health checks, resource limits, external service exposure, and Artifact Registry deployment automation.

The environment validates the full application lifecycle locally with Docker, then prepares the Kubernetes and Google Cloud deployment workflow needed to publish the image, deploy it to GKE, expose it through a LoadBalancer service, and operate it with rolling updates.

The live GKE provisioning phase was blocked by Google Cloud project permissions, so this implementation includes a complete permission analysis report and deployable infrastructure artifacts that can run unchanged once the required IAM, billing, and API access are available.

## Architecture

    +--------------------------------------------------+
    | Local Ubuntu Runtime                             |
    | Docker + Node.js + Google Cloud CLI              |
    +----------------------+---------------------------+
                           |
                           v
    +--------------------------------------------------+
    | Containerized Application                        |
    | Node.js Express API                              |
    | / endpoint                                       |
    | /health endpoint                                 |
    +----------------------+---------------------------+
                           |
                           v
    +--------------------------------------------------+
    | Docker Image                                     |
    | node:20-alpine                                   |
    | Non-root runtime user                            |
    | Version: gke-container-runtime:v1.0              |
    +----------------------+---------------------------+
                           |
                           v
    +--------------------------------------------------+
    | Google Cloud Deployment Path                     |
    | Artifact Registry                                |
    | GKE Cluster                                      |
    | Kubernetes Deployment                            |
    | Kubernetes LoadBalancer Service                  |
    +----------------------+---------------------------+
                           |
                           v
    +--------------------------------------------------+
    | Kubernetes Runtime Controls                      |
    | Replicas                                         |
    | Health probes                                    |
    | CPU and memory limits                            |
    | Non-root pod security context                    |
    | Read-only root filesystem                        |
    +--------------------------------------------------+

## Prerequisites

- Ubuntu 24.04
- Docker Engine
- Google Cloud CLI
- GKE gcloud auth plugin
- kubectl
- Node.js
- npm
- jq
- curl
- Git
- tree
- Google Cloud project with billing enabled
- IAM permissions for GKE, Artifact Registry, Compute Engine, Service Usage, and IAM APIs

## Setup & Installation

sudo apt-get update -y

sudo apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg \
  lsb-release \
  git \
  jq \
  tree \
  nodejs \
  npm

sudo install -m 0755 -d /usr/share/keyrings

curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg \
  | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg

echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
  | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list >/dev/null

sudo apt-get update -y

sudo apt-get install -y \
  google-cloud-cli \
  google-cloud-cli-gke-gcloud-auth-plugin \
  kubectl

export USE_GKE_GCLOUD_AUTH_PLUGIN=True

gcloud auth login --no-launch-browser

## How to Reproduce

Create the working directory:

mkdir -p ~/gke-container-platform/{app,k8s,reports,scripts}

cd ~/gke-container-platform

Build the local container image:

cd app

npm install --package-lock-only

docker build -t gke-container-runtime:v1.0 .

Run and test the container locally:

docker run -d \
  --name gke-container-runtime-test \
  -p 8080:8080 \
  gke-container-runtime:v1.0

curl http://localhost:8080

curl http://localhost:8080/health

docker rm -f gke-container-runtime-test

Create a Google Cloud repository and deploy when permissions are available:

export PROJECT_ID="your-google-cloud-project"
export REGION="us-central1"
export ZONE="us-central1-a"
export REPOSITORY="container-runtime"
export CLUSTER_NAME="container-platform-gke"

./scripts/deploy-to-gke.sh

The deployment script performs the following actions:

- Creates an Artifact Registry Docker repository
- Configures Docker authentication for Artifact Registry
- Tags and pushes the local image
- Retrieves GKE cluster credentials
- Applies the Kubernetes Deployment manifest
- Applies the Kubernetes LoadBalancer Service manifest
- Waits for rollout completion
- Prints pod and service status

## Tools Used

- Docker
- Google Cloud CLI
- Google Kubernetes Engine
- Artifact Registry
- Kubernetes
- kubectl
- Node.js
- npm
- Express
- Bash
- jq
- Linux
- Git
- tree

## Key Skills Demonstrated

- Cloud-native container deployment planning
- Docker image creation and local validation
- Kubernetes Deployment and Service authoring
- GKE deployment automation
- Artifact Registry migration from legacy registry workflows
- Health probe implementation
- Resource request and limit configuration
- Non-root container runtime design
- Kubernetes security context configuration
- Cloud IAM blocker diagnosis
- Evidence-driven troubleshooting
- Production deployment documentation

## Real-World Use Case

A platform engineering team can use this pattern to move a containerized web service from local development into a managed Kubernetes platform on Google Cloud. The same workflow applies to internal developer platforms, staging environments, production GKE clusters, and cloud migration efforts where applications need repeatable builds, registry publishing, Kubernetes manifests, external exposure, and operational readiness checks.

## Lessons Learned

- Google Cloud CLI is not always preinstalled in fresh environments, even when documentation says the environment is ready.
- Google Container Registry workflows should be modernized to Artifact Registry for current production deployments.
- GKE cluster provisioning depends on project existence, billing, IAM permissions, API enablement, and Compute Engine access.
- kubectl defaults to localhost:8080 when no valid cluster context exists, which usually means credential retrieval failed.
- npm ci requires a package-lock.json file; without it, npm install --package-lock-only must be run first.
- Deployment artifacts can still be valuable when cloud permissions are blocked if the blocker is documented clearly and the workflow remains reproducible.

## Troubleshooting Log

Issue:
The environment did not include gcloud even though the original instructions claimed Google Cloud SDK was preinstalled.

Resolution:
Installed google-cloud-cli, google-cloud-cli-gke-gcloud-auth-plugin, and kubectl from Google Cloud's APT repository.

Issue:
The original workflow used Google Container Registry through gcr.io.

Resolution:
Modernized the workflow to use Artifact Registry with us-central1-docker.pkg.dev because Artifact Registry is the current Google Cloud container registry path.

Issue:
The generated Google Cloud project could not be accessed.

Resolution:
Captured the permission failure in reports/gcp-permission-blocker.txt and documented the missing IAM and project access requirements.

Issue:
GKE API checks failed with project not found or permission denied.

Resolution:
Stopped cluster provisioning attempts and switched to local Docker validation plus deployable Kubernetes/GKE artifacts.

Issue:
kubectl returned localhost:8080 connection refused.

Resolution:
Identified this as a missing cluster context caused by failed gcloud container clusters get-credentials.

Issue:
npm ci failed because package-lock.json did not exist.

Resolution:
Generated package-lock.json with npm install --package-lock-only before rebuilding the image.

Issue:
The Docker image did not exist after the failed npm ci build.

Resolution:
Rebuilt the image after generating the lockfile, then reran the local container validation successfully.
