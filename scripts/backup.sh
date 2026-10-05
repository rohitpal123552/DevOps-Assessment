#!/usr/bin/env bash
# Creates a timestamped, gzipped pg_dump of the local database.
set -euo pipefail

cd "$(dirname "$0")/.."

if [ -f .env ]; then
  set -a
  . ./.env
  set +a
fi

DB_USER="${POSTGRES_USER:-postgres}"
DB_NAME="${POSTGRES_DB:-hotel_db}"
BACKUP_DIR="backups"

if ! docker compose ps --status running --services | grep -qx db; then
  echo "db container is not running. Start it with: docker compose up -d" >&2
  exit 1
fi

mkdir -p "$BACKUP_DIR"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_${TIMESTAMP}.sql.gz"

echo "Backing up '$DB_NAME' to $BACKUP_FILE ..."

# remove the half written file if pg_dump fails
trap 'rm -f "$BACKUP_FILE"' ERR

docker compose exec -T db pg_dump -U "$DB_USER" --no-owner "$DB_NAME" | gzip > "$BACKUP_FILE"

trap - ERR
echo "Backup done: $BACKUP_FILE ($(du -h "$BACKUP_FILE" | cut -f1))"
