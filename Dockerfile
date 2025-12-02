## Multi-stage build intentionally omitted: CI builds the jar, this image expects the fat jar in /target
## Minimal runtime Dockerfile for the Spring Boot application

FROM eclipse-temurin:17-jre AS runtime

WORKDIR /app

# Copy the fat jar produced by the build into the image. CI places jar(s) in target/.
COPY target/*.jar app.jar

EXPOSE 8080

# Use JAVA_OPTS environment variable if provided
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 CMD wget -qO- http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]
