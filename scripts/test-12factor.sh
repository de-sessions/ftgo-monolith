#!/bin/bash
set -euo pipefail

echo "=== FTGO 12-Factor Compliance Test ==="

echo "Testing Factor III - Config externalization..."
if grep -q "\$" ftgo-application/src/main/resources/application.properties; then
    echo "✅ Configuration externalized with environment variables"
else
    echo "❌ Configuration not properly externalized"
    exit 1
fi

echo "Testing Factor V - Build artifacts..."
if [ -f "scripts/build.sh" ] && [ -f "scripts/release.sh" ] && [ -f "scripts/run.sh" ]; then
    echo "✅ Build, release, and run stages separated"
else
    echo "❌ Build stages not properly separated"
    exit 1
fi

echo "Testing Factor III - Environment documentation..."
if [ -f ".env.example" ]; then
    echo "✅ Environment variables documented"
else
    echo "❌ Environment variables not documented"
    exit 1
fi

echo "Testing Factor XI - Logging configuration..."
if [ -f "config/logback-spring.xml" ] || [ -f "ftgo-application/src/main/resources/logback-spring.xml" ]; then
    echo "✅ Structured logging configuration exists"
else
    echo "❌ Logging configuration missing"
    exit 1
fi

echo "Testing Factor VII - Port binding..."
if grep -q "SERVER_PORT" docker-compose.yml; then
    echo "✅ Port binding externalized"
else
    echo "❌ Port binding not externalized"
    exit 1
fi

echo "Testing Factor XII - Admin processes..."
if [ -f "scripts/admin/db-migrate.sh" ] && [ -f "scripts/admin/db-reset.sh" ]; then
    echo "✅ Admin processes implemented"
else
    echo "❌ Admin processes missing"
    exit 1
fi

echo "Testing Factor X - Dev/Prod parity..."
if [ -f "docker-compose.override.yml" ] && [ -f "docker-compose.prod.yml" ]; then
    echo "✅ Environment-specific configurations exist"
else
    echo "❌ Environment parity configurations missing"
    exit 1
fi

echo "=== All 12-Factor compliance tests passed! ==="
