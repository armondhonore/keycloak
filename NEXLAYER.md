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
Keycloak is an open-source Identity and Access Management (IAM) solution providing single sign-on, user federation, and fine-grained authorization for modern applications.
<!-- nexlayer:end -->

## Technology Stack
<!-- nexlayer:section agent-managed=tech_stack -->
| Name | Kind | Version | Detected From |
|------|------|---------|---------------|
| Java | language | 17 | pom.xml |
| Quarkus | framework | 3.33.2.1 | pom.xml |
| Maven | build | 3.9.8 | pom.xml |
<!-- nexlayer:end -->

## Repository Structure
<!-- nexlayer:section agent-managed=structure_map -->
- core/ — Core IAM logic and identity providers
- services/ — Backend service implementations
- quarkus/ — Quarkus-specific integration and deployment logic
- distribution/ — Packaging and distribution scripts
- themes/ — UI templates for login and account management
- operator/ — Kubernetes operator for Keycloak lifecycle management
<!-- nexlayer:end -->

## External Services Required
<!-- nexlayer:section agent-managed=external_deps -->
Services that must be configured separately (not deployed by Nexlayer):

- Relational Database (PostgreSQL/MySQL/Oracle/MSSQL)
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
| `keycloak` | `KC_DB` | `"postgres"` | plain |
| `keycloak` | `KC_HEALTH_ENABLED` | `"true"` | plain |
| `keycloak` | `KC_METRICS_ENABLED` | `"true"` | plain |
| `keycloak` | `JAVA_OPTS` | `"-XX:MaxRAMPercentage=75.0 -XX:+UseContainerSupport"` | plain |

### nexlayer.yaml

```yaml
application:
  name: keycloak
  pods:
    - name: keycloak
      image: "registry.nexlayer.io/user_01kece1xyh817dwff7wnarhkxd/keycloak:9f0bca6-fix5"
      path: /
      servicePorts:
        - 8080
      vars:
        KC_DB: "postgres"
        KC_HEALTH_ENABLED: "true"
        KC_METRICS_ENABLED: "true"
        JAVA_OPTS: "-XX:MaxRAMPercentage=75.0 -XX:+UseContainerSupport"
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
**Last deployed:** 2026-06-28T01:49:52Z  
**Live URL:** https://relaxed-weasel-keycloak.cloud.nexlayer.ai  
**Runtime:**  · **Port:** auto-detected  
**Deploy branch:** nexlayer  

```yaml
application:
  name: keycloak
  pods:
    - name: keycloak
      image: "registry.nexlayer.io/user_01kece1xyh817dwff7wnarhkxd/keycloak:9f0bca6-fix5"
      path: /
      servicePorts:
        - 8080
      vars:
        KC_DB: "postgres"
        KC_HEALTH_ENABLED: "true"
        KC_METRICS_ENABLED: "true"
        JAVA_OPTS: "-XX:MaxRAMPercentage=75.0 -XX:+UseContainerSupport"
```
<!-- nexlayer:end -->

## Build History
<!-- nexlayer:section agent-managed=build_history -->
| Date | Status | Notes |
|------|--------|-------|
| 2026-06-28T01:14:29Z | analyzed | initial repo analysis |
| 2026-06-28T01:49:52Z | success | deployed https://relaxed-weasel-keycloak.cloud.nexlayer.ai |
<!-- nexlayer:end -->
