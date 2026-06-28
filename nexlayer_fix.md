# Nexlayer fix (pinned — authoritative, use verbatim)

Root cause of the 503/build-failure: `KC_DB=postgres` was set with NO postgres
pod (start-dev needs no external DB), and the app image was a stale built ref
instead of the pipeline placeholder so the runner deployed a broken old image.
Fix: thin `FROM quay.io/keycloak/keycloak:26.0` wrapper whose ENTRYPOINT bakes
`start-dev --proxy-headers=xforwarded --hostname-strict=false` (the platform
ignores the pod command), embedded H2 DB (no KC_DB), bootstrap admin creds, and
the app image set to the pipeline placeholder. Do NOT regenerate the Dockerfile.

## Fixed Dockerfile

```
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
```

## Fixed nexlayer.yaml

```
application:
  name: keycloak
  pods:
    - name: keycloak
      # Placeholder so the runner injects the freshly BUILT wrapper image (the
      # thin FROM quay.io/keycloak/keycloak:26.0 image whose ENTRYPOINT bakes
      # `start-dev --proxy-headers=xforwarded --hostname-strict=false`). A real
      # image ref here would make the runner skip the build and deploy a stale
      # image instead.
      image: "# filled by pipeline"
      path: /
      servicePorts:
        - 8080
      vars:
        # start-dev uses the embedded H2 DB — do NOT set KC_DB (postgres with no
        # DB pod was why startup failed). Health/metrics on; HTTP enabled and
        # proxy/hostname relaxed for the edge (also baked into ENTRYPOINT).
        KC_HEALTH_ENABLED: "true"
        KC_METRICS_ENABLED: "true"
        KC_HTTP_ENABLED: "true"
        KC_HTTP_PORT: "8080"
        KC_HOSTNAME_STRICT: "false"
        KC_PROXY_HEADERS: "xforwarded"
        # First-boot admin account (Keycloak 26 bootstrap vars). Without these
        # start-dev provisions no admin and the console is unusable.
        KC_BOOTSTRAP_ADMIN_USERNAME: "admin"
        KC_BOOTSTRAP_ADMIN_PASSWORD: "nexlayer2024"
        JAVA_OPTS_APPEND: "-XX:MaxRAMPercentage=75.0 -XX:+UseContainerSupport"
```
