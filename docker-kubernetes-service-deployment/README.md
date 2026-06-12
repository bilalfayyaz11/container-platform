# Docker Kubernetes Service Deployment

## What This Does

This implementation builds a Flask web application, packages it into a Docker image, and deploys it onto a local Kubernetes cluster using Minikube.

The application is exposed through a Kubernetes NodePort Service and includes health endpoints, readiness probes, liveness probes, resource requests, CPU limits, and a scalable Deployment with three replicas.

This demonstrates the core container-to-orchestration workflow used by platform engineering, DevOps, SRE, and cloud infrastructure teams to move an application from local code to managed runtime infrastructure.

## Architecture

    +-----------------------------+
    | Flask Web Application       |
    | app/app.py                  |
    | / and /health endpoints     |
    +-------------+---------------+
                  |
                  v
    +-----------------------------+
    | Docker Image Build Layer    |
    | Dockerfile                  |
    | python:3.12-slim            |
    | webapp-k8s:v1.0             |
    +-------------+---------------+
                  |
                  v
    +-----------------------------+
    | Minikube Docker Runtime     |
    | Local image availability    |
    | imagePullPolicy: Never      |
    +-------------+---------------+
                  |
                  v
    +-----------------------------+
    | Kubernetes Workload Layer   |
    | Pod + Deployment            |
    | 3 replicas                  |
    | Health probes               |
    | Resource controls           |
    +-------------+---------------+
                  |
                  v
    +-----------------------------+
    | Kubernetes Service Layer    |
    | NodePort Service            |
    | Port 80 -> Target 5000      |
    | NodePort 30080              |
    +-------------+---------------+
                  |
                  v
    +-----------------------------+
    | External Access             |
    | Minikube IP + NodePort      |
    | Browser / curl access       |
    +-----------------------------+

## Prerequisites

- Ubuntu 24.04
- Docker Engine
- kubectl
- Minikube
- curl
- Git
- tree
- Internet access for pulling base images and Kubernetes utility images

## Setup & Installation

sudo apt update

sudo apt install -y docker.io tree conntrack socat curl git

sudo systemctl enable --now docker

sudo usermod -aG docker $USER

curl -LO "https://dl.k8s.io/release/stable.txt"

KUBECTL_VERSION=$(cat stable.txt)

curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"

chmod +x kubectl

sudo mv kubectl /usr/local/bin/

curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

sudo install minikube-linux-amd64 /usr/local/bin/minikube

rm -f stable.txt minikube-linux-amd64

newgrp docker

## How to Reproduce

Start the local Kubernetes cluster:

minikube start --driver=docker

Configure Docker to build images inside Minikube:

eval $(minikube docker-env)

Build the application image:

docker build -t webapp-k8s:v1.0 .

Deploy the standalone Pod:

kubectl apply -f webapp-pod.yaml

Wait for the Pod to become ready:

kubectl wait --for=condition=Ready pod/webapp-pod --timeout=90s

Deploy the NodePort Service:

kubectl apply -f webapp-service.yaml

Get the service URL:

minikube service webapp-service --url

Test the application:

curl -s $(minikube service webapp-service --url)

Test the health endpoint:

curl -s $(minikube service webapp-service --url)/health

Deploy the scalable workload:

kubectl apply -f webapp-deployment.yaml

Verify rollout status:

kubectl rollout status deployment/webapp-deployment --timeout=120s

Verify replicas:

kubectl get pods -l app=webapp -o wide

Run repeated service tests:

for i in {1..10}; do curl -s $(minikube service webapp-service --url)/health; echo; done

## Tools Used

- Docker
- Kubernetes
- Minikube
- kubectl
- Python 3.12
- Flask
- Werkzeug
- YAML
- Bash
- curl
- tree
- Git

## Key Skills Demonstrated

- Docker image creation for Python web services
- Kubernetes Pod deployment
- Kubernetes Deployment configuration
- Kubernetes NodePort Service exposure
- Local Kubernetes cluster operation with Minikube
- Health endpoint implementation
- Liveness and readiness probe configuration
- CPU and memory resource control
- Service-to-Pod traffic routing
- Container image troubleshooting
- Kubernetes workload debugging
- Platform engineering deployment workflow

## Real-World Use Case

Engineering teams use this workflow when packaging internal tools, APIs, dashboards, and microservices into containers before deploying them to Kubernetes environments. In production, the same pattern can be extended to managed Kubernetes platforms such as Amazon EKS, Azure AKS, or Google GKE, with image storage handled by a private registry and traffic routed through ingress controllers, service meshes, or cloud load balancers.

## Lessons Learned

- Building directly inside the Minikube Docker daemon avoids unnecessary registry authentication during local Kubernetes testing.
- A standalone Pod is useful for learning, but a Deployment is the better production pattern because it manages replicas and recovery.
- NodePort Services provide a simple way to expose applications during local cluster validation.
- Minimal container images reduce size but may not include troubleshooting tools such as curl.
- Kubernetes Services route traffic using labels, so label design directly affects which Pods receive traffic.

## Troubleshooting Log

Issue:
Docker, kubectl, Minikube, and tree were missing from the fresh Ubuntu environment.

Resolution:
Installed Docker and tree through apt, then installed kubectl and Minikube using current official Linux binaries.

Issue:
Snap-based Docker and kubectl installation options were shown by Ubuntu, but Snap can create permission and path issues in temporary cloud terminals.

Resolution:
Used apt for Docker and official binaries for kubectl and Minikube.

Issue:
The original container test failed when Docker was pointed at the Minikube Docker daemon because localhost port mapping was not exposed on the Ubuntu host.

Resolution:
Switched back to the host Docker daemon for local container testing, then switched again to the Minikube Docker daemon for Kubernetes image availability.

Issue:
The application container did not include curl because it used a minimal Python slim base image.

Resolution:
Used a temporary curl container and direct Pod IP testing instead of expecting curl to exist inside the application image.

Issue:
The first temporary DNS test used the Pod name as if it were a stable service DNS name.

Resolution:
Validated the application through the Pod IP first, then exposed it correctly through a Kubernetes Service.

Issue:
The original registry workflow could fail because Docker Hub login and image push are not required for Minikube-local execution.

Resolution:
Used imagePullPolicy: Never and built the image directly inside Minikube’s Docker daemon.

Issue:
Kubernetes v1.33+ warns that direct Endpoints output is deprecated.

Resolution:
Documented EndpointSlice as the modern Kubernetes discovery resource for future inspection.
