#!/bin/bash

BACKUP_DIR="./backups"

mkdir -p "$BACKUP_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)

docker compose exec -T web \
cp /app/data/visitors.db /tmp/visitors.db

docker cp \
$(docker compose ps -q web):/tmp/visitors.db \
"$BACKUP_DIR/visitors_${TIMESTAMP}.db"

echo "Backup created:"
ls -lh "$BACKUP_DIR"
