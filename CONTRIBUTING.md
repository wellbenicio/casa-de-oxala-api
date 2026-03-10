# Contribuindo com o Casa de Oxalá API

Obrigado por contribuir! Este guia descreve os padrões adotados no projeto para manter o histórico limpo e o processo de revisão ágil.

---

## Modelo de branching — GitHub Flow

A branch `main` é protegida e representa sempre o estado deployável da aplicação. **Nunca commite diretamente na `main`.**

```
main  ●────────────────●────────────────●──── (produção)
       \              /  \              /
        ●──●──●──●──●    ●──●──●──●──●
        criar  commits  PR  criar  commits  PR
```

### Regras do fluxo

1. Toda mudança começa criando uma branch a partir da `main` atualizada.
2. Desenvolva na branch, fazendo commits pequenos e frequentes.
3. Abra um Pull Request (PR) direcionado à `main`.
4. A CI deve passar antes do merge.
5. Após o merge, a branch é deletada automaticamente.

---

## Convenção de nomes de branch

```
<tipo>/COX-<id>-<descricao-curta>
```

| Tipo | Quando usar |
|---|---|
| `feature` | Nova funcionalidade |
| `fix` | Correção de bug |
| `chore` | Tooling, CI, configurações |
| `docs` | Documentação |
| `refactor` | Refatoração sem mudança de comportamento |

**Exemplos:**

```
feature/COX-01-crud-produtos
fix/COX-15-webhook-idempotencia
chore/COX-03-github-actions-ci
docs/COX-04-readme-operacional
refactor/COX-22-extrai-servico-pagamento
```

> O identificador `COX-<id>` corresponde ao número da issue no GitHub (ex: `COX-42` → issue #42).

---

## Conventional Commits

Formato:

```
<tipo>(<escopo>): <descrição curta no imperativo>

[corpo opcional — explica o "porquê", não o "o quê"]

[rodapé opcional — breaking changes, closes #issue]
```

### Tipos

| Tipo | Descrição |
|---|---|
| `feat` | Nova funcionalidade |
| `fix` | Correção de bug |
| `chore` | Tarefa de manutenção sem impacto funcional |
| `docs` | Documentação |
| `refactor` | Refatoração sem mudança de comportamento |
| `test` | Adição ou correção de testes |
| `perf` | Melhoria de performance |
| `ci` | Pipelines e configurações de CI/CD |

### Escopos sugeridos

| Escopo | Domínio |
|---|---|
| `catalog` | Catálogo de produtos e categorias |
| `checkout` | Carrinho e pedidos |
| `payments` | Integração com gateways de pagamento |
| `delivery` | Cálculo e rastreamento de entregas |
| `ops` | Operações e infraestrutura |
| `quotes` | Cotações |
| `iam` | Identidade e acesso (autenticação/autorização) |
| `audit` | Auditoria e rastreabilidade |
| `shared` | Utilitários e componentes compartilhados |

**Exemplos:**

```
feat(catalog): cria endpoint de listagem de produtos com paginação

fix(payments): corrige cálculo de desconto em pedidos com cupom

chore(ci): adiciona job de lint no GitHub Actions

docs(iam): atualiza exemplos de autenticação JWT no Swagger

refactor(checkout): extrai lógica de validação de estoque para serviço dedicado
```

---

## Desenvolvimento local

### Pré-requisitos

- Java 25+
- Maven Wrapper (`./mvnw`) — já incluso no repositório
- Docker e Docker Compose (para o banco de dados)

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

### Variáveis de ambiente

Copie o arquivo de exemplo e ajuste conforme seu ambiente local:

```bash
cp .env.example .env
```

---

## Migrations Flyway

- **Nunca altere** uma migration já aplicada em qualquer ambiente.
- Novas migrations devem seguir a nomenclatura:
  ```
  V<versao>__<descricao_snake_case>.sql
  ```
  Exemplo: `V002__adiciona_coluna_status_produto.sql`
- Migrations destrutivas (DROP, DELETE em massa) precisam ser revisadas com atenção redobrada.
- Scripts de dados iniciais (seeds) devem usar o prefixo `R__` (repeatable) apenas quando for realmente necessário reaplicar.

---

## Definition of Done (DoD)

Uma tarefa está **concluída** quando:

- [ ] Código implementado e funcionando conforme o requisito
- [ ] Testes unitários criados/atualizados — cobertura mínima mantida
- [ ] Testes de integração passando (`./mvnw clean verify`)
- [ ] PR aberto com template preenchido
- [ ] CI verde (build + testes + lint)
- [ ] Code review aprovado
- [ ] Sem regressões em funcionalidades existentes

---

## Observabilidade e segurança

### Sem PII nos logs

Nunca registre dados pessoais identificáveis (nome, e-mail, CPF, telefone, endereço) em logs.

```java
// ❌ Errado
log.info("Processando pedido do cliente {}", cliente.getEmail());

// ✅ Correto
log.info("Processando pedido id={}", pedido.getId());
```

### Actuator

- Mantenha os endpoints do Actuator (`/actuator/**`) protegidos — não exponha em ambiente de produção sem autenticação.
- Adicione health checks relevantes para novos serviços integrados.

### Idempotência de webhooks

- Todo endpoint que recebe callbacks externos (ex: gateways de pagamento) **deve** implementar idempotência usando um campo `idempotency_key` ou similar.
- Requisições duplicadas devem retornar a resposta original sem reprocessar o evento.
