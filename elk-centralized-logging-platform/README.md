# ELK Centralized Logging Platform

## What This Does

This implementation builds a centralized logging and observability platform using Elasticsearch, Logstash, Kibana, and Filebeat running inside Docker containers.

The platform collects logs from multiple containerized applications, processes and enriches log events through Logstash pipelines, stores searchable data in Elasticsearch, and provides visualization and analytics capabilities through Kibana dashboards.

The environment includes multi-service applications, structured log ingestion, GELF logging drivers, container metadata enrichment, index templates, health monitoring, operational validation scripts, and production-style deployment management.

This architecture mirrors how modern DevOps, SRE, Platform Engineering, Cloud Operations, Security Operations, and AIOps teams centralize logs for troubleshooting, monitoring, auditing, and operational intelligence.

## Architecture

    +------------------------------------------------+
    | Application Containers                         |
    | sample-app                                     |
    | nginx-sample                                   |
    | web-frontend                                   |
    | api-backend                                    |
    | database                                       |
    | redis-cache                                    |
    +----------------------+-------------------------+
                           |
                           v
    +------------------------------------------------+
    | GELF Logging Driver                            |
    | Docker Container Logs                          |
    +----------------------+-------------------------+
                           |
                           v
    +------------------------------------------------+
    | Logstash                                       |
    | Parsing                                        |
    | Filtering                                      |
    | Enrichment                                     |
    | Index Routing                                  |
    +----------------------+-------------------------+
                           |
                           v
    +------------------------------------------------+
    | Elasticsearch                                  |
    | Search                                         |
    | Index Storage                                  |
    | Log Analytics                                  |
    +----------------------+-------------------------+
                           |
                           v
    +------------------------------------------------+
    | Kibana                                         |
    | Dashboards                                     |
    | Search                                         |
    | Visualization                                  |
    +------------------------------------------------+

                           ^
                           |
    +------------------------------------------------+
    | Filebeat                                       |
    | Docker Log Collection                          |
    | Container Metadata Enrichment                  |
    +------------------------------------------------+

## Prerequisites

- Ubuntu 24.04
- Docker Engine
- Docker Compose v2
- curl
- netcat
- Git
- tree
- Minimum 6 GB RAM
- vm.max_map_count configured for Elasticsearch

## Setup & Installation

sudo apt update

sudo apt install -y docker.io docker-compose-v2 tree

sudo systemctl enable --now docker

sudo usermod -aG docker ubuntu

newgrp docker

docker --version

docker compose version

sysctl vm.max_map_count

free -h

## How to Reproduce

Create the working directory:

mkdir -p ~/elk-centralized-logging-platform

cd ~/elk-centralized-logging-platform

Validate the Docker Compose configuration:

docker compose config

Start the ELK stack:

docker compose up -d

Verify container health:

docker compose ps

Verify Elasticsearch:

curl http://localhost:9200/_cluster/health?pretty

Verify Kibana:

curl http://localhost:5601/api/status

Deploy sample logging applications:

cd sample-app

docker compose -f docker-compose-app.yml up -d --build

Generate application logs:

curl http://localhost:8080/

curl http://localhost:8080/api/data

curl http://localhost:8080/health

Deploy multi-service application:

cd ../multi-service-app

docker compose -f docker-compose-multi.yml up -d --build

Generate multi-service logs:

curl http://localhost:8082/

curl http://localhost:8082/api/users

curl http://localhost:8082/api/orders

Verify Elasticsearch indices:

curl http://localhost:9200/_cat/indices?v

Search indexed logs:

curl "http://localhost:9200/docker-logs-*/_search?pretty&size=5"

Create index templates:

./create-index-template.sh

Validate the stack:

./validate-elk.sh

Monitor platform status:

./manage-elk.sh status

## Tools Used

- Elasticsearch 8.11
- Logstash 8.11
- Kibana 8.11
- Filebeat 8.11
- Docker Engine
- Docker Compose v2
- GELF Logging Driver
- Python Flask
- Nginx
- PostgreSQL
- Redis
- Bash
- curl

## Key Skills Demonstrated

- Centralized logging architecture
- ELK stack deployment
- Elasticsearch administration
- Logstash pipeline creation
- Kibana integration
- Filebeat configuration
- Container log collection
- Structured log processing
- GELF logging drivers
- Index template management
- Operational validation
- Docker observability
- Production logging patterns
- Platform monitoring
- Troubleshooting distributed services

## Real-World Use Case

Modern engineering organizations operate dozens or hundreds of services across containers, virtual machines, and cloud infrastructure. Without centralized logging, troubleshooting requires manually connecting to systems and reviewing scattered logs. An ELK platform aggregates operational data into a searchable system where engineers can identify failures, investigate incidents, analyze traffic patterns, monitor service behavior, detect security events, and accelerate root-cause analysis across the entire platform.

## Lessons Learned

- Elasticsearch requires sufficient memory and properly configured JVM heap sizes.
- vm.max_map_count must be configured correctly before Elasticsearch can operate reliably.
- GELF logging provides a simple method for shipping Docker logs directly into Logstash.
- Container metadata enrichment improves log searchability and troubleshooting efficiency.
- Log ingestion pipelines should be validated before building dashboards and visualizations.
- Production logging systems require both operational monitoring and lifecycle management.

## Troubleshooting Log

Issue:
Docker was missing from the fresh Ubuntu 24.04 environment.

Resolution:
Installed docker.io and docker-compose-v2 before building the platform.

Issue:
ELK stack memory requirements exceeded typical training environment defaults.

Resolution:
Reduced Elasticsearch JVM heap allocation from 1–2 GB to 512 MB for reliable execution on a 7.7 GB host.

Issue:
Elasticsearch data volume permissions can prevent successful startup.

Resolution:
Assigned ownership using:
sudo chown -R 1000:0 data/elasticsearch

Issue:
The lab referenced legacy docker-compose commands.

Resolution:
Replaced all commands with Docker Compose v2 syntax using docker compose.

Issue:
A duplicate GELF listener would have created a UDP port conflict on 12201.

Resolution:
Removed the redundant forwarder and routed logs directly into the primary Logstash GELF input.

Issue:
The original index template referenced lifecycle management settings without an ILM policy.

Resolution:
Removed lifecycle references to provide clean template deployment and validation.

Issue:
Kibana startup timing may exceed default expectations.

Resolution:
Added explicit wait loops and service validation before continuing with application deployments.
