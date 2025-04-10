#!/bin/bash
# PostgreSQL backup script for Sonarr and Radarr using superuser credentials

# Define the timestamp format for backup filenames
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$HOME/postgres_backups"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Backup Sonarr database using superuser credentials
echo "Backing up Sonarr database..."
PGUSER=$(kubectl -n media get secret sonarr-superuser -o jsonpath="{.data.username}" | base64 -d)
PGPASSWORD=$(kubectl -n media get secret sonarr-superuser -o jsonpath="{.data.password}" | base64 -d) \
pg_dump-17 -h localhost -p 5432 -U "$PGUSER" -d sonarr-main -F c -f "$BACKUP_DIR/sonarr-main_$TIMESTAMP.backup"

# Backup Radarr database using superuser credentials
echo "Backing up Radarr database..."
PGUSER=$(kubectl -n media get secret radarr-superuser -o jsonpath="{.data.username}" | base64 -d)
PGPASSWORD=$(kubectl -n media get secret radarr-superuser -o jsonpath="{.data.password}" | base64 -d) \
pg_dump-17 -h localhost -p 5433 -U "$PGUSER" -d radarr-main -F c -f "$BACKUP_DIR/radarr-main_$TIMESTAMP.backup"

echo "Backups completed successfully."
echo "Sonarr backup: $BACKUP_DIR/sonarr-main_$TIMESTAMP.backup"
echo "Radarr backup: $BACKUP_DIR/radarr-main_$TIMESTAMP.backup"
