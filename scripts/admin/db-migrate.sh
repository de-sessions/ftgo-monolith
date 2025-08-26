#!/bin/bash
set -euo pipefail

echo "=== FTGO Database Migration Admin Process ==="

if [ -f ".env" ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

if ! docker-compose ps mysql | grep -q "Up"; then
    echo "Starting MySQL service..."
    docker-compose up -d mysql
    ./gradlew waitForMySql
fi

echo "Running database migrations..."
./gradlew :ftgo-flyway:flywayMigrate

echo "Database migration completed successfully!"
