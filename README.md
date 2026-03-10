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
| **Quality Gate** | Análise SonarCloud (opcional — pula se `SONAR_TOKEN` não estiver configurado) |

> **O job de Build & Test é o check obrigatório.** O Quality Gate é opcional e não bloqueia o merge caso os secrets do SonarCloud ainda não estejam configurados.

### Configurar SonarCloud (opcional)

1. Acesse [sonarcloud.io](https://sonarcloud.io) e faça login com o GitHub
2. Importe o repositório `casa-de-oxala-api` na organização `wellbenicio`
3. Em **Administration → Analysis Method**, desabilite *Automatic Analysis*
4. Gere um token em **My Account → Security**
5. No GitHub, vá em **Settings → Secrets and variables → Actions** e crie:

| Secret | Valor |
|---|---|
| `SONAR_TOKEN` | Token gerado no SonarCloud |
| `SONAR_ORGANIZATION` | `wellbenicio` |
| `SONAR_PROJECT_KEY` | `wellbenicio_casa-de-oxala-api` |

---

## Configuração de Branch Protection

Para garantir que o proprietário (`wellbenicio`) consiga **aprovar e mergear** os pull requests abertos pelo agente Copilot, siga os passos abaixo.

### Configurar a regra de proteção da branch `main`

1. Acesse **Settings → Branches** no repositório
2. Clique em **Edit** na regra existente para `main` (ou **Add rule** se não houver)
3. Aplique as seguintes configurações:

#### ✅ Configurações recomendadas

| Configuração | Valor |
|---|---|
| Require a pull request before merging | ✅ Habilitado |
| Required approvals | `1` |
| Dismiss stale reviews | ✅ Recomendado |
| Require status checks to pass before merging | ✅ Habilitado |
| Status check obrigatório | `Build & Test` (nome do job no CI) |
| Require branches to be up to date before merging | ✅ Recomendado |
| Do not allow bypassing the above settings | ❌ **Desabilitado** — permite que admins/owners façam merge mesmo que alguns checks falhem em casos emergenciais |

#### ⚠️ Configurações que bloqueiam o owner — verifique se estão desabilitadas

| Configuração | Deve estar |
|---|---|
| Restrict who can push to matching branches | ❌ Desabilitado (ou contendo `wellbenicio`) |
| Require review from Code Owners | ❌ Desabilitado (não há `CODEOWNERS` neste repositório) |
| Restrict who can dismiss pull request reviews | ❌ Desabilitado |

> **Atenção:** No GitHub, o autor de um PR **não pode aprovar o próprio PR**. Como os PRs são abertos pelo agente **Copilot**, o proprietário `wellbenicio` pode (e deve) aprovar normalmente — desde que o CI esteja verde.

### Por que os PRs ficam bloqueados?

Os PRs aparecem como **bloqueados** principalmente porque:

1. **CI falha** — O job `Build & Test` retorna erro (ex.: testes não passam). Após o merge deste PR, o CI deve passar e desbloquear os PRs #3 e #4.
2. **Review pendente** — O branch protection exige pelo menos 1 aprovação. Basta `wellbenicio` aprovar o PR no GitHub.
3. **Branch desatualizada** — Se `main` recebeu commits desde que o PR foi aberto, é necessário fazer `Update branch` antes do merge.

### Fluxo de aprovação

```
Copilot abre PR → CI roda → CI passa (verde) → wellbenicio aprova → wellbenicio faz merge
```

---

## Variáveis de ambiente

Copie o arquivo de exemplo e ajuste conforme seu ambiente local:

```bash
cp .env.example .env
```

> Arquivos `.env`, `application-prod.*`, `application-local.*` etc. estão no `.gitignore` e **nunca** devem ser versionados.
