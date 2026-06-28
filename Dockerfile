# Thin Keycloak wrapper for Nexlayer.
#
# The platform ignores the pod `command:`/`args:` fields, so the start mode
# (start-dev) and its flags MUST be baked into the image ENTRYPOINT here.
# We force the embedded H2 dev database (KC_DB=dev-file) — no external DB pod
# required, single-pod deploy. The base keycloak:26.0 image carries a persisted
# `db=postgres` build option, so start-dev was trying (and failing) to reach a
# non-existent postgres; we re-run `kc.sh build --db=dev-file` to overwrite that
# persisted option, and also pin it via env + the entrypoint flag. TLS is
# terminated at the Nexlayer edge and plain HTTP is forwarded on :8080, so we
# enable HTTP, trust x-forwarded headers, and relax strict hostname checks.
FROM quay.io/keycloak/keycloak:26.0

ENV KC_DB=dev-file
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true
ENV KC_HTTP_ENABLED=true
ENV KC_HTTP_PORT=8080
ENV KC_HOSTNAME_STRICT=false
ENV KC_PROXY_HEADERS=xforwarded
# JVM tuning to avoid OOMKilled in a resource-constrained pod.
ENV JAVA_OPTS_APPEND="-XX:MaxRAMPercentage=75.0 -XX:+UseContainerSupport"

# Re-bake the persisted build options to H2 so start-dev does not inherit the
# base image's db=postgres.
RUN /opt/keycloak/bin/kc.sh build --db=dev-file --health-enabled=true --metrics-enabled=true

EXPOSE 8080

# Bake the start mode + flags into the entrypoint (platform ignores pod command).
ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "start-dev", "--db=dev-file", "--http-enabled=true", "--http-port=8080", "--proxy-headers=xforwarded", "--hostname-strict=false"]