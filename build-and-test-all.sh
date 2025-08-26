#!/bin/bash
set -euo pipefail

echo "=== FTGO Build and Test All ==="
echo "12-Factor compliant build, release, and run pipeline"

KEEP_RUNNING=
ASSEMBLE_ONLY=
DATABASE_SERVICES="mysql"

if [ -z "${DOCKER_COMPOSE:-}" ] ; then
    DOCKER_COMPOSE=docker-compose
fi

if [ -f ".env" ]; then
    echo "Loading environment variables from .env file..."
    export $(cat .env | grep -v '^#' | xargs)
fi

while [ ! -z "${1:-}" ] ; do
  case $1 in
    "--keep-running" )
      KEEP_RUNNING=yes
      ;;
    "--assemble-only" )
      ASSEMBLE_ONLY=yes
      ;;
    "--help" )
      echo "Usage: ./build-and-test-all.sh [--keep-running] [--assemble-only]"
      echo "  --keep-running: Keep services running after tests"
      echo "  --assemble-only: Only build and assemble, skip full tests"
      exit 0
      ;;
  esac
  shift
done

echo "KEEP_RUNNING=$KEEP_RUNNING"
echo "ASSEMBLE_ONLY=$ASSEMBLE_ONLY"

. ./set-env.sh

echo "=== Build Stage ==="
./gradlew testClasses

echo "=== Infrastructure Setup ==="
${DOCKER_COMPOSE} down --remove-orphans -v
${DOCKER_COMPOSE} up -d --build ${DATABASE_SERVICES}

./gradlew waitForMySql
echo "MySQL is ready"

./gradlew :ftgo-flyway:flywayMigrate
echo "Database migrations completed"

if [ -z "$ASSEMBLE_ONLY" ] ; then
  echo "=== Full Build and Test ==="
  ./gradlew -x :ftgo-end-to-end-tests:test $* build

  echo "=== Release Stage ==="
  ${DOCKER_COMPOSE} build

  echo "=== Integration Tests ==="
  ./gradlew $* integrationTest

  echo "=== Run Stage ==="
  ${DOCKER_COMPOSE} up -d
else
  echo "=== Assemble Only ==="
  ./gradlew $* assemble

  ${DOCKER_COMPOSE} up -d --build ${DATABASE_SERVICES}
  ./gradlew waitForMySql
  echo "MySQL is ready"

  ${DOCKER_COMPOSE} up -d --build
fi

echo "=== Service Health Check ==="
./wait-for-services.sh

echo "=== End-to-End Tests ==="
./run-end-to-end-tests.sh

if [ -z "$KEEP_RUNNING" ] ; then
  echo "=== Cleanup ==="
  ${DOCKER_COMPOSE} down --remove-orphans -v
fi

echo "=== Build and Test Completed Successfully ==="
