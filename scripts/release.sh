#!/bin/bash
set -euo pipefail

echo "=== FTGO Release Stage ==="
echo "Creating release artifacts..."

if [ ! -f "ftgo-application/build/libs/ftgo-application.jar" ]; then
    echo "Error: Build artifacts not found. Run build.sh first."
    exit 1
fi

echo "Building Docker images..."
docker-compose build

if [ -n "${RELEASE_VERSION:-}" ]; then
    echo "Tagging images with version: $RELEASE_VERSION"
    docker tag ftgo-monolith_ftgo-application:latest ftgo-monolith_ftgo-application:$RELEASE_VERSION
    docker tag ftgo-monolith_mysql:latest ftgo-monolith_mysql:$RELEASE_VERSION
fi

echo "Release completed successfully!"
