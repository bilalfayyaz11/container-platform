#!/bin/bash
echo "=== Docker Swarm Nodes ==="
docker node ls

echo
echo "=== Docker Swarm Services ==="
docker service ls

echo
echo "=== Docker Swarm Tasks ==="
docker service ps $(docker service ls -q) --no-trunc

echo
echo "=== Docker Networks ==="
docker network ls

echo
echo "=== Docker Secrets ==="
docker secret ls

echo
echo "=== Docker System Usage ==="
docker system df
