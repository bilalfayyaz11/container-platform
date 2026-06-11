#!/bin/bash

set -e

BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p "$BACKUP_DIR"

APP_VOLUME=$(docker volume ls --format '{{.Name}}' | grep '_app-data$' | head -1)
REDIS_VOLUME=$(docker volume ls --format '{{.Name}}' | grep '_redis-data$' | head -1)

if [ -z "$APP_VOLUME" ]; then
    echo "App data volume not found"
    exit 1
fi

if [ -z "$REDIS_VOLUME" ]; then
    echo "Redis data volume not found"
    exit 1
fi

docker run --rm \
  -v "$APP_VOLUME":/data:ro \
  -v "$(pwd)/$BACKUP_DIR":/backup \
  alpine tar czf "/backup/app-data-$TIMESTAMP.tar.gz" -C /data .

docker run --rm \
  -v "$REDIS_VOLUME":/data:ro \
  -v "$(pwd)/$BACKUP_DIR":/backup \
  alpine tar czf "/backup/redis-data-$TIMESTAMP.tar.gz" -C /data .

echo "Backup completed: $TIMESTAMP"
ls -lh "$BACKUP_DIR"
