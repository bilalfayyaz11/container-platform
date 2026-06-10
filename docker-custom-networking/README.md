# Docker Custom Network Segmentation and Service Discovery

## What This Does
This implementation demonstrates advanced Docker networking using custom bridge networks, network segmentation, DNS-based service discovery, host networking, and dynamic network troubleshooting. It separates containers into frontend, backend, database, and web application networks to model real microservices communication boundaries. The workflow also validates connectivity, isolation, disconnect/reconnect operations, network inspection, and host-level Docker NAT rules.

## Architecture
+-----------------------------+
| Host Machine                 |
| Docker Engine                |
+-------------+---------------+
              |
              v
+-----------------------------+
| Custom Docker Networks       |
| webapp-network               |
| frontend-network             |
| backend-network              |
| database-network             |
+-------------+---------------+
              |
              v
+-----------------------------+
| Container Placement          |
| web-server + web-client      |
| frontend-app                 |
| app-server                   |
| mysql-db                     |
+-------------+---------------+
              |
              v
+-----------------------------+
| Connectivity Controls        |
| DNS resolution               |
| network isolation            |
| multi-network app-server     |
| disconnect/reconnect testing |
| host networking comparison   |
+-----------------------------+

## Prerequisites
- Ubuntu 24.04 or compatible Linux environment
- Docker Engine installed and running
- tree
- curl
- iptables
- Internet access for pulling container images

## Setup & Installation
sudo apt update
sudo apt install -y docker.io tree curl iptables
sudo systemctl enable --now docker

## How to Reproduce
git clone https://github.com/bilalfayyaz11/container-platform.git
cd container-platform/docker-custom-networking

docker network create --driver bridge webapp-network
docker network create --driver bridge --subnet=172.20.0.0/16 --ip-range=172.20.240.0/20 --gateway=172.20.0.1 backend-network
docker network create frontend-network
docker network create database-network

docker run -d --name web-server --network webapp-network nginx:alpine
docker run -d --name web-client --network webapp-network alpine:latest sleep 3600
docker run -d --name mysql-db --network backend-network -e MYSQL_ROOT_PASSWORD=rootpass -e MYSQL_DATABASE=webapp mysql:8.0
docker run -d --name app-server --network backend-network nginx:alpine
docker network connect frontend-network app-server
docker run -d --name frontend-app --network frontend-network alpine:latest sleep 3600

docker exec web-client apk add --no-cache curl iputils bind-tools
docker exec frontend-app apk add --no-cache curl iputils bind-tools

docker exec web-client ping -c 3 web-server
docker exec web-client curl -s http://web-server
docker exec frontend-app ping -c 3 app-server
docker exec frontend-app ping -c 2 mysql-db || true

docker network inspect webapp-network
docker network inspect backend-network
docker network disconnect frontend-network app-server
docker network connect frontend-network app-server

./cleanup-docker-networking.sh

## Tools Used
- Docker Engine
- Docker CLI
- Docker bridge networks
- Docker host networking
- Nginx
- MySQL
- Alpine Linux
- iptables
- curl
- ping
- nslookup
- tree

## Key Skills Demonstrated
- Custom Docker bridge network creation
- Container network segmentation
- DNS-based container service discovery
- Multi-network container attachment
- Frontend/backend/database network isolation
- Host networking analysis
- Network inspection and IPAM validation
- Docker network disconnect and reconnect troubleshooting
- Docker NAT rule inspection
- Reusable cleanup automation

## Real-World Use Case
This pattern is used when companies deploy microservices that must communicate through controlled network boundaries. A frontend service should not directly reach a database, while an application service may need controlled access to both frontend and backend networks. These Docker networking concepts directly map to Kubernetes Services, NetworkPolicies, service discovery, and cloud-native platform networking.

## Lessons Learned
- User-defined Docker bridge networks provide automatic DNS resolution between containers.
- Containers on separate networks are isolated unless explicitly connected to a shared network.
- A multi-network container can act as a controlled communication bridge between tiers.
- Host networking improves performance but reduces isolation and can create port conflicts.
- Docker network inspection is essential for diagnosing DNS, subnet, gateway, and connectivity issues.

## Troubleshooting Log
- Docker was missing in the fresh Ubuntu environment and was installed manually.
- tree was missing and was installed manually for clean verification.
- Alpine containers required temporary installation of curl, iputils, and bind-tools for network testing.
- The original host networking command used port publishing with --network host; this was corrected because published ports are ignored in host network mode.
- Network disconnect and reconnect operations were tested to validate loss and restoration of service discovery.
- iptables Docker NAT rules were inspected to understand host-level Docker networking behavior.
