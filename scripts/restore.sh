#!/usr/bin/env bash
# Restores a backup into a fresh database (default: hotel_db_restored).
# Usage: ./scripts/restore.sh [backup_file]
# If no file is given, the newest file in backups/ is used.
set -euo pipefail

cd "$(dirname "$0")/.."

if [ -f .env ]; then
  set -a
  . ./.env
  set +a
fi

DB_USER="${POSTGRES_USER:-postgres}"
DB_NAME="${POSTGRES_DB:-hotel_db}"
RESTORE_DB="${RESTORE_DB:-hotel_db_restored}"

BACKUP_FILE="${1:-$(ls -1t backups/*.sql.gz 2>/dev/null | head -n 1 || true)}"

if [ -z "$BACKUP_FILE" ] || [ ! -f "$BACKUP_FILE" ]; then
  echo "No backup file found. Run ./scripts/backup.sh first." >&2
  exit 1
fi

if ! docker compose ps --status running --services | grep -qx db; then
  echo "db container is not running. Start it with: docker compose up -d" >&2
  exit 1
fi

echo "Restoring $BACKUP_FILE into fresh database '$RESTORE_DB' ..."

docker compose exec -T db psql -U "$DB_USER" -d postgres -v ON_ERROR_STOP=1 -q \
  -c "DROP DATABASE IF EXISTS \"$RESTORE_DB\" WITH (FORCE);" \
  -c "CREATE DATABASE \"$RESTORE_DB\";"

gunzip -c "$BACKUP_FILE" | docker compose exec -T db psql -U "$DB_USER" -d "$RESTORE_DB" -v ON_ERROR_STOP=1 -q

count() {
  docker compose exec -T db psql -U "$DB_USER" -d "$1" -tAc "SELECT count(*) FROM $2" | tr -d '[:space:]'
}

echo
echo "Row counts (source vs restored):"
echo "  hotel_bookings : $(count "$DB_NAME" hotel_bookings) vs $(count "$RESTORE_DB" hotel_bookings)"
echo "  booking_events : $(count "$DB_NAME" booking_events) vs $(count "$RESTORE_DB" booking_events)"
echo
echo "Restore finished. Database: $RESTORE_DB"
