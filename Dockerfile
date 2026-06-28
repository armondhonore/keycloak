# Thin wrapper over the official Keycloak image so the container starts the
# server by default. The Nexlayer pipeline does not honor a pod-level
# `command:` field (the image CMD/ENTRYPOINT runs as-is), and the upstream
# Keycloak image has no default CMD — it prints usage and exits. Baking the
# start command into CMD here makes the prebuilt server boot on deploy.
FROM quay.io/keycloak/keycloak:26.0

# start-dev: dev mode (HTTP enabled, no TLS termination in-pod — the Nexlayer
# edge terminates TLS and forwards X-Forwarded-* headers). Hostname + proxy
# flags make Keycloak emit correct absolute URLs behind the edge proxy.
ENV KC_HEALTH_ENABLED=true

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start-dev", "--http-enabled=true", "--http-port=8080", "--hostname=https://relaxed-weasel-keycloak.cloud.nexlayer.ai", "--hostname-strict=false", "--proxy-headers=xforwarded"]
