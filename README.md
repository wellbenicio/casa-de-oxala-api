# Casa de Oxalá — API

[![CI](https://github.com/wellbenicio/casa-de-oxala-api/actions/workflows/ci.yml/badge.svg)](https://github.com/wellbenicio/casa-de-oxala-api/actions/workflows/ci.yml)
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=wellbenicio_casa-de-oxala-api&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=wellbenicio_casa-de-oxala-api)

API REST para a Casa de Oxalá — loja de artigos religiosos (umbanda, candomblé, jurema e afins).

**Stack:** Java 25 · Spring Boot 4 · PostgreSQL · Maven · Azure Container Apps

---

## Desenvolvimento local

### Pré-requisitos

- Java 25+
- Maven Wrapper (`./mvnw`) — já incluso no repositório
- Docker e Docker Compose (para o banco PostgreSQL)

### Banco de dados (PostgreSQL)

O projeto usa PostgreSQL 17 via Docker Compose. O Flyway gerencia as migrations automaticamente ao iniciar a aplicação.

#### Subir o banco

```bash
docker compose up -d
```

O container `casadeoxala-postgres` será criado com:

| Parâmetro | Valor padrão |
|---|---|
| Host | `localhost` |
| Porta | `5432` |
| Banco | `casadeoxala` |
| Usuário | `casadeoxala` |
| Senha | `casadeoxala` |

#### Verificar se o banco está pronto

```bash
docker compose ps
```

O status deve ser `healthy`.

#### Parar o banco

```bash
# Para sem perder os dados
docker compose down

# Para e remove o volume (apaga todos os dados)
docker compose down -v
```

#### Variáveis de ambiente

Copie o arquivo de exemplo e ajuste se necessário:

```bash
cp .env.example .env
```

| Variável | Descrição | Valor padrão |
|---|---|---|
| `DB_URL` | JDBC URL do PostgreSQL | `jdbc:postgresql://localhost:5432/casadeoxala` |
| `DB_USERNAME` | Usuário do banco | `casadeoxala` |
| `DB_PASSWORD` | Senha do banco | `casadeoxala` |

> Arquivos `.env` estão no `.gitignore` e **nunca** devem ser versionados.

#### Flyway (migrations)

As migrations ficam em `src/main/resources/db/migration/` e são aplicadas automaticamente ao iniciar a aplicação.

- Nomenclatura: `V<numero>__<descricao>.sql` (ex: `V1__baseline.sql`)
- Nos testes, o Flyway é desabilitado — o perfil `test` usa H2 em memória com `ddl-auto: create-drop`.

### Subir a aplicação

```bash
# Sobe o banco (se ainda não estiver rodando)
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

> Os testes usam H2 em memória e não dependem do PostgreSQL.

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
