#!/bin/bash

set -e

echo "===== DOCKER COMPOSE SERVICES ====="
docker compose ps

echo
echo "===== RUNNING CONTAINERS ====="
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"

echo
echo "===== HTTP HEALTH ====="
curl -s http://localhost/health | jq

echo
echo "===== APP STATS ====="
curl -s http://localhost/stats | jq

echo
echo "===== REDIS CHECK ====="
docker compose exec redis redis-cli ping

echo
echo "===== SQLITE COUNT ====="
docker compose exec web python3 -c "
import sqlite3
conn = sqlite3.connect('/app/data/visitors.db')
cursor = conn.cursor()
cursor.execute('SELECT COUNT(*) FROM visitors')
print('Total visitors:', cursor.fetchone()[0])
conn.close()
"

echo
echo "===== IMAGE LIST ====="
docker images | grep -E 'flask-container-stack|redis|nginx'

echo
echo "===== VOLUMES ====="
docker volume ls | grep -E 'app-data|redis-data'

echo
echo "===== NETWORKS ====="
docker network ls | grep app-network

echo
echo "===== FILE TREE ====="
tree .
