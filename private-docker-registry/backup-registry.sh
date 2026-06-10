#!/bin/bash
set -e
BACKUP_DIR="/opt/docker-registry/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="registry_backup_${TIMESTAMP}.tar.gz"
sudo mkdir -p "$BACKUP_DIR"
sudo docker stop registry-configured
sudo tar -czf "${BACKUP_DIR}/${BACKUP_FILE}" -C /opt/docker-registry data auth certs config.yml
sudo docker start registry-configured
echo "Backup created: ${BACKUP_DIR}/${BACKUP_FILE}"
sudo du -sh "${BACKUP_DIR}/${BACKUP_FILE}"
