# Kubernetes Platform Foundation

## What This Does

This implementation establishes a local Kubernetes environment using Minikube and demonstrates the core building blocks of Kubernetes workload orchestration.

The platform deploys standalone pods, multi-container pods, deployments, ClusterIP services, NodePort services, and LoadBalancer services while validating scaling, self-healing, rolling updates, namespace management, and service discovery.

The environment provides a practical foundation for understanding how Kubernetes manages containerized workloads in production-grade cloud platforms such as Amazon EKS, Azure AKS, and Google GKE.

This work models the operational workflows used by platform engineering, cloud engineering, DevOps, and site reliability engineering teams responsible for containerized infrastructure.

## Architecture

    +--------------------------------------+
    | Minikube Kubernetes Cluster          |
    +------------------+-------------------+
                       |
                       v
    +--------------------------------------+
    | Kubernetes Control Plane             |
    | API Server                           |
    | Scheduler                            |
    | Controller Manager                   |
    +------------------+-------------------+
                       |
                       v
    +--------------------------------------+
    | Worker Node                          |
    | Minikube Node                        |
    +------------------+-------------------+
                       |
      +----------------+----------------+
      |                                 |
      v                                 v

 +--------------+              +------------------+
 | Nginx Pod    |              | Multi-Container  |
 | nginx-pod    |              | Pod              |
 +--------------+              | Nginx + Redis    |
                               +------------------+

                       |
                       v

    +--------------------------------------+
    | Deployment Controller                |
    | nginx-deployment                     |
    | Replica Management                   |
    | Self-Healing                         |
    | Rolling Updates                      |
    +------------------+-------------------+
                       |
                       v

    +--------------------------------------+
    | Services                             |
    | ClusterIP                            |
    | NodePort                             |
    | LoadBalancer                         |
    +--------------------------------------+

## Prerequisites

- Ubuntu 24.04
- Docker Engine
- Docker Compose
- Minikube
- kubectl
- curl
- Internet connectivity
- Minimum 2 CPU cores
- Minimum 4 GB RAM

## Setup & Installation

Install Docker:

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

Install kubectl:

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

Install Minikube:

curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

Start Kubernetes:

minikube start --driver=docker

Verify cluster:

kubectl cluster-info

kubectl get nodes

## How to Reproduce

Start the cluster:

minikube start --driver=docker

Deploy standalone pod:

kubectl apply -f nginx-pod.yaml

Deploy multi-container pod:

kubectl apply -f multi-container-pod.yaml

Deploy application deployment:

kubectl apply -f nginx-deployment.yaml

Create services:

kubectl apply -f nginx-service-clusterip.yaml

kubectl apply -f nginx-service-nodeport.yaml

kubectl apply -f nginx-service-loadbalancer.yaml

Verify resources:

kubectl get all

Scale deployment:

kubectl scale deployment nginx-deployment --replicas=5

Perform rolling update:

kubectl set image deployment/nginx-deployment nginx=nginx:1.25-alpine

Rollback deployment:

kubectl rollout undo deployment/nginx-deployment

## Tools Used

- Kubernetes
- Minikube
- kubectl
- Docker
- Docker Compose
- Nginx
- Redis
- YAML
- Linux
- Bash

## Key Skills Demonstrated

- Kubernetes cluster provisioning
- Kubernetes pod management
- Multi-container pod deployment
- Deployment and replica management
- Kubernetes service networking
- ClusterIP service configuration
- NodePort service exposure
- LoadBalancer service deployment
- Self-healing infrastructure
- Horizontal scaling
- Rolling updates
- Rollback procedures
- Namespace management
- Resource inspection
- kubectl operational workflows
- Service discovery concepts

## Real-World Use Case

Organizations running microservices platforms rely on Kubernetes to automate workload scheduling, scaling, service discovery, and application lifecycle management. The concepts implemented in this environment mirror production workflows used by engineering teams operating Kubernetes clusters in cloud environments. These operational patterns form the foundation for platform engineering, DevOps automation, and container orchestration at scale.

## Lessons Learned

- Deployments provide resilience beyond standalone pods.
- Kubernetes automatically restores desired state when workloads fail.
- Services decouple application access from pod lifecycle events.
- Rolling updates reduce deployment risk while maintaining availability.
- Namespace isolation helps organize workloads across environments.

## Troubleshooting Log

Issue:
Minikube could not communicate with Docker.

Resolution:
Added the user to the Docker group and executed Minikube inside a Docker-enabled group context.

Issue:
Latest image tags introduce deployment unpredictability.

Resolution:
Pinned container image versions for repeatable deployments.

Issue:
kubectl exec with /bin/bash failed in Alpine-based containers.

Resolution:
Used direct command execution compatible with Alpine images.

Issue:
LoadBalancer services require additional networking support in Minikube.

Resolution:
Validated service creation while avoiding blocking tunnel processes during lab execution.

Issue:
Resource metrics may not be available immediately.

Resolution:
Allowed kubectl top commands to fail gracefully when Metrics Server data was unavailable.
