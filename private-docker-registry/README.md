# Private Docker Registry

## What This Does

This implementation builds a secure private Docker registry for storing, distributing, and managing container images inside a controlled infrastructure environment.

The registry starts with basic image push and pull validation, then adds TLS encryption, HTTP basic authentication, Docker client trust configuration, registry API inspection, backup procedures, monitoring scripts, and final operational verification.

This platform gives engineering teams a private alternative to public container registries, reducing external dependency risk while improving control over internal image distribution.

Private registries are commonly used by DevOps, Platform Engineering, Cloud Infrastructure, and Security Engineering teams to manage proprietary application images, enforce access control, and support secure deployment pipelines.

## Architecture

    +--------------------------------------+
    | Docker Client                        |
    | docker login / push / pull           |
    +------------------+-------------------+
                       |
                       v
    +--------------------------------------+
    | TLS + Authentication Layer           |
    | Self-Signed Certificate              |
    | htpasswd Basic Auth                  |
    +------------------+-------------------+
                       |
                       v
    +--------------------------------------+
    | Private Docker Registry              |
    | registry:2                           |
    | Port 5000                            |
    | Registry API v2                      |
    +------------------+-------------------+
                       |
                       v
    +--------------------------------------+
    | Persistent Registry Storage          |
    | /opt/docker-registry/data            |
    | Image Blobs                          |
    | Manifests                            |
    | Tags                                 |
    +------------------+-------------------+
                       |
                       v
    +--------------------------------------+
    | Operations Layer                     |
    | Monitoring                           |
    | Backup                               |
    | API Testing                          |
    | Final Verification                   |
    +--------------------------------------+

## Prerequisites

- Ubuntu 24.04
- Docker Engine
- Docker Compose Plugin
- OpenSSL
- curl
- jq
- apache2-utils
- net-tools
- sysstat
- Git
- sudo privileges
- Internet access for pulling public base images

## Setup & Installation

sudo apt-get update

sudo apt-get install -y ca-certificates curl gnupg git tree jq apache2-utils net-tools sysstat openssl

sudo install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

sudo chmod a+r /etc/apt/keyrings/docker.gpg

. /etc/os-release

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${VERSION_CODENAME} stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl enable docker

sudo systemctl start docker

sudo docker --version

sudo docker compose version

## How to Reproduce

Create registry directories:

sudo mkdir -p /opt/docker-registry/data

sudo mkdir -p /opt/docker-registry/certs

sudo mkdir -p /opt/docker-registry/auth

sudo mkdir -p /opt/docker-registry/backups

sudo chown -R ubuntu:ubuntu /opt/docker-registry

Generate a SAN-enabled self-signed certificate:

cd /opt/docker-registry/certs

openssl genrsa -traditional -out domain.key 4096

openssl req -new -key domain.key -out domain.csr -config openssl-san.cnf

openssl x509 -req -days 365 \
  -in domain.csr \
  -signkey domain.key \
  -out domain.crt \
  -extensions v3_req \
  -extfile openssl-san.cnf

Create registry authentication:

htpasswd -Bbn testuser testpass > /opt/docker-registry/auth/htpasswd

Configure Docker client trust:

sudo mkdir -p /etc/docker/certs.d/localhost:5000

sudo cp /opt/docker-registry/certs/domain.crt /etc/docker/certs.d/localhost:5000/ca.crt

sudo systemctl restart docker

Start the secure registry:

sudo docker run -d \
  --name registry-secure \
  --restart=always \
  -p 5000:5000 \
  -v /opt/docker-registry/data:/var/lib/registry \
  -v /opt/docker-registry/certs:/certs \
  -v /opt/docker-registry/auth:/auth \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
  -e REGISTRY_AUTH=htpasswd \
  -e REGISTRY_AUTH_HTPASSWD_REALM="Registry Realm" \
  -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
  registry:2

Login to the registry:

echo "testpass" | sudo docker login localhost:5000 -u testuser --password-stdin

Push an image:

sudo docker pull nginx:1.27-alpine

sudo docker tag nginx:1.27-alpine localhost:5000/my-nginx:v1.0

sudo docker push localhost:5000/my-nginx:v1.0

List registry repositories:

curl -s -k -u testuser:testpass https://localhost:5000/v2/_catalog | jq .

Pull and run from the private registry:

sudo docker pull localhost:5000/my-nginx:v1.0

sudo docker run --rm -p 8080:80 -d --name test-nginx localhost:5000/my-nginx:v1.0

curl http://localhost:8080

sudo docker stop test-nginx

Run final verification:

./final-verification.sh

## Tools Used

- Docker Engine
- Docker Registry v2
- OpenSSL
- htpasswd
- curl
- jq
- Bash
- Linux
- net-tools
- sysstat
- Git

## Key Skills Demonstrated

- Private Docker registry deployment
- TLS-secured registry configuration
- Self-signed certificate generation
- Subject Alternative Name certificate handling
- Docker client certificate trust configuration
- Basic authentication with htpasswd
- Authenticated image push and pull workflows
- Registry API v2 exploration
- Registry storage persistence
- Image tag inspection
- Registry monitoring automation
- Registry backup automation
- Registry troubleshooting
- Docker Content Trust behavior validation
- Container image distribution infrastructure

## Real-World Use Case

A company can use this private registry pattern to host internal container images for application teams, CI/CD systems, and deployment platforms. Instead of relying only on public registries, teams can push approved images into a controlled registry protected by TLS and authentication. This improves supply chain control, supports internal deployment workflows, reduces public registry dependency, and gives platform teams operational ownership over image storage, monitoring, and backup.

## Lessons Learned

- Private registries need persistent storage because registry containers are disposable.
- Modern TLS clients require Subject Alternative Name values instead of relying only on certificate common names.
- Docker Registry v2 uses specific environment variables for TLS configuration, and incorrect variable names can break startup.
- Authenticated push and pull workflows should be tested before adding advanced configuration.
- Registry API checks are useful for validating repositories, tags, and manifests.
- Backup and monitoring scripts make the registry operationally useful beyond a basic container run command.

## Troubleshooting Log

Issue:
Docker was not installed in the fresh Ubuntu 24.04 environment.

Resolution:
Installed Docker Engine from the official Docker repository using the active Ubuntu codename.

Issue:
The original instructions used older assumptions about Ubuntu 20.04.

Resolution:
Used Ubuntu 24.04-compatible package setup and repository configuration.

Issue:
The first secure registry failed because the TLS private key was generated in an unsupported format.

Resolution:
Regenerated the TLS key as a traditional PEM RSA private key and verified it with OpenSSL.

Issue:
The registry container entered a restart loop with the error open : no such file or directory.

Resolution:
Inspected registry logs and found that REGISTRY_HTTP_TLS_PRIVATE_KEY was ignored by the registry image. Replaced it with the correct REGISTRY_HTTP_TLS_KEY variable.

Issue:
Docker login attempted HTTP while the registry was down.

Resolution:
Restarted the registry with correct TLS configuration, verified port 5000 was listening, then retried login.

Issue:
Image push failed with connection refused.

Resolution:
Confirmed the registry was not listening, fixed the crash-loop cause, restarted the registry, and repeated the authenticated push.

Issue:
The original garbage collection command did not mount the registry configuration into the temporary cleanup container.

Resolution:
Created a cleanup script that mounts registry data and the registry configuration file into the garbage-collection container.

Issue:
Self-signed certificates are not trusted globally by default.

Resolution:
Copied the certificate into /etc/docker/certs.d/localhost:5000/ca.crt and restarted Docker.
