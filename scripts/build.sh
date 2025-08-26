#!/bin/bash
set -euo pipefail

echo "=== FTGO Build Stage ==="
echo "Building application artifacts..."

./gradlew clean assemble

echo "Build completed successfully!"
