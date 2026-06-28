# Nexlayer — keycloak

<!-- nexlayer:meta version=1 analyzed=2026-06-28T01:14:29Z repo=https://github.com/armondhonore/keycloak branch=nexlayer -->

> **For AI agents (Claude Code, Cursor, Gemini CLI, Copilot):**
> This file is the **project context** for this Nexlayer deployment — tech stack, env vars, secrets, live URL.
> For full platform detail (nexlayer.yaml schema, Dockerfile rules, CI/CD, task recipes) read **`nexlayer.skills`** in this repo.
>
> **Critical rules (full detail in `nexlayer.skills`):**
> - Inter-pod refs: `${podName:port}` only — never `localhost` or bare hostnames
> - Docker Hub images: prefix with `mirror.gcr.io/library/` — bare tags fail on the cluster
> - Secrets: set in the Nexlayer dashboard — never commit to `nexlayer.yaml` or Dockerfile
>
> **This file:** `agent-managed` sections update automatically. `user-editable` sections (Local Development Setup, Nexlayer Deployment Plan, Build Notes) are yours — preserved across re-analysis.

## Project Summary
<!-- nexlayer:section agent-managed=project_summary -->
Keycloak is an open-source Identity and Access Management (IAM) solution providing authentication, authorization, and user federation for modern applications.
<!-- nexlayer:end -->

## Technology Stack
<!-- nexlayer:section agent-managed=tech_stack -->
| Name | Kind | Version | Detected From |
|------|------|---------|---------------|
| Java | language | 17 | pom.xml |
| Quarkus | framework | 3.x | quarkus/ |
| Maven | build | 3.9 | pom.xml, mvnw |
<!-- nexlayer:end -->

## Repository Structure
<!-- nexlayer:section agent-managed=structure_map -->
- core/ — Core IAM logic and authentication engines
- services/ — Backend service implementations
- quarkus/ — Quarkus-based runtime configuration
- distribution/ — Packaging and build scripts
- themes/ — UI customization and templates
<!-- nexlayer:end -->

## External Services Required
<!-- nexlayer:section agent-managed=external_deps -->
Services that must be configured separately (not deployed by Nexlayer):

- PostgreSQL (Required for persistence)
<!-- nexlayer:end -->

## Local Development Setup
<!-- nexlayer:section user-editable=local_setup -->
### Prerequisites

- OpenJDK 17
- Maven 3.9.8

### Environment variables

Copy `.env.example` to `.env.local` and fill in:

```
KC_DB=postgres
KC_DB_URL=jdbc:postgresql://localhost:5432/keycloak
KC_DB_USERNAME=keycloak
KC_DB_PASSWORD=password
KEYCLOAK_ADMIN=admin
KEYCLOAK_ADMIN_PASSWORD=admin
```

### Steps

1. `./mvnw clean install` — Build the project using the Maven wrapper
2. `./mvnw quarkus:dev` — Start Keycloak in development mode via Quarkus

<!-- nexlayer:end -->

## Nexlayer Setup
<!-- nexlayer:section agent-managed=nexlayer_setup -->
### Pod Environment Variables

| Pod | Variable | Value | Kind |
|-----|----------|-------|------|
| `keycloak` | `KC_DB` | `"dev-file"` | plain |
| `keycloak` | `KC_HEALTH_ENABLED` | `"true"` | plain |
| `keycloak` | `KC_METRICS_ENABLED` | `"true"` | plain |
| `keycloak` | `KC_HTTP_ENABLED` | `"true"` | plain |
| `keycloak` | `KC_HTTP_PORT` | `"8080"` | plain |
| `keycloak` | `KC_HOSTNAME_STRICT` | `"false"` | plain |
| `keycloak` | `KC_PROXY_HEADERS` | `"xforwarded"` | plain |
| `keycloak` | `KC_BOOTSTRAP_ADMIN_USERNAME` | `"admin"` | plain |
| `keycloak` | `KC_BOOTSTRAP_ADMIN_PASSWORD` | _(set via Nexlayer dashboard)_ | secret |
| `keycloak` | `JAVA_OPTS_APPEND` | `"-XX:MaxRAMPercentage=75.0 -XX:+UseContainerSupport"` | plain |

### Secrets Required

Set these in the Nexlayer dashboard before deploying:

- `KC_BOOTSTRAP_ADMIN_PASSWORD` (`keycloak` pod)

### nexlayer.yaml

```yaml
application:
  name: keycloak
  pods:
    - name: keycloak
      # Placeholder so the runner injects the freshly BUILT wrapper image (the
      # thin FROM quay.io/keycloak/keycloak:26.0 image whose ENTRYPOINT bakes
      # `start-dev --proxy-headers=xforwarded --hostname-strict=false`). A real
      # image ref here would make the runner skip the build and deploy a stale
      # image instead.
      image: "registry.nexlayer.io/user_01kece1xyh817dwff7wnarhkxd/keycloak:19f0da5ebde"
      path: /
      servicePorts:
        - 8080
      vars:
        # Force the embedded H2 dev DB. The base keycloak:26.0 image has a
        # persisted db=postgres build option, so without this start-dev tries a
        # non-existent postgres and crashes. dev-file = no external DB pod.
        KC_DB: "dev-file"
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
<!-- nexlayer:end -->

## Nexlayer Deployment Plan
<!-- nexlayer:section user-editable=deployment_plan -->
### Pod Topology

| Pod | Image | Port | Role |
|-----|-------|------|------|
| keycloak | mirror.gcr.io/library/openjdk:17-slim | 8080 | web |
| postgres | mirror.gcr.io/library/postgres:16-alpine | 5432 | database |

### Deployment notes

- Keycloak connects to the database pod using the address postgres.pod:5432
- Images are sourced from mirror.gcr.io to comply with Nexlayer platform rules
- Database is strictly separated into its own pod

<!-- nexlayer:end -->

## Build Notes
<!-- nexlayer:section user-editable=build_notes -->
<!-- Add notes for future builds here — preserved across re-analysis -->
<!-- nexlayer:end -->

## Nexlayer Configuration
<!-- nexlayer:section agent-managed=nexlayer_config -->
**Last deployed:** 2026-06-28T09:55:22Z  
**Live URL:** https://relaxed-weasel-keycloak.cloud.nexlayer.ai  
**Runtime:**  · **Port:** auto-detected  
**Deploy branch:** nexlayer  

```yaml
application:
  name: keycloak
  pods:
    - name: keycloak
      # Placeholder so the runner injects the freshly BUILT wrapper image (the
      # thin FROM quay.io/keycloak/keycloak:26.0 image whose ENTRYPOINT bakes
      # `start-dev --proxy-headers=xforwarded --hostname-strict=false`). A real
      # image ref here would make the runner skip the build and deploy a stale
      # image instead.
      image: "registry.nexlayer.io/user_01kece1xyh817dwff7wnarhkxd/keycloak:19f0da5ebde"
      path: /
      servicePorts:
        - 8080
      vars:
        # Force the embedded H2 dev DB. The base keycloak:26.0 image has a
        # persisted db=postgres build option, so without this start-dev tries a
        # non-existent postgres and crashes. dev-file = no external DB pod.
        KC_DB: "dev-file"
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
<!-- nexlayer:end -->

## Build History
<!-- nexlayer:section agent-managed=build_history -->
| Date | Status | Notes |
|------|--------|-------|
| 2026-06-28T09:53:47Z | analyzed | initial repo analysis |
| 2026-06-28T09:55:22Z | success | deployed https://relaxed-weasel-keycloak.cloud.nexlayer.ai |
<!-- nexlayer:end -->



