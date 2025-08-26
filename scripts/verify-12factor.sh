#!/bin/bash
set -euo pipefail

echo "=== FTGO 12-Factor Verification ==="

echo "Verifying build process..."
./scripts/build.sh

echo "Verifying configuration externalization..."
if [ -f ".env.example" ]; then
    cp .env.example .env
    echo "✅ Environment configuration ready"
fi

echo "Testing Docker Compose configuration..."
docker-compose config > /dev/null
echo "✅ Docker Compose configuration valid"

echo "Verifying script permissions..."
if [ -x "scripts/build.sh" ] && [ -x "scripts/release.sh" ] && [ -x "scripts/run.sh" ]; then
    echo "✅ All scripts are executable"
else
    echo "❌ Scripts not executable"
    exit 1
fi

echo "Running 12-factor compliance tests..."
./scripts/test-12factor.sh

echo "=== 12-Factor verification completed successfully! ==="
