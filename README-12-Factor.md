# FTGO 12-Factor App Modernization

This document describes the 12-Factor App modernization implemented across the FTGO monolith application.

## Overview

The FTGO application has been modernized to follow all 12 factors of the [12-Factor App methodology](https://12factor.net/), making it more suitable for modern cloud deployments and DevOps practices.

## 12-Factor Implementation

### I. Codebase
✅ **Implemented**: Single codebase tracked in Git with multiple deployment environments
- Single repository with environment-specific configurations
- Multiple deployment targets (development, staging, production)

### II. Dependencies
✅ **Implemented**: Explicitly declared and isolated dependencies
- Gradle build system with explicit dependency declarations
- Environment-specific dependency management via `gradle.properties`
- Docker containers provide dependency isolation

### III. Config
✅ **Implemented**: Configuration externalized to environment variables
- All configuration moved from hardcoded values to environment variables
- Default values provided for development convenience
- Environment-specific `.env` files supported
- Examples: `SPRING_DATASOURCE_URL`, `MYSQL_PASSWORD`, `LOGGING_LEVEL_*`

### IV. Backing Services
✅ **Implemented**: Backing services treated as attached resources
- Database, Kafka, and Zookeeper configured via environment variables
- Service URLs externalized: `KAFKA_BOOTSTRAP_SERVERS`, `ZOOKEEPER_CONNECTION_STRING`
- Easy swapping between local and remote services

### V. Build, Release, Run
✅ **Implemented**: Strict separation of build, release, and run stages
- **Build**: `scripts/build.sh` - Compiles code and creates artifacts
- **Release**: `scripts/release.sh` - Combines build artifacts with config
- **Run**: `scripts/run.sh` - Executes the release in runtime environment
- Updated `build-and-run.sh` to use separated stages

### VI. Processes
✅ **Implemented**: Stateless process execution
- Application designed as stateless processes
- No local session storage
- All persistent data stored in backing services (MySQL)

### VII. Port Binding
✅ **Implemented**: Services export via port binding
- Applications bind to ports specified by `SERVER_PORT` environment variable
- Self-contained services that export HTTP
- No dependency on runtime injection of webserver

### VIII. Concurrency
✅ **Implemented**: Horizontal scaling via process model
- Docker containers enable horizontal scaling
- JVM configuration externalized via `JAVA_OPTS`
- Resource limits defined in production configuration

### IX. Disposability
✅ **Implemented**: Fast startup and graceful shutdown
- Improved Docker health checks with proper timeouts
- Graceful shutdown handling in Spring Boot applications
- Fast startup optimizations in container configuration

### X. Dev/Prod Parity
✅ **Implemented**: Minimal differences between environments
- Same environment variable patterns across all environments
- Environment-specific Docker Compose files (`docker-compose.override.yml`, `docker-compose.prod.yml`)
- Consistent backing services across environments

### XI. Logs
✅ **Implemented**: Logs as event streams
- Structured JSON logging configuration (`config/logback-spring.xml`)
- All logs output to stdout/stderr
- Log levels configurable via environment variables
- No local log file storage

### XII. Admin Processes
✅ **Implemented**: Admin tasks as one-off processes
- Database migration script: `scripts/admin/db-migrate.sh`
- Database reset script: `scripts/admin/db-reset.sh`
- Admin processes use same environment and codebase

## Usage

### Environment Configuration

1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

2. Customize the `.env` file for your environment:
   ```bash
   # Edit database credentials, ports, etc.
   vim .env
   ```

### Development

```bash
# Build, release, and run for development
./build-and-run.sh

# Or use individual stages
./scripts/build.sh
./scripts/release.sh
./scripts/run.sh
```

### Production

```bash
# Use production configuration
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

### Admin Tasks

```bash
# Run database migrations
./scripts/admin/db-migrate.sh

# Reset database (development only)
./scripts/admin/db-reset.sh
```

## Environment Variables

### Core Application
- `SPRING_APPLICATION_NAME`: Application name
- `SERVER_PORT`: HTTP port binding
- `JAVA_OPTS`: JVM configuration

### Database Configuration
- `SPRING_DATASOURCE_URL`: Database connection URL
- `SPRING_DATASOURCE_USERNAME`: Database username
- `SPRING_DATASOURCE_PASSWORD`: Database password
- `MYSQL_ROOT_PASSWORD`: MySQL root password
- `MYSQL_USER`: MySQL application user
- `MYSQL_PASSWORD`: MySQL application password

### Logging Configuration
- `LOGGING_LEVEL_ROOT`: Root logging level
- `LOGGING_LEVEL_FTGO`: Application logging level
- `LOGGING_LEVEL_HIBERNATE_SQL`: SQL logging level

### Backing Services
- `KAFKA_BOOTSTRAP_SERVERS`: Kafka connection string
- `ZOOKEEPER_CONNECTION_STRING`: Zookeeper connection string
- `SPRING_ZIPKIN_BASE_URL`: Distributed tracing URL

### Management/Monitoring
- `MANAGEMENT_ENDPOINTS`: Exposed actuator endpoints
- `MANAGEMENT_HEALTH_SHOW_DETAILS`: Health check detail level

## Migration Notes

### Breaking Changes
- Database driver updated from `com.mysql.jdbc.Driver` to `com.mysql.cj.jdbc.Driver`
- All configuration now requires environment variables (defaults provided)
- Log output format changed to structured JSON (with fallback)

### Backward Compatibility
- Default values provided for all environment variables
- Existing Docker Compose commands continue to work
- Build scripts maintain same interface

## Benefits

1. **Cloud Native**: Ready for deployment on modern cloud platforms
2. **Scalable**: Horizontal scaling support via stateless processes
3. **Configurable**: Runtime configuration without code changes
4. **Observable**: Structured logging and health checks
5. **Maintainable**: Clear separation of concerns and standardized practices
6. **Portable**: Consistent behavior across environments
