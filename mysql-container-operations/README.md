# MySQL Container Operations and Data Persistence

## What This Does

This implementation demonstrates production-oriented MySQL database operations using Docker containers. The environment provisions a containerized MySQL server, configures custom networking, initializes database schemas, performs backup and restore operations, validates persistent storage, and captures operational evidence.

The solution showcases how stateful workloads can safely operate inside containers while maintaining data durability through Docker volumes. It also demonstrates database administration, health monitoring, backup validation, and disaster recovery procedures.

These capabilities are essential for Platform Engineering, DevOps, Site Reliability Engineering, Cloud Infrastructure, and Database Operations teams responsible for running containerized database platforms.

## Architecture

    +--------------------------------------------------+
    | Docker Host                                      |
    +----------------------+---------------------------+
                           |
                           v
    +--------------------------------------------------+
    | Docker Network                                   |
    | mysql-network                                    |
    +----------------------+---------------------------+
                           |
                           v
    +--------------------------------------------------+
    | MySQL Container                                  |
    | mysql-restored                                   |
    | Port 3306                                        |
    +----------------------+---------------------------+
                           |
             +-------------+-------------+
             |                           |
             v                           v

    +-------------------+     +------------------------+
    | Persistent Volume |     | Backup Storage         |
    | mysql-data        |     | backups/*.sql          |
    +-------------------+     +------------------------+

                           |
                           v

    +--------------------------------------------------+
    | Evidence Collection                              |
    | Monitoring, Queries, Restore Validation          |
    +--------------------------------------------------+

## Prerequisites

- Ubuntu 24.04 LTS
- Docker Engine
- Docker Compose Plugin
- MySQL 8.0 Container Image
- Git
- curl
- tree
- net-tools

## Setup & Installation

Install Docker:

sudo apt update

sudo apt install -y ca-certificates curl gnupg git tree net-tools

sudo install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
| sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
| sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update

sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl enable --now docker

## How to Reproduce

Pull MySQL image:

docker pull mysql:8.0

Create network:

docker network create mysql-network

Deploy database:

docker run --name mysql-server \
--network mysql-network \
-e MYSQL_ROOT_PASSWORD=SecurePass123 \
-e MYSQL_DATABASE=company_db \
-e MYSQL_USER=app_user \
-e MYSQL_PASSWORD=AppPass456 \
-p 3306:3306 \
-d mysql:8.0

Initialize schema:

docker cp init-schema.sql mysql-server:/tmp/init-schema.sql

docker exec mysql-server mysql \
-u root \
-pSecurePass123 \
-e "source /tmp/init-schema.sql"

Create backup:

docker exec mysql-server mysqldump \
-u root \
-pSecurePass123 \
company_db > company-db-backup.sql

Restore backup:

docker exec -i mysql-server mysql \
-u root \
-pSecurePass123 \
company_db < company-db-backup.sql

## Tools Used

- Docker
- Docker Networking
- Docker Volumes
- MySQL 8.0
- MySQL Client
- mysqldump
- Linux
- Bash
- Git

## Key Skills Demonstrated

- Containerized database deployment
- Docker networking
- Persistent storage management
- MySQL administration
- Schema initialization
- SQL data validation
- Backup creation
- Backup restoration
- Disaster recovery validation
- Database monitoring
- Container health verification
- Infrastructure troubleshooting

## Real-World Use Case

Organizations increasingly run databases inside containerized environments for development, testing, and controlled production workloads. Platform and DevOps teams must ensure databases remain recoverable, observable, and resilient even when containers are recreated or migrated.

This implementation demonstrates core operational procedures including initialization, backup management, persistence validation, and recovery testing that are commonly required for managed database services and internal platform engineering environments.

## Lessons Learned

- Database containers require persistent volumes to prevent data loss.
- Backup validation is as important as backup creation.
- Container recreation should never impact stored data when volumes are configured correctly.
- Operational monitoring provides early warning of performance or availability issues.
- Restore testing should be performed regularly to verify recovery readiness.

## Troubleshooting Log

Issue:
Docker was not installed in the fresh environment.

Resolution:
Installed Docker Engine and Docker Compose Plugin from the official Docker repository.

Issue:
tree utility was unavailable.

Resolution:
Installed tree through apt.

Issue:
Original backup file path was not generated correctly.

Resolution:
Created backup variables and validated generated backup files before restore operations.

Issue:
Restore containers experienced authentication inconsistencies.

Resolution:
Recreated clean containers and validated restoration using fresh MySQL instances.

Issue:
Original monitoring commands relied on netstat.

Resolution:
Used ss -tlnp for modern Ubuntu 24.04 compatibility.

Issue:
Schema execution could fail on reruns.

Resolution:
Implemented IF NOT EXISTS and duplicate-safe inserts.
