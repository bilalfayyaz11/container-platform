# Docker Swarm Secret Management

## What This Does

This implementation demonstrates secure secret management for containerized services using Docker Swarm.

The system creates Docker secrets from both standard input and source files, mounts them into services as protected files, rotates secrets through service updates, and verifies that sensitive values are not exposed through logs or regular environment variables.

This pattern is used in production container platforms to protect database passwords, API keys, connection settings, and application credentials without committing plaintext secrets into source control.

## Architecture

    +--------------------------------------+
    | Docker Swarm Manager Node            |
    | Secret Store                         |
    | Encrypted Swarm Metadata             |
    +------------------+-------------------+
                       |
                       v
    +--------------------------------------+
    | Docker Secrets                       |
    | db_username                          |
    | db_password                          |
    | db_config                            |
    | api_key                              |
    | api_key_v2                           |
    | db_password_v2                       |
    +------------------+-------------------+
                       |
        +--------------+--------------+
        |                             |
        v                             v

+---------------------------+   +---------------------------+
| MySQL Service             |   | Web Application Service    |
| mysql_db                  |   | web_app                    |
| /run/secrets/db_username  |   | /run/secrets/db_username   |
| /run/secrets/db_password  |   | /run/secrets/db_password   |
| MYSQL_*_FILE variables    |   | /run/secrets/api_key       |
+---------------------------+   +---------------------------+
                                      |
                                      v
                              +---------------------------+
                              | Scaled Replicas           |
                              | Secret Distribution       |
                              | Secret Rotation           |
                              +---------------------------+

        +----------------------------------------------+
        | Custom Application Service                    |
        | custom_app                                    |
        | /app/config/database.json                     |
        | /app/keys/api.key                             |
        +----------------------------------------------+

## Prerequisites

- Ubuntu 24.04
- Docker Engine
- Docker Swarm mode
- Git
- tree
- jq
- sudo privileges
- Internet access for pulling container images

## Setup & Installation

sudo apt-get update

sudo apt-get install -y ca-certificates curl gnupg git tree jq

sudo install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

sudo chmod a+r /etc/apt/keyrings/docker.gpg

. /etc/os-release

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${VERSION_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl enable docker

sudo systemctl start docker

sudo docker --version

## How to Reproduce

Initialize Docker Swarm:

sudo docker swarm init

Verify manager node status:

sudo docker node ls

Create base secrets:

printf "mySecretPassword123" | sudo docker secret create db_password -

printf "admin_user" | sudo docker secret create db_username -

List secrets:

sudo docker secret ls

Deploy MySQL using secret files:

sudo docker service create \
  --name mysql_db \
  --secret db_username \
  --secret db_password \
  --env MYSQL_ROOT_PASSWORD_FILE=/run/secrets/db_password \
  --env MYSQL_USER_FILE=/run/secrets/db_username \
  --env MYSQL_PASSWORD_FILE=/run/secrets/db_password \
  --env MYSQL_DATABASE=testdb \
  --publish 3306:3306 \
  mysql:8.0

Create file-based secrets:

mkdir -p secret-source-files

cat > secret-source-files/db_config.json << 'CONFIG'
{
  "host": "mysql_db",
  "port": 3306,
  "database": "testdb",
  "ssl_mode": "required",
  "connection_timeout": 30
}
CONFIG

printf "api_key_abc123xyz789" > secret-source-files/api_key.txt

sudo docker secret create db_config secret-source-files/db_config.json

sudo docker secret create api_key secret-source-files/api_key.txt

Deploy a service with multiple secrets:

sudo docker service create \
  --name web_app \
  --secret db_username \
  --secret db_password \
  --secret db_config \
  --secret api_key \
  --env DB_USERNAME_FILE=/run/secrets/db_username \
  --env DB_PASSWORD_FILE=/run/secrets/db_password \
  --env DB_CONFIG_FILE=/run/secrets/db_config \
  --env API_KEY_FILE=/run/secrets/api_key \
  --publish 8080:80 \
  nginx:1.27-alpine

Scale the service:

sudo docker service scale web_app=3

Rotate an API key secret:

printf "api_key_new_version_456" | sudo docker secret create api_key_v2 -

sudo docker service update \
  --secret-rm api_key \
  --secret-add api_key_v2 \
  web_app

Verify secrets are not exposed in logs:

sudo docker service logs web_app

Verify unassigned containers cannot access secrets:

sudo docker run --rm alpine:3.20 ls -la /run/secrets/ 2>/dev/null || echo "No secrets accessible from unassigned container"

Clean up services:

sudo docker service rm web_app custom_app mysql_db

## Tools Used

- Docker Engine
- Docker Swarm
- Docker Secrets
- MySQL
- Nginx
- Alpine Linux
- Ubuntu Linux
- Bash
- jq
- tree
- Git

## Key Skills Demonstrated

- Docker Swarm initialization
- Secure secret creation
- File-based secret management
- Runtime secret injection
- Service-level secret assignment
- Least-privilege secret access
- MySQL credential loading through secret files
- Multi-replica secret distribution
- Custom secret mount paths
- Secret rotation through immutable versions
- Service updates with secret replacement
- Secret exposure verification
- Container security auditing
- Production credential handling

## Real-World Use Case

A platform engineering or DevSecOps team can use this pattern to distribute database credentials, API keys, certificates, and application configuration to containerized workloads without storing secrets in Git repositories, Compose files, or environment variables. Docker Swarm secrets reduce credential exposure by mounting sensitive values as protected files only inside assigned services, making them useful for production services that require controlled access to sensitive runtime data.

## Lessons Learned

- Docker secrets require Swarm mode and are attached to services rather than ordinary standalone containers.
- Secret values are not shown through docker secret inspect, which protects accidental disclosure.
- The safest pattern for database credentials is using *_FILE environment variables that point to mounted secret files.
- Docker secrets are immutable, so rotation is handled by creating a new secret version and updating services.
- Unassigned containers cannot read Swarm secrets, which enforces service-level access control.

## Troubleshooting Log

Issue:
Docker was not installed in the fresh Ubuntu 24.04 environment.

Resolution:
Installed Docker Engine from the official Docker repository for the active Ubuntu codename.

Issue:
Docker group permissions can fail in active SSH sessions.

Resolution:
Used sudo docker commands throughout the workflow to avoid group refresh problems.

Issue:
The original instructions assumed secrets could be deleted immediately.

Resolution:
Removed services first because Docker secrets cannot be deleted while still attached to active services.

Issue:
The original log verification searched for the generic word password.

Resolution:
Checked for actual raw secret values to avoid false positives from normal MySQL log messages.

Issue:
Docker secrets cannot be edited in place.

Resolution:
Created versioned replacement secrets and updated services to consume the new versions.

Issue:
Standalone containers cannot access Swarm secrets.

Resolution:
Verified that an unassigned Alpine container had no access to /run/secrets.
