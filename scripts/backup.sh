#!/bin/bash

set -e

BACKUP_DIR="./backups"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="$BACKUP_DIR/ecommerce_${TIMESTAMP}.sql"

mkdir -p "$BACKUP_DIR"

echo "Starting PostgreSQL backup..."

docker exec ecommerce-postgres-compose \
  pg_dump -U ecommerce_user -d ecommerce_db \
  > "$BACKUP_FILE"

echo "Backup completed successfully!"
echo "Backup file: $BACKUP_FILE"

