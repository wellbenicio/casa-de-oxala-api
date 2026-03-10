# Casa de Oxalá — API

[![CI](https://github.com/wellbenicio/casa-de-oxala-api/actions/workflows/ci.yml/badge.svg)](https://github.com/wellbenicio/casa-de-oxala-api/actions/workflows/ci.yml)
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=wellbenicio_casa-de-oxala-api&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=wellbenicio_casa-de-oxala-api)
[![Coverage](https://sonarcloud.io/api/project_badges/measure?project=wellbenicio_casa-de-oxala-api&metric=coverage)](https://sonarcloud.io/summary/new_code?id=wellbenicio_casa-de-oxala-api)

Backend REST API for Casa de Oxalá — a religious articles store management system.

## Stack

- **Java 21** + **Spring Boot 3**
- **PostgreSQL** (via Azure Database for PostgreSQL Flexible Server)
- **Maven**
- **Flyway** for database migrations
- **Spring Security** + JWT
- **Springdoc OpenAPI** (Swagger UI)

## Getting Started

### Prerequisites

- Java 21+
- Maven 3.9+
- PostgreSQL 15+

### Running locally

```bash
./mvnw spring-boot:run
```

### Running tests

```bash
./mvnw clean verify
```

## CI/CD

The CI pipeline runs automatically on every push and pull request to `main` and `develop` branches.

### Pipeline jobs

| Job | Description |
|-----|-------------|
| **Build & Test** | Compiles the project and runs all tests with JaCoCo coverage report |
| **Quality Gate** | Runs SonarCloud analysis and enforces quality gate |

### Configuring Secrets (required for Quality Gate)

Add the following secrets in **Settings → Secrets and variables → Actions**:

| Secret | Description |
|--------|-------------|
| `SONAR_TOKEN` | SonarCloud user token (generate at sonarcloud.io → My Account → Security) |
| `SONAR_ORGANIZATION` | SonarCloud organization key (e.g. `wellbenicio`) |
| `SONAR_PROJECT_KEY` | SonarCloud project key (e.g. `wellbenicio_casa-de-oxala-api`) |

### SonarCloud Setup

1. Go to [sonarcloud.io](https://sonarcloud.io) and sign in with GitHub
2. Click **"+"** → **"Analyze new project"** and import `casa-de-oxala-api`
3. Note your **Organization Key** and **Project Key**
4. In **Administration → Analysis Method**, disable "Automatic Analysis" (CI-based analysis is used)
5. Generate a token at **My Account → Security** and add it as `SONAR_TOKEN` secret
6. Update the badge URLs in README.md to match your actual project key if it differs from `wellbenicio_casa-de-oxala-api`

## Architecture

Modular monolith organized by feature (package-by-feature). Domains:

- `catalog` — products, categories, images
- `checkout` — orders, items, totals, status
- `payments` — payment intents, webhooks
- `delivery` — shipping, distance calculation
- `ops` — operational queue, dispatch
- `iam` — authentication, authorization (RBAC)
- `audit` — audit logging

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.
