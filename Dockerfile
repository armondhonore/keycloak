# Thin Keycloak wrapper for Nexlayer.
#
# The platform ignores the pod `command:`/`args:` fields, so the start mode
# (start-dev) and its flags MUST be baked into the image ENTRYPOINT here.
# start-dev uses the embedded H2 database — no external DB pod required, which
# keeps this a single-pod deploy. TLS is terminated at the Nexlayer edge and
# plain HTTP is forwarded to the pod on :8080, so we enable HTTP, trust the
# x-forwarded proxy headers, and disable strict hostname checks so the admin
# console works behind the edge.
FROM quay.io/keycloak/keycloak:26.0

ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true
ENV KC_HTTP_ENABLED=true
ENV KC_HTTP_PORT=8080
ENV KC_HOSTNAME_STRICT=false
ENV KC_PROXY_HEADERS=xforwarded
# JVM tuning to avoid OOMKilled in a resource-constrained pod.
ENV JAVA_OPTS_APPEND="-XX:MaxRAMPercentage=75.0 -XX:+UseContainerSupport"

EXPOSE 8080

# Bake the start mode + flags into the entrypoint (platform ignores pod command).
ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "start-dev", "--http-enabled=true", "--http-port=8080", "--proxy-headers=xforwarded", "--hostname-strict=false"]
