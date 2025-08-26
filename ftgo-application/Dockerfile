FROM openjdk:8u171-jre-alpine

RUN apk --no-cache add curl && \
    addgroup -g 1000 ftgo && \
    adduser -D -s /bin/sh -u 1000 -G ftgo ftgo

WORKDIR /app

COPY build/libs/ftgo-application.jar ./ftgo-application.jar

RUN chown -R ftgo:ftgo /app

USER ftgo

EXPOSE ${SERVER_PORT:-8080}

HEALTHCHECK --start-period=40s --interval=30s --timeout=10s --retries=3 \
    CMD curl -f http://localhost:${SERVER_PORT:-8080}/actuator/health || exit 1

CMD ["sh", "-c", "exec java ${JAVA_OPTS:--Xmx192m} -Djava.security.egd=file:/dev/./urandom -jar ftgo-application.jar"]
