## O que foi feito?

<!-- Descreva de forma objetiva as mudanças implementadas neste PR -->

-

## Por que essa mudança é necessária?

<!-- Explique o contexto e a motivação. Referencie a issue quando aplicável (ex: Closes #42) -->

-

## Como testar?

<!-- Passo a passo para validar as mudanças localmente -->

1.
2.
3.

---

## Checklist

### Geral

- [ ] O código compila e os testes passam (`./mvnw clean verify`)
- [ ] Não há dados pessoais (PII) em logs (nome, e-mail, CPF, telefone, endereço)
- [ ] Nenhuma credencial ou segredo foi commitado

### API / Contrato

- [ ] DTOs de request e response criados/atualizados corretamente
- [ ] Respostas de erro seguem o padrão da API (`ApiError` / RFC 9457)
- [ ] Swagger/OpenAPI atualizado (anotações `@Operation`, `@ApiResponse`)

### Banco de dados

- [ ] Migrations Flyway nomeadas corretamente (`V<versao>__<descricao>.sql`)
- [ ] Nenhuma migration existente foi alterada

### Integrações externas

- [ ] Endpoints de webhook implementam idempotência (`idempotency_key` ou equivalente)
