FROM mysql:8.0

# Copy initialization scripts
COPY schema.sql /docker-entrypoint-initdb.d/schema.sql

# Configure MySQL for 12-factor compliance
ENV MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-rootpassword}
ENV MYSQL_DATABASE=${MYSQL_DATABASE:-ftgo}
ENV MYSQL_USER=${MYSQL_USER:-mysqluser}
ENV MYSQL_PASSWORD=${MYSQL_PASSWORD:-mysqlpw}

# Expose port via environment variable
EXPOSE ${MYSQL_PORT:-3306}

# Health check for disposability
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD mysqladmin ping -h localhost || exit 1
