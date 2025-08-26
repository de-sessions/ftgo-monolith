#!/bin/bash
set -euo pipefail

echo "=== FTGO Build and Run ==="
echo "12-Factor compliant build, release, and run pipeline"

if [ -f ".env" ]; then
    echo "Loading environment variables from .env file..."
    export $(cat .env | grep -v '^#' | xargs)
fi

. ./set-env.sh

echo "=== Build Stage ==="
./scripts/build.sh

echo "=== Release Stage ==="
./scripts/release.sh

echo "=== Run Stage ==="
./scripts/run.sh

echo "=== Application URLs ==="
./show-swagger-ui-urls.sh

echo "=== Build and Run Completed Successfully ==="
