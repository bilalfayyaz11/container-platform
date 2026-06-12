#!/bin/bash

echo "===== DOCKER COMPOSE STATUS ====="
docker compose ps

echo
echo "===== ELASTICSEARCH HEALTH ====="
curl -s "localhost:9200/_cluster/health?pretty"

echo
echo "===== LOGSTASH API ====="
curl -s "localhost:9600" | head -30

echo
echo "===== KIBANA STATUS ====="
curl -s "localhost:5601/api/status" | head -30

echo
echo "===== ELASTICSEARCH INDICES ====="
curl -s "localhost:9200/_cat/indices?v"

echo
echo "===== LOG SEARCH SAMPLE ====="
curl -s "localhost:9200/docker-logs-*/_search?pretty&size=5" | head -120
