# Casa de Oxalá — API

[![CI](https://github.com/wellbenicio/casa-de-oxala-api/actions/workflows/ci.yml/badge.svg)](https://github.com/wellbenicio/casa-de-oxala-api/actions/workflows/ci.yml)
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=wellbenicio_casa-de-oxala-api&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=wellbenicio_casa-de-oxala-api)

API REST para a Casa de Oxalá — loja de artigos religiosos (umbanda, candomblé, jurema e afins).

**Stack:** Java 21 · Spring Boot 4 · PostgreSQL · Maven · Azure Container Apps

---

## Desenvolvimento local

### Pré-requisitos

- Java 21+
- Maven Wrapper (`./mvnw`) — já incluso no repositório
- Docker e Docker Compose (para o banco PostgreSQL)

### Subir a aplicação

```bash
# Sobe os serviços de infraestrutura (PostgreSQL, etc.)
docker compose up -d

# Inicia a aplicação Spring Boot
./mvnw spring-boot:run
```

### Executar os testes

```bash
# Roda apenas os testes unitários
./mvnw test

# Build completo com testes de integração e verificações
./mvnw clean verify
```

---

## Pipeline CI (GitHub Actions)

O arquivo `.github/workflows/ci.yml` dispara automaticamente em push e pull requests para `main` e `develop`.

### Jobs

| Job | O que faz |
|---|---|
| **Build & Test** | Compila com Maven, roda testes, gera relatório JaCoCo |
| **Quality Gate** | Análise SonarCloud — bloqueia o merge se o token não estiver configurado ou se a análise falhar |

> **Ambos os jobs são obrigatórios.** Configure o `SONAR_TOKEN` antes de abrir PRs.

### Configurar SonarCloud

1. Acesse [sonarcloud.io](https://sonarcloud.io) e faça login com o GitHub
2. Importe o repositório `casa-de-oxala-api` na organização `wellbenicio`
3. Em **Administration → Analysis Method**, desabilite *Automatic Analysis*
4. Gere um token em **My Account → Security**
5. No GitHub, vá em **Settings → Secrets and variables → Actions** e crie:

| Secret | Valor |
|---|---|
| `SONAR_TOKEN` | Token gerado no SonarCloud |

> **`sonar.organization` e `sonar.projectKey` já estão definidos em `pom.xml`** — apenas o `SONAR_TOKEN` precisa ser configurado como secret.

---

## Variáveis de ambiente

Copie o arquivo de exemplo e ajuste conforme seu ambiente local:

```bash
cp .env.example .env
```

> Arquivos `.env`, `application-prod.*`, `application-local.*` etc. estão no `.gitignore` e **nunca** devem ser versionados.
