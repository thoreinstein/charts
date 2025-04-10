#!/bin/bash
# PostgreSQL restore script for Sonarr and Radarr databases
# Restores the most recent backup for each database

set -e

BACKUP_DIR="$HOME/postgres_backups"

# Function to get the most recent backup file for a given pattern
get_latest_backup() {
  local pattern="$1"
  # Simplified to just get the first matching file without sorting by time
  find "$BACKUP_DIR" -name "$pattern" -type f | head -1
}

# Function to restore a database
restore_database() {
  local app="$1"
  local port="$2"
  local backup_file="$3"
  local username="$4"
  local dbname="$5"
  
  if [ "$backup_file" = "" ]; then
    echo "No backup found for $app"
    return 1
  fi
  
  echo "Restoring $app database from: $backup_file"
  echo "Using port: $port, username: $username, database: $dbname"
  
  # Get password from Kubernetes secret
  PGPASSWORD=$(kubectl -n media get secret "$app-db-credentials" -o jsonpath="{.data.password}" | base64 -d)
  
  # Drop and recreate the database
  PGPASSWORD=$PGPASSWORD psql-17 -h localhost -p "$port" -U "$username" -c "DROP DATABASE IF EXISTS \"$dbname\";"
  PGPASSWORD=$PGPASSWORD psql-17 -h localhost -p "$port" -U "$username" -c "CREATE DATABASE \"$dbname\" WITH OWNER = \"$username\";"
  
  # Restore the database
  PGPASSWORD=$PGPASSWORD pg_restore-17 -h localhost -p "$port" -U "$username" -d "$dbname" "$backup_file"
  
  echo "$app database restoration completed successfully."
}

# Check if backup directory exists
if [ ! -d "$BACKUP_DIR" ]; then
  echo "Error: Backup directory not found: $BACKUP_DIR"
  exit 1
fi

echo "=== PostgreSQL Database Restore Tool ==="
echo "This script will restore the most recent PostgreSQL backups for Sonarr and Radarr"
echo "Backup directory: $BACKUP_DIR"
echo

# Set up port-forwarding for Sonarr database (run in background)
echo "Setting up port-forwarding for Sonarr database..."
kubectl -n media port-forward svc/sonarr-rw 5432:5432 &
SONARR_PF_PID=$!
# Give it a moment to establish
sleep 3

# Set up port-forwarding for Radarr database (run in background)
echo "Setting up port-forwarding for Radarr database..."
kubectl -n media port-forward svc/radarr-rw 5433:5432 &
RADARR_PF_PID=$!
# Give it a moment to establish
sleep 3

# Find the latest backup files
SONARR_BACKUP=$(get_latest_backup "sonarr-main_*.backup")
RADARR_BACKUP=$(get_latest_backup "radarr-main_*.backup")

# local app="$1"
# local port="$2"
# local backup_file="$3"
# local username="$4"
# local dbname="$5"
# Restore Sonarr database
restore_database "sonarr" "5432" "$SONARR_BACKUP" "sonarr" "sonarr-main"

# Restore Radarr database
restore_database "radarr" "5433" "$RADARR_BACKUP" "radarr" "radarr-main"

# Clean up port-forwarding
echo "Cleaning up port-forwarding..."
kill "$SONARR_PF_PID" "$RADARR_PF_PID" 2>/dev/null || true
wait "$SONARR_PF_PID" "$RADARR_PF_PID" 2>/dev/null || true

echo
echo "=== Restoration process completed ==="
echo "Check the logs above for any errors."
