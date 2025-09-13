# ROSA-compatible Multi-stage build Dockerfile
FROM registry.access.redhat.com/ubi8/openjdk-17:1.17 as builder

# Install Maven
RUN microdnf install -y maven

# Set working directory
WORKDIR /workspace

# Copy pom.xml first for better layer caching
COPY pom.xml .

# Download dependencies
RUN mvn dependency:go-offline -B

# Copy source code
COPY src src

# Build the application
RUN mvn clean package -DskipTests
 
# Runtime stage
FROM registry.access.redhat.com/ubi8/openjdk-17-runtime:1.17

# Set working directory
WORKDIR /app

# Copy the jar file from builder stage
COPY --from=builder /workspace/target/*.jar app.jar

# Download Splunk Otel Java Agent
RUN curl -L https://github.com/signalfx/splunk-otel-java/releases/download/v2.15.0/splunk-otel-javaagent.jar -o splunk-otel-javaagent.jar

# Set permissions for the agent and application
RUN chmod -R go+r /app/splunk-otel-javaagent.jar

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# Set JVM options for container environment with Splunk agent
ENV JAVA_OPTS="-Xms256m -Xmx512m -XX:+UseG1GC -XX:+UseContainerSupport"

# Run the application with Splunk Java Agent
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -javaagent:./splunk-otel-javaagent.jar -jar app.jar"]
 
