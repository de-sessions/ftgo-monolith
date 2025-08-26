#!/bin/bash
set -euo pipefail

echo "=== FTGO Database Reset Admin Process ==="
echo "WARNING: This will destroy all data in the database!"

read -p "Are you sure you want to reset the database? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Database reset cancelled."
    exit 0
fi

if [ -f ".env" ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

echo "Stopping and removing database container..."
docker-compose down mysql
docker-compose rm -f mysql

echo "Removing database volume..."
docker volume rm ftgo-monolith_mysql_data 2>/dev/null || true

echo "Starting fresh database..."
docker-compose up -d mysql
./gradlew waitForMySql

echo "Running database migrations..."
./gradlew :ftgo-flyway:flywayMigrate

echo "Database reset completed successfully!"
