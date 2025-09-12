# ECR用 Multi-stage build Dockerfile
FROM openjdk:17-jdk-slim as builder

# Install curl for health checks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace

# Copy Maven wrapper and pom.xml
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .

# Make Maven wrapper executable
RUN chmod +x ./mvnw

# Download dependencies
RUN ./mvnw dependency:go-offline -B

# Copy source code
COPY src src

# Build the application
RUN ./mvnw clean package -DskipTests

# Runtime stage
FROM openjdk:17-jre-slim

# Install curl for health checks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN groupadd -r spring && useradd -r -g spring spring

# Set working directory
WORKDIR /app

# Copy the jar file from builder stage
COPY --from=builder /workspace/target/*.jar app.jar

# Download Splunk Otel Java Agent
RUN curl -L https://github.com/signalfx/splunk-otel-java/releases/download/v2.15.0/splunk-otel-javaagent.jar -o splunk-otel-javaagent.jar

# Set permissions for the agent and application
RUN chmod -R go+r /app/splunk-otel-javaagent.jar

# Change ownership to spring user
RUN chown spring:spring app.jar splunk-otel-javaagent.jar

# Switch to non-root user
USER spring

# Expose port
EXPOSE 8080

# Health check (内部チェックのためHTTP使用、外部アクセスはRouteでHTTPS化)
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# Set JVM options for container environment with Splunk agent
ENV JAVA_OPTS="-Xms256m -Xmx512m -XX:+UseG1GC -XX:+UseContainerSupport"

# Run the application with Splunk Java Agent
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -javaagent:./splunk-otel-javaagent.jar -jar app.jar"]
