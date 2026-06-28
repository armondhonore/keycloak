FROM quay.io/keycloak/keycloak:latest

# Keycloak configuration for Nexlayer environment
# These environment variables ensure the container starts in dev mode
# and is compatible with the Nexlayer proxy/network.
ENV KC_DB=postgres
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true
ENV KC_HTTP_ENABLED=true
ENV KC_HOSTNAME_STRICT=false
ENV KC_HTTP_PORT=8080

# JVM tuning to prevent OOMKilled in resource-constrained environments
ENV JAVA_OPTS="-XX:MaxRAMPercentage=75.0 -XX:+UseContainerSupport"

EXPOSE 8080

# Using the official binary entrypoint. 
# start-dev is used to bypass strict HTTPS requirements for internal cluster traffic.
ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "start-dev"]
