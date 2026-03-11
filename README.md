# Casa de Oxalá — API

[![CI](https://github.com/wellbenicio/casa-de-oxala-api/actions/workflows/ci.yml/badge.svg)](https://github.com/wellbenicio/casa-de-oxala-api/actions/workflows/ci.yml)
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=wellbenicio_casa-de-oxala-api&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=wellbenicio_casa-de-oxala-api)

API REST para a Casa de Oxalá — loja de artigos religiosos (umbanda, candomblé, jurema e afins).

**Stack:** Java 21 · Spring Boot · PostgreSQL · Maven · Azure Container Apps

---

## Desenvolvimento local

### Pré-requisitos

- Java 21+
- Maven Wrapper (`./mvnw`) — já incluso no repositório
- Docker e Docker Compose (para o banco PostgreSQL)

### Variáveis de ambiente

```bash
cp .env.example .env
# edite .env com suas configurações locais
```

> Arquivos `.env`, `application-prod.*`, `application-local.*` etc. estão no `.gitignore` e **nunca** devem ser versionados.

### Subir a aplicação

```bash
# Sobe o banco PostgreSQL local
docker compose up -d

# Inicia a aplicação Spring Boot
./mvnw spring-boot:run
```

### Executar os testes

```bash
./mvnw test          # apenas testes unitários
./mvnw clean verify  # build completo + JaCoCo
```

---

## Arquitetura Azure (MVP — custo mínimo)

```
GitHub Actions
    │
    ├─ CI (build + test)
    │
    ├─ CD Dev ──► ACR ──► Container App (dev)  ─┐
    └─ CD Prod ─► ACR ──► Container App (prod) ─┤
                                                 │
                           PostgreSQL Flexible Server
                           ├─ database: casadeoxala_dev
                           └─ database: casadeoxala_prod
```

**Recursos Azure (1 resource group, compartilhado):**

| Recurso | SKU / Tier | Observação |
|---|---|---|
| Resource Group | — | Único, compartilhado dev + prod |
| Container Registry (ACR) | Basic | ~US$ 5/mês; free tier não existe |
| Container Apps Environment | Consumption | Paga por uso; próximo de zero em MVP |
| Container App (dev) | Consumption, `minReplicas=0` | Escala a zero quando inativo |
| Container App (prod) | Consumption, `minReplicas=0` | Escala a zero; aceitar cold start no MVP |
| PostgreSQL Flexible Server | Burstable B1ms | ~US$ 13/mês; 2 DBs lógicos no mesmo server |

> **Custo estimado MVP:** ~US$ 18–25/mês (dominado por PostgreSQL + ACR).
> Se o custo ainda for alto, considere compartilhar o server com outros projetos ou usar Neon/Supabase free tier no MVP inicial.

### `minReplicas=0` — scale-to-zero

Ambos os Container Apps são criados com `--min-replicas 0`. Isso elimina custo de compute quando não há tráfego.  
**Trade-off:** cold start de ~15–30 s na primeira requisição após inatividade. Aceitável para MVP.

---

## Pipeline CI/CD (GitHub Actions)

### Fluxo

```
feature/* → develop → main
              │           │
            CD Dev     CD Prod (requer aprovação manual)
```

| Workflow | Arquivo | Trigger | O que faz |
|---|---|---|---|
| **CI** | `ci.yml` | Push/PR em `develop` ou `main` | Build, testes, JaCoCo, SonarCloud |
| **CD Dev** | `cd-dev.yml` | CI ✅ em `develop` | Build Docker → push ACR → deploy dev |
| **CD Prod** | `cd-prod.yml` | CI ✅ em `main` | Build Docker → push ACR → deploy prod (gate manual) |
| **Auto PR** | `auto-pr-develop-to-main.yml` | Push em `develop` | Abre PR automático `develop → main` |

### Autenticação Azure: OIDC (sem JSON longo)

Os workflows usam **federated credentials** (OIDC) para autenticar no Azure.  
Nenhum segredo de longa duração (`AZURE_CREDENTIALS_*`, `ACR_PASSWORD`, etc.) é armazenado no GitHub.

O fluxo é:
1. GitHub Actions gera um token OIDC efêmero para o job
2. `azure/login@v2` troca esse token por um token Azure (via Entra ID)
3. `az acr login` autentica o Docker usando o token Azure (sem senha de admin)
4. `az containerapp update` atualiza a imagem (sem credencial extra)

---

## Configuração no GitHub

### Secrets

| Secret | Descrição |
|---|---|
| `AZURE_CLIENT_ID` | Client ID do Service Principal (App Registration) para OIDC |
| `SONAR_TOKEN` | *(opcional)* Token do SonarCloud |

### Variables

| Variable | Exemplo | Descrição |
|---|---|---|
| `AZURE_TENANT_ID` | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` | Tenant ID do Azure AD |
| `AZURE_SUBSCRIPTION_ID` | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` | Subscription ID |
| `AZURE_RESOURCE_GROUP` | `rg-casadeoxala` | Resource group único (dev + prod) |
| `ACR_NAME` | `acrcasadeoxala` | Nome do Azure Container Registry |
| `ACA_APP_NAME_DEV` | `casa-de-oxala-api-dev` | Nome do Container App de dev |
| `ACA_APP_NAME_PROD` | `casa-de-oxala-api` | Nome do Container App de prod |

### GitHub Environments

Crie em **Settings → Environments**:

| Environment | Branch | Aprovação manual |
|---|---|---|
| `dev` | `develop` (implícito via `workflow_run`) | Não |
| `production` | `main` (implícito via `workflow_run`) | **Sim — adicione seu usuário como reviewer** |

---

## Configuração manual na Azure

> Execute **uma única vez** ao criar a infraestrutura. Depois disso, os deploys são automáticos via GitHub Actions.

### Pré-requisitos

```bash
# Instale Azure CLI e autentique
az login
az account set --subscription "<SUBSCRIPTION_ID>"

# Defina variáveis de conveniência (substitua pelos seus valores)
RG="rg-casadeoxala"
LOCATION="eastus"
ACR="acrcasadeoxala"            # nome único global; sem hifens
ENV="cae-casadeoxala"          # Container Apps Environment
APP_DEV="casa-de-oxala-api-dev"
APP_PROD="casa-de-oxala-api"
PG_SERVER="pg-casadeoxala"
PG_ADMIN="pgadmin"
PG_PASS="<senha-forte>"        # guarde em lugar seguro
SP_NAME="sp-casadeoxala-deploy"
```

### 1. Resource Group

```bash
az group create --name "$RG" --location "$LOCATION"
```

### 2. Container Registry (ACR)

```bash
az acr create \
  --name "$ACR" \
  --resource-group "$RG" \
  --sku Basic \
  --admin-enabled false          # sem admin; autenticação via identidade
```

### 3. Container Apps Environment (compartilhado dev + prod)

```bash
az containerapp env create \
  --name "$ENV" \
  --resource-group "$RG" \
  --location "$LOCATION"
```

### 4. PostgreSQL Flexible Server + 2 databases lógicos

```bash
az postgres flexible-server create \
  --name "$PG_SERVER" \
  --resource-group "$RG" \
  --location "$LOCATION" \
  --sku-name "Standard_B1ms" \
  --tier "Burstable" \
  --storage-size 32 \
  --version 16 \
  --admin-user "$PG_ADMIN" \
  --admin-password "$PG_PASS" \
  --public-access None           # acesso apenas via Container Apps

az postgres flexible-server db create \
  --server-name "$PG_SERVER" \
  --resource-group "$RG" \
  --database-name casadeoxala_dev

az postgres flexible-server db create \
  --server-name "$PG_SERVER" \
  --resource-group "$RG" \
  --database-name casadeoxala_prod
```

### 5. Container App — Dev

```bash
az containerapp create \
  --name "$APP_DEV" \
  --resource-group "$RG" \
  --environment "$ENV" \
  --image "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest" \
  --target-port 8080 \
  --ingress external \
  --min-replicas 0 \
  --max-replicas 2 \
  --registry-server "${ACR}.azurecr.io" \
  --registry-identity system-environment \
  --secrets \
    "db-password=${PG_PASS}" \
    "jwt-secret=$(openssl rand -hex 32)" \
  --env-vars \
    "SPRING_PROFILES_ACTIVE=dev" \
    "SPRING_DATASOURCE_URL=jdbc:postgresql://${PG_SERVER}.postgres.database.azure.com:5432/casadeoxala_dev?sslmode=require" \
    "SPRING_DATASOURCE_USERNAME=${PG_ADMIN}" \
    "SPRING_DATASOURCE_PASSWORD=secretref:db-password" \
    "JWT_SECRET=secretref:jwt-secret" \
    "CORS_ALLOWED_ORIGINS=http://localhost:3000"
```

### 6. Container App — Prod

```bash
az containerapp create \
  --name "$APP_PROD" \
  --resource-group "$RG" \
  --environment "$ENV" \
  --image "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest" \
  --target-port 8080 \
  --ingress external \
  --min-replicas 0 \
  --max-replicas 3 \
  --registry-server "${ACR}.azurecr.io" \
  --registry-identity system-environment \
  --secrets \
    "db-password=${PG_PASS}" \
    "jwt-secret=$(openssl rand -hex 32)" \
  --env-vars \
    "SPRING_PROFILES_ACTIVE=prod" \
    "SPRING_DATASOURCE_URL=jdbc:postgresql://${PG_SERVER}.postgres.database.azure.com:5432/casadeoxala_prod?sslmode=require" \
    "SPRING_DATASOURCE_USERNAME=${PG_ADMIN}" \
    "SPRING_DATASOURCE_PASSWORD=secretref:db-password" \
    "JWT_SECRET=secretref:jwt-secret" \
    "CORS_ALLOWED_ORIGINS=https://<seu-dominio-prod>"
```

> **Nota:** `--registry-identity system-environment` usa a managed identity do Container Apps Environment para pull de imagens do ACR — sem usuário/senha de admin.

### 7. Service Principal + Federated Credentials (OIDC)

```bash
# Cria o Service Principal
SP_ID=$(az ad sp create-for-rbac \
  --name "$SP_NAME" \
  --skip-assignment \
  --query appId -o tsv)

# Atribui permissões mínimas
TENANT_ID=$(az account show --query tenantId -o tsv)
SUB_ID=$(az account show --query id -o tsv)

# AcrPush — para fazer push de imagens
ACR_ID=$(az acr show --name "$ACR" --resource-group "$RG" --query id -o tsv)
az role assignment create --assignee "$SP_ID" --role "AcrPush" --scope "$ACR_ID"

# Contributor no resource group — para az containerapp update
RG_ID=$(az group show --name "$RG" --query id -o tsv)
az role assignment create --assignee "$SP_ID" --role "Contributor" --scope "$RG_ID"

# Federated credential para o GitHub Environment 'dev'
az ad app federated-credential create \
  --id "$SP_ID" \
  --parameters "{
    \"name\": \"github-dev\",
    \"issuer\": \"https://token.actions.githubusercontent.com\",
    \"subject\": \"repo:wellbenicio/casa-de-oxala-api:environment:dev\",
    \"audiences\": [\"api://AzureADTokenExchange\"]
  }"

# Federated credential para o GitHub Environment 'production'
az ad app federated-credential create \
  --id "$SP_ID" \
  --parameters "{
    \"name\": \"github-production\",
    \"issuer\": \"https://token.actions.githubusercontent.com\",
    \"subject\": \"repo:wellbenicio/casa-de-oxala-api:environment:production\",
    \"audiences\": [\"api://AzureADTokenExchange\"]
  }"

echo "AZURE_CLIENT_ID  (secret):  $SP_ID"
echo "AZURE_TENANT_ID  (variable): $TENANT_ID"
echo "AZURE_SUBSCRIPTION_ID (variable): $SUB_ID"
```

### 8. Permitir acesso do PostgreSQL ao Container Apps Environment

```bash
# Obtém o IP de saída do Container Apps Environment
OUTBOUND_IP=$(az containerapp env show \
  --name "$ENV" \
  --resource-group "$RG" \
  --query "properties.staticIp" -o tsv)

az postgres flexible-server firewall-rule create \
  --name "$PG_SERVER" \
  --resource-group "$RG" \
  --rule-name "allow-containerapp-env" \
  --start-ip-address "$OUTBOUND_IP" \
  --end-ip-address "$OUTBOUND_IP"
```

---

## Variáveis de ambiente de runtime (Container Apps)

Configuradas diretamente no Container App — nunca no código. Veja os comandos da seção anterior.

| Variável | Descrição | Sensível? |
|---|---|---|
| `SPRING_PROFILES_ACTIVE` | `dev` ou `prod` | Não |
| `SPRING_DATASOURCE_URL` | JDBC URL do PostgreSQL (`...?sslmode=require`) | Não |
| `SPRING_DATASOURCE_USERNAME` | Usuário do banco | Não |
| `SPRING_DATASOURCE_PASSWORD` | Senha do banco | **Sim** — via `secretref:` |
| `JWT_SECRET` | Chave JWT (≥ 32 chars) | **Sim** — via `secretref:` |
| `JWT_EXPIRATION_MS` | Expiração do token em ms (padrão: `86400000`) | Não |
| `CORS_ALLOWED_ORIGINS` | Origens CORS permitidas | Não |

> Secrets do Container Apps (`secretref:`) são criptografados pelo Azure e nunca expostos em logs ou variáveis de ambiente planas.

---

## Configurar SonarCloud

1. Acesse [sonarcloud.io](https://sonarcloud.io) e faça login com o GitHub
2. Importe o repositório `casa-de-oxala-api` na organização `wellbenicio`
3. Em **Administration → Analysis Method**, desabilite *Automatic Analysis*
4. Gere um token em **My Account → Security**
5. No GitHub, vá em **Settings → Secrets → Actions** e crie o secret `SONAR_TOKEN`

> `sonar.organization` e `sonar.projectKey` já estão em `pom.xml`. Só o token precisa ser configurado.

---

## Custos e trade-offs aceitos no MVP

| Decisão | Motivo |
|---|---|
| `minReplicas=0` em dev e prod | Elimina custo de compute idle; cold start é tolerável no MVP |
| 1 SP + 2 federated credentials (não 2 SPs) | Simplifica gestão de identidade para equipe solo |
| 1 Resource Group compartilhado | Menos overhead; isolamento por Container App é suficiente para MVP |
| 1 PostgreSQL server + 2 databases lógicos | Evita pagar dois servers (~US$ 26/mês → ~US$ 13/mês) |
| ACR Basic (não Standard) | Suficiente para MVP; sem geo-replication nem content trust |
| Sem Key Vault agora | Container Apps secrets satisfazem a necessidade; KV adicionado quando houver rotação automática ou auditoria de secrets |

---

## Evolução futura

- **Key Vault:** quando necessitar de rotação automática, auditoria de acesso a secrets ou volume maior:
  ```bash
  az keyvault secret set --vault-name <KV> --name jwt-secret --value "<valor>"
  az containerapp secret set --name <APP> --resource-group <RG> \
    --secrets "jwt-secret=keyvaultref:<KV_SECRET_URI>,identityref:<MI_ID>"
  ```
- **`minReplicas=1` em prod:** quando a latência de cold start se tornar inaceitável
- **Standard/Premium ACR:** quando precisar de geo-replication ou vulnerability scanning de imagens
- **Bicep/Terraform:** quando a infraestrutura precisar ser reproduzível de forma confiável (ex.: múltiplos ambientes, onboarding de mais devs)
- **VNet + Private Endpoint no PostgreSQL:** quando o tráfego DB/App precisar ser totalmente privado (hoje usa firewall por IP de saída)

