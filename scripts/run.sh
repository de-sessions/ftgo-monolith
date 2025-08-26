#!/bin/bash
set -euo pipefail

echo "=== FTGO Run Stage ==="
echo "Starting application services..."

if [ -f ".env" ]; then
    echo "Loading environment variables from .env file..."
    export $(cat .env | grep -v '^#' | xargs)
fi

echo "Starting infrastructure services..."
docker-compose up -d mysql

echo "Waiting for MySQL to be ready..."
./gradlew waitForMySql

echo "Running database migrations..."
./gradlew :ftgo-flyway:flywayMigrate

echo "Starting application services..."
docker-compose up -d

echo "Application started successfully!"
echo "Application will be available at: http://localhost:${FTGO_APP_PORT:-8081}"
