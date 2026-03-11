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

### Variáveis de ambiente

Copie o arquivo de exemplo e ajuste conforme seu ambiente local:

```bash
cp .env.example .env
```

> Arquivos `.env`, `application-prod.*`, `application-local.*` etc. estão no `.gitignore` e **nunca** devem ser versionados.

### Subir a aplicação

```bash
# Sobe o banco PostgreSQL local
docker compose up -d

# Inicia a aplicação Spring Boot (lê variáveis do .env ou do ambiente)
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

## Pipeline CI/CD (GitHub Actions)

### Fluxo de branches

```
feature/* → develop → main
```

| Branch    | Trigger                       | Pipeline                    |
|-----------|-------------------------------|-----------------------------|
| `develop` | Push (após merge de feature)  | CI → CD dev (automático)    |
| `main`    | Push (via PR develop → main)  | CI → CD prod (manual gate)  |

### Jobs

| Workflow          | Arquivo                          | O que faz                                             |
|-------------------|----------------------------------|-------------------------------------------------------|
| **CI**            | `ci.yml`                         | Build, testes, JaCoCo, SonarCloud                     |
| **CD — Dev**      | `cd-dev.yml`                     | Build imagem Docker, push ACR, deploy Container Apps  |
| **CD — Prod**     | `cd-prod.yml`                    | Igual ao dev, requer aprovação manual no GitHub Env   |
| **Auto PR**       | `auto-pr-develop-to-main.yml`    | Abre PR automático de `develop` → `main`              |

### Segredos e variáveis necessários (GitHub → Settings → Secrets and variables → Actions)

#### Secrets (valores sensíveis)

| Secret                   | Descrição                                               |
|--------------------------|---------------------------------------------------------|
| `SONAR_TOKEN`            | Token do SonarCloud                                     |
| `ACR_LOGIN_SERVER`       | Servidor do Azure Container Registry (ex.: `myacr.azurecr.io`) |
| `ACR_USERNAME`           | Usuário admin do ACR                                    |
| `ACR_PASSWORD`           | Senha admin do ACR                                      |
| `AZURE_CREDENTIALS_DEV`  | JSON do Service Principal com acesso ao resource group dev  |
| `AZURE_CREDENTIALS_PROD` | JSON do Service Principal com acesso ao resource group prod |

#### Variables (valores não-sensíveis)

| Variable                    | Exemplo                        |
|-----------------------------|--------------------------------|
| `ACR_NAME`                  | `myacr`                        |
| `ACA_APP_NAME_DEV`          | `casa-de-oxala-api-dev`        |
| `ACA_APP_NAME_PROD`         | `casa-de-oxala-api`            |
| `AZURE_RESOURCE_GROUP_DEV`  | `rg-casadeoxala-dev`           |
| `AZURE_RESOURCE_GROUP_PROD` | `rg-casadeoxala-prod`          |

#### Como gerar o JSON do Service Principal

```bash
az ad sp create-for-rbac \
  --name "sp-casadeoxala-dev-deploy" \
  --role contributor \
  --scopes /subscriptions/<SUB_ID>/resourceGroups/<RG_DEV> \
  --sdk-auth
```

Copie o JSON completo retornado e salve como secret `AZURE_CREDENTIALS_DEV`.

### GitHub Environments

Configure dois ambientes em **Settings → Environments**:

| Environment  | Branch de origem | Aprovação manual      |
|--------------|------------------|-----------------------|
| `dev`        | `develop`        | Não (automático)      |
| `production` | `main`           | **Sim** (recomendado) |

---

## Gestão de secrets na aplicação

Os secrets em runtime são injetados como variáveis de ambiente no Azure Container Apps. Nunca são hard-coded nem versionados.

### Variáveis de ambiente obrigatórias (Container Apps)

| Variável                     | Descrição                                      |
|------------------------------|------------------------------------------------|
| `SPRING_DATASOURCE_URL`      | JDBC URL do PostgreSQL Azure (ex.: `jdbc:postgresql://host:5432/db`) |
| `SPRING_DATASOURCE_USERNAME` | Usuário do banco                               |
| `SPRING_DATASOURCE_PASSWORD` | Senha do banco (via Container Apps secret)     |
| `JWT_SECRET`                 | Chave JWT (mínimo 32 chars; via secret)        |
| `JWT_EXPIRATION_MS`          | Tempo de expiração do JWT em ms (padrão: 86400000) |
| `CORS_ALLOWED_ORIGINS`       | Origens permitidas no CORS (ex.: `https://meusite.com`) |
| `SPRING_PROFILES_ACTIVE`     | Perfil ativo: `dev` ou `prod`                  |

### Evolução: Azure Key Vault

Para o MVP, os secrets são gerenciados diretamente no Container Apps. Quando houver necessidade de rotação automatizada, auditoria centralizada ou volume maior de secrets, migre para Azure Key Vault com referências no Container Apps:

```bash
az keyvault secret set --vault-name <KV_NAME> --name jwt-secret --value "<valor>"
az containerapp secret set --name <APP_NAME> --resource-group <RG> \
  --secrets "jwt-secret=keyvaultref:<KV_SECRET_URI>,identityref:<MI_RESOURCE_ID>"
```

---

## Configurar SonarCloud

1. Acesse [sonarcloud.io](https://sonarcloud.io) e faça login com o GitHub
2. Importe o repositório `casa-de-oxala-api` na organização `wellbenicio`
3. Em **Administration → Analysis Method**, desabilite *Automatic Analysis*
4. Gere um token em **My Account → Security**
5. No GitHub, vá em **Settings → Secrets and variables → Actions** e crie:

| Secret | Valor |
|---|---|
| `SONAR_TOKEN` | Token gerado no SonarCloud |

> **`sonar.organization` e `sonar.projectKey` já estão definidos em `pom.xml`** — apenas o `SONAR_TOKEN` precisa ser configurado como secret.
