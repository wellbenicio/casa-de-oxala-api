# AGENTS.md — Contexto Mestre para Agentes de IA
## Projeto Casa de Oxalá

> Use este documento como fonte de verdade antes de executar qualquer tarefa de desenvolvimento neste projeto.
> Ele foi escrito para Codex, GitHub Copilot, agentes autônomos e assistentes de código.
> Se uma solicitação conflitar com este documento, pare e peça validação humana antes de implementar.

---

## 1. Finalidade

Este documento existe para impedir que agentes de IA:

- inventem requisitos;
- criem funcionalidades fora do MVP;
- tomem decisões arquiteturais não aprovadas;
- introduzam overengineering;
- alterem regras críticas de pagamento, estoque, pedido, segurança ou auditoria;
- implementem integrações, bibliotecas ou serviços cloud sem necessidade real;
- ignorem o backlog planejado no Jira.

O agente deve trabalhar com base em:

1. este documento;
2. o código atual do repositório;
3. o backlog planejado no Jira;
4. a tarefa específica solicitada pelo usuário.

---

## 2. Identidade do produto

**Nome:** Casa de Oxalá

A Casa de Oxalá é um **e-commerce operacional com backoffice/mini-ERP** para uma loja de artigos religiosos.

Não é apenas uma vitrine online. O produto precisa apoiar a operação real da loja:

- catálogo;
- cadastro de clientes;
- carrinho;
- checkout;
- pedidos;
- pagamentos;
- estoque;
- separação;
- despacho/entrega;
- orçamentos personalizados;
- relatórios gerenciais;
- auditoria operacional.

---

## 3. Stack técnica oficial

### Backend

- Java 25
- Spring Boot 4
- Spring Security
- Jakarta Validation
- API REST JSON
- OpenAPI/Swagger
- Flyway
- PostgreSQL

### Frontend

- Next.js
- TypeScript
- Um único app com rotas separadas:
  - área pública;
  - área do cliente;
  - área administrativa.

### Cloud

- Azure

Serviços previstos para o MVP:

- Azure App Service ou Azure Container Apps para backend;
- Azure Static Web Apps ou App Service para frontend;
- Azure Database for PostgreSQL Flexible Server;
- Azure Blob Storage para imagens;
- Application Insights / Azure Monitor para observabilidade básica;
- App Settings / Container Apps Secrets no MVP;
- Key Vault somente se for viável e não adicionar fricção excessiva.

### CI/CD

- GitHub Actions

### Pagamento

- Mercado Pago Checkout Pro

### Gateway alternativo permitido

- Asaas, apenas como fallback se Mercado Pago for inviável por bloqueio cadastral, fricção operacional, homologação ou custo.

O agente **não deve trocar gateway por conta própria**.

---

## 4. Arquitetura oficial

A arquitetura oficial é:

```txt
Monólito modular + API REST JSON
```

O backend deve ser organizado por módulos de domínio, não por microsserviços.

### Módulos backend previstos

- `auth`
- `customers`
- `addresses`
- `users`
- `products`
- `inventory`
- `cart`
- `orders`
- `payments`
- `shipping`
- `quotes`
- `notifications`
- `reports`
- `audit`

### Estrutura interna sugerida por módulo

Use esta estrutura quando fizer sentido, sem criar abstrações inúteis:

```txt
module
├── api
│   ├── controller
│   ├── request
│   └── response
├── application
│   ├── service
│   └── usecase
├── domain
│   ├── model
│   ├── enum
│   └── policy
├── infrastructure
│   ├── repository
│   ├── persistence
│   └── integration
└── mapper
```

### Decisões proibidas no MVP sem aprovação explícita

Não introduzir:

- microsserviços;
- Kubernetes;
- AKS;
- Kafka;
- RabbitMQ;
- Azure Service Bus;
- Event Grid;
- CQRS;
- Event Sourcing;
- API Gateway dedicado;
- Redis;
- Elasticsearch;
- BI completo;
- Data warehouse;
- multi-região;
- alta disponibilidade sofisticada;
- checkout transparente;
- salvar cartão;
- split de pagamento;
- múltiplos gateways ativos;
- WhatsApp Business API;
- integração automática com Correios/Melhor Envio;
- emissão fiscal;
- app mobile;
- marketplace;
- multi-loja;
- multi-estoque.

---

## 5. Organização frontend oficial

Estrutura sugerida:

```txt
src
├── app
│   ├── (public)
│   ├── (customer)
│   ├── (admin)
│   └── api
├── components
├── services
├── hooks
├── schemas
├── types
├── utils
└── middleware.ts
```

### Regras para o frontend

- Não concentrar regra crítica apenas no frontend.
- Toda regra de negócio crítica deve existir no backend.
- Usar services para chamadas HTTP.
- Proteger rotas de cliente e admin.
- Cliente só acessa seus próprios dados.
- Admin/backoffice deve respeitar perfil.
- Nunca exibir preço de compra ao cliente.
- Tratar estados de carregamento, vazio e erro.
- Não criar layout sofisticado antes de concluir fluxo funcional.

---

## 6. Perfis e permissões

Perfis internos oficiais do MVP:

```txt
ADMIN
GESTOR
ATENDENTE
OPERACAO
```

### Regras

- `ADMIN`: acesso total.
- `GESTOR`: produtos, estoque, pedidos, relatórios e operação.
- `ATENDENTE`: orçamentos, clientes e acompanhamento de pedidos.
- `OPERACAO`: separação, checklist, despacho, retirada, entrega e não entrega.

### Restrições

- Apenas Admin/Gestor alteram preço.
- Apenas Admin/Gestor alteram estoque manualmente.
- Apenas Admin/Gestor cancelam pedido efetivamente.
- Atendente atua em orçamentos e atendimento.
- Operação não altera preço, pagamento ou estoque manual sem permissão explícita.

---

## 7. Regras críticas de domínio

### 7.1. Segurança e LGPD

Obrigatório:

- senha sempre com hash seguro;
- token com expiração;
- validação backend com Jakarta Validation;
- DTOs separados de entidades;
- não retornar senha, hash, token ou dados sensíveis;
- não logar senha, token, CPF ou payload sensível;
- não passar dados pessoais sensíveis em query string;
- cliente só acessa seus próprios dados;
- endpoints administrativos exigem autenticação interna e perfil correto.

Proibido:

- retornar entidade JPA diretamente em API pública;
- deixar endpoint admin sem proteção;
- expor stack trace em resposta HTTP;
- versionar secrets.

### 7.2. Produtos e catálogo

Produto deve suportar:

- nome;
- slug;
- descrição curta;
- descrição completa;
- categoria;
- preço de venda;
- preço promocional;
- preço de compra;
- ativo/inativo;
- disponível/indisponível;
- imagens;
- peso/dimensões opcionais.

Regras:

- produto inativo não aparece no catálogo público;
- produto indisponível pode aparecer, mas não pode ser comprado;
- preço promocional deve ser menor que preço de venda;
- preço de compra nunca aparece para cliente;
- alteração de preço deve gerar auditoria;
- produto com pedido associado não deve ser excluído fisicamente.

### 7.3. Imagens

Decisão oficial:

```txt
Usar Azure Blob Storage.
```

Regras:

- banco guarda apenas metadados/path/URL;
- não salvar binário da imagem no PostgreSQL;
- validar tipo e tamanho do arquivo;
- produto pode ter imagem principal;
- produto pode ter imagens adicionais simples;
- apenas uma imagem principal ativa por produto.

### 7.4. Estoque

Estoque é crítico e deve ser auditável.

Modelo conceitual:

```txt
Product 1 ─── 1 Inventory
Product 1 ─── N InventoryMovement
```

Regras obrigatórias:

- estoque não deve ser apenas campo simples em Produto;
- todo produto vendável deve ter Inventory;
- controlar quantidade disponível;
- controlar quantidade reservada;
- controlar estoque mínimo;
- toda entrada, saída, ajuste, reserva, baixa e liberação deve gerar movimento;
- ajuste manual exige motivo e usuário autorizado;
- não permitir estoque disponível negativo;
- carrinho não reserva estoque;
- pedido criado reserva estoque;
- pagamento aprovado transforma reserva em baixa definitiva;
- pagamento recusado, expirado ou cancelado libera reserva;
- cancelamento libera/devolve estoque conforme estágio do pedido.

Tipos de movimentação previstos:

```txt
INBOUND
OUTBOUND
RESERVATION
RESERVATION_RELEASE
SALE_CONFIRMATION
MANUAL_ADJUSTMENT
RETURN
CANCEL_RELEASE
```

### 7.5. Carrinho

Regras:

- cliente deve ter no máximo um carrinho ativo;
- produto inativo ou indisponível não pode ser adicionado;
- quantidade deve ser maior que zero;
- quantidade não pode exceder estoque disponível;
- subtotal do carrinho é informativo;
- preço final deve ser recalculado no checkout;
- antes de criar pedido, backend deve revalidar preço, produto e estoque;
- carrinho convertido não pode ser alterado.

Status previstos:

```txt
ACTIVE
CONVERTED
ABANDONED
EXPIRED
```

### 7.6. Pedido

Status MVP:

```txt
AGUARDANDO_PAGAMENTO
PAGAMENTO_CONFIRMADO
PENDENTE_SEPARACAO
EM_SEPARACAO
SEPARADO
AGUARDANDO_DESPACHO
ENVIADO
DISPONIVEL_RETIRADA
RETIRADO
ENTREGUE
NAO_ENTREGUE
CANCELADO
PAGAMENTO_RECUSADO
PAGAMENTO_EXPIRADO
```

Regras obrigatórias:

- pedido deve ter número único;
- pedido deve ter ao menos um item;
- pedido deve salvar snapshot de item, preço, custo e endereço;
- pedido criado pelo site tem origem `SITE`;
- pedido criado por orçamento aprovado tem origem `QUOTE`;
- toda mudança de status gera histórico;
- transições inválidas devem ser bloqueadas no backend;
- pedido cancelado não volta ao fluxo normal;
- pedido entregue encerra o fluxo operacional normal;
- pedido só entra em separação após pagamento confirmado/aprovado.

Origens previstas:

```txt
SITE
QUOTE
INTERNAL
REORDER
```

### 7.7. Pagamento com Mercado Pago

Decisão oficial:

```txt
Mercado Pago Checkout Pro com checkout redirecionado.
```

Fluxo obrigatório:

1. Cliente confirma pedido.
2. Backend cria pedido como `AGUARDANDO_PAGAMENTO`.
3. Backend reserva estoque.
4. Backend cria preferência no Mercado Pago.
5. Frontend redireciona cliente para Checkout Pro.
6. Mercado Pago envia webhook.
7. Backend valida evento.
8. Backend consulta API Mercado Pago para confirmar status real.
9. Backend atualiza pagamento.
10. Backend atualiza pedido.
11. Backend baixa/libera estoque.
12. Backend registra histórico/auditoria.

Regras críticas:

- nunca confiar apenas no retorno do navegador;
- nunca confiar cegamente no payload do webhook;
- consultar API Mercado Pago antes de confirmar status crítico;
- webhook deve ser idempotente;
- evento duplicado não pode duplicar baixa de estoque;
- reconsulta manual no backoffice deve seguir a mesma lógica idempotente;
- falha de e-mail/notificação não pode quebrar confirmação de pagamento.

Status internos de pagamento:

```txt
CREATED
PENDING
APPROVED
REJECTED
CANCELLED
EXPIRED
REFUNDED
CHARGEBACK
```

Mapeamento inicial:

- `APPROVED` → pedido vai para `PENDENTE_SEPARACAO`;
- `PENDING` → pedido permanece aguardando confirmação;
- `REJECTED` → pedido vai para `PAGAMENTO_RECUSADO`;
- `EXPIRED` → pedido vai para `PAGAMENTO_EXPIRADO` e libera reserva;
- `CANCELLED` → liberar reserva ou tratar conforme estágio;
- `REFUNDED` e `CHARGEBACK` são v1.1/fluxos posteriores, salvo necessidade operacional explícita.

Proibido no MVP:

- checkout transparente;
- salvar cartão;
- split;
- assinatura;
- múltiplos gateways ativos;
- reembolso automático completo;
- conciliação financeira avançada.

### 7.8. Separação

Regras:

- apenas pedido pago/confirmado entra na separação;
- iniciar separação registra responsável e horário;
- cada item do pedido deve gerar checklist;
- cada item conferido registra usuário e horário;
- pedido não pode ir para `SEPARADO` com item pendente;
- conclusão da separação registra horário final;
- mudança de status gera histórico.

### 7.9. Despacho e entrega

Modalidades MVP:

```txt
STORE_PICKUP
LOCAL_MOTOBOY
POST_OFFICE
CARRIER
MANUAL_COMBINED
```

Regras:

- pedido precisa estar separado antes do despacho;
- retirada registra quem retirou e horário;
- entrega registra data/hora;
- não entrega exige motivo;
- transportadora/Correios no MVP é manual;
- código de rastreio é opcional;
- integração automática de frete fica fora do MVP.

### 7.10. Orçamentos

Status:

```txt
SOLICITADO
EM_ANALISE
AGUARDANDO_CLIENTE
APROVADO
RECUSADO
EXPIRADO
CONVERTIDO_EM_PEDIDO
```

Regras:

- cliente pode solicitar orçamento com descrição livre;
- orçamento pode ter produtos cadastrados e itens personalizados;
- item personalizado exige descrição;
- proposta precisa ter validade;
- orçamento expirado não pode ser aprovado;
- cliente precisa aprovar antes de virar pedido;
- orçamento aprovado deve gerar um único pedido;
- pedido originado de orçamento deve preservar itens personalizados;
- orçamento convertido não pode gerar pedido duplicado.

### 7.11. Cancelamento e reembolso manual

MVP contempla cancelamento básico e registro de pendência manual de reembolso.

Regras:

- cliente pode solicitar cancelamento;
- apenas Admin/Gestor cancela efetivamente;
- cancelamento exige motivo;
- pedido entregue não deve ser cancelado pelo fluxo simples do MVP;
- cancelamento trata estoque conforme estágio;
- se pedido pago for cancelado, registrar pendência de reembolso manual;
- não executar reembolso automático no MVP;
- pedido cancelado não volta ao fluxo normal;
- cancelamento gera auditoria.

### 7.12. Relatórios

Relatórios MVP:

- vendas por período;
- total vendido;
- quantidade de pedidos;
- pedidos por status;
- pedidos cancelados;
- produtos mais vendidos;
- produtos com estoque baixo;
- margem estimada por pedido;
- faturamento bruto simples;
- custo estimado dos produtos vendidos.

Regras:

- financeiro do MVP é gerencial, não contábil/fiscal;
- cancelados não inflam faturamento realizado;
- margem usa snapshot de custo do pedido;
- se custo não existir, indicar margem incompleta;
- filtros por período são obrigatórios ou devem ter padrão seguro.

Proibido no MVP:

- DRE;
- fluxo de caixa completo;
- BI avançado;
- data warehouse;
- conciliação financeira completa.

### 7.13. Auditoria

Auditoria é obrigatória nos eventos críticos.

Registrar:

- alteração de preço;
- entrada/saída/ajuste de estoque;
- reserva/liberação/baixa de estoque;
- mudança de status de pedido;
- confirmação/alteração de pagamento;
- cancelamento;
- ações administrativas relevantes.

Atores:

```txt
CUSTOMER
INTERNAL_USER
SYSTEM
```

Regras:

- auditoria deve registrar ator, ação, entidade, ID, data/hora e mudança relevante;
- não armazenar senha, token ou payload sensível desnecessário;
- webhooks/processos automáticos devem usar ator `SYSTEM`.

---

## 8. Backlog e sprints oficiais

O backlog foi planejado com:

- 16 épicos;
- 80 histórias;
- 185 subtarefas.

Sprints oficiais:

```txt
S00 Base técnica
S01 Infra
S02 Segurança
S03 Catálogo
S04 Imagens
S05 Estoque
S06 Pedido
S07 Pagamento
S08 Backoffice
S09 Operação
S10 Orçamentos
S11 Relatórios
S12 Exceções
S13 Homologação
S14 Produção
```

## Regra para agentes

Quando receber uma tarefa, o agente deve identificar a qual história/subtarefa do Jira ela pertence, se possível.

Se a tarefa não corresponder a nenhuma história planejada, o agente deve alertar:

```txt
Esta tarefa parece estar fora do backlog planejado do MVP. Confirmar antes de implementar.
```

---

## 9. Regras de execução para agentes

Antes de modificar código, o agente deve:

1. Ler este documento.
2. Inspecionar a estrutura atual do repositório.
3. Identificar o módulo impactado.
4. Confirmar se a tarefa pertence ao escopo do MVP.
5. Procurar implementações existentes antes de criar novas.
6. Evitar duplicação de classes, services, DTOs, hooks ou componentes.
7. Planejar a alteração em passos pequenos.
8. Implementar somente o necessário para a tarefa.
9. Adicionar ou ajustar testes quando aplicável.
10. Executar validações disponíveis.
11. Reportar claramente o que foi alterado, testado e o que ficou pendente.

## Quando houver dúvida

Se a dúvida for de regra de negócio, arquitetura, segurança, pagamento, estoque ou infraestrutura, o agente deve **parar e perguntar**.

Não deve “decidir por conta própria” em temas críticos.

Exemplos de dúvidas que exigem validação humana:

- criar nova integração externa;
- alterar status de pedido;
- mudar regra de estoque;
- alterar fluxo de pagamento;
- trocar gateway;
- adicionar fila/mensageria;
- adicionar serviço Azure novo;
- criar campo sensível novo;
- mudar permissões;
- remover auditoria;
- simplificar validação crítica;
- alterar o modelo de pedido/pagamento/estoque.

---

## 10. Padrões de implementação backend

### Controllers

- Controllers devem ser finos.
- Não colocar regra de negócio diretamente no controller.
- Usar request/response DTOs.
- Não retornar entidade JPA diretamente.

### Services/use cases

- Devem coordenar fluxo de aplicação.
- Regras críticas podem ficar em domain policies quando fizer sentido.
- Operações críticas devem ser transacionais.

### Repositories

- Devem encapsular acesso ao banco.
- Consultas com paginação quando retornarem listas.
- Evitar N+1.
- Usar índices quando necessário.

### Validação

- Usar Jakarta Validation nos DTOs.
- Validar também regras de negócio no service/domain.
- Não confiar em validação apenas no frontend.

### Migrations

- Toda alteração de banco deve ter migration Flyway.
- Não alterar banco manualmente sem migration.
- Não criar migration destrutiva sem aprovação.
- Preservar compatibilidade com dados existentes sempre que possível.

### Testes

Adicionar testes para:

- regra crítica de domínio;
- transição de status;
- estoque;
- pagamento;
- idempotência;
- permissões;
- validações importantes.

---

## 11. Padrões de implementação frontend

- Usar TypeScript com tipos claros.
- Usar services para chamadas HTTP.
- Separar componentes de UI de regras de integração quando possível.
- Não duplicar lógica crítica do backend como única proteção.
- Implementar guards para rotas privadas.
- Tratar loading, empty state e erro.
- Não expor dados internos ao cliente.
- Não exibir preço de compra fora do backoffice autorizado.
- Não criar telas sofisticadas antes de concluir o fluxo funcional.

---

## 12. Infraestrutura e secrets

Regras:

- não versionar secrets;
- usar variáveis de ambiente;
- usar GitHub Secrets em pipelines;
- usar App Settings/Container Secrets na Azure;
- Key Vault só se aprovado/viável;
- configurar budget/custo quando criar recursos;
- usar menor SKU possível no MVP;
- não criar serviços Azure extras sem necessidade.

---

## 13. Definition of Done

Uma tarefa só deve ser considerada concluída quando:

- implementa exatamente o escopo solicitado;
- não cria funcionalidade fora do backlog;
- respeita arquitetura e módulos existentes;
- possui validações backend;
- possui migrations se alterou banco;
- possui testes quando aplicável;
- não expõe dados sensíveis;
- não quebra fluxos existentes;
- build/lint/testes relevantes foram executados ou a impossibilidade foi explicada;
- documentação foi atualizada quando necessário;
- pendências foram explicitadas.

---

## 14. Comandos de validação

O agente deve preferir os comandos já existentes no repositório.

### Backend

Se o projeto usar Maven:

```bash
./mvnw clean test
```

ou:

```bash
mvn clean test
```

Se houver profile específico, verificar README antes.

### Frontend

```bash
npm install
npm run lint
npm run build
```

Se o projeto usar `npm ci`, preferir:

```bash
npm ci
npm run lint
npm run build
```

### Observação

Não inventar comandos se o repositório já tiver scripts definidos. Verificar `README.md`, `package.json`, `pom.xml` e workflows do GitHub Actions.

---

## 15. Padrão de resposta esperado do agente

Ao finalizar uma tarefa, o agente deve responder com:

```txt
Resumo:
- ...

Arquivos alterados:
- ...

Validações executadas:
- ...

Riscos/observações:
- ...

Pendências:
- ...

Sugestão de commit:
tipo: mensagem
```

## Padrão de commit

Usar mensagens em português.

Exemplos:

```txt
feat: configurar base inicial do backend com Java 25 e Spring Boot
feat: implementar cadastro de cliente com aceite de termos
fix: corrigir validação de estoque na criação do pedido
refactor: isolar integração do Mercado Pago em client dedicado
test: adicionar testes para reserva e liberação de estoque
docs: registrar decisões arquiteturais iniciais do projeto
ci: configurar pipeline de validação do backend
```

---

## 16. Prompt recomendado para usar com agentes

Use este modelo ao pedir uma tarefa:

```txt
Contexto obrigatório:
Leia e siga o arquivo AGENTS.md do projeto Casa de Oxalá antes de alterar qualquer código.

Tarefa:
[descreva a tarefa específica]

Referência Jira:
[ex: H-01 / ST-H01-01]

Regras:
- Não implemente nada fora do escopo solicitado.
- Não tome decisão arquitetural sem perguntar.
- Não adicione dependências ou serviços externos sem justificar e pedir validação.
- Respeite a arquitetura monólito modular.
- Respeite Java 25, Spring Boot 4, Next.js, PostgreSQL e Azure.
- Adicione/ajuste testes quando aplicável.
- Ao final, informe arquivos alterados, validações executadas e sugestão de commit em português.
```

---

## 17. Critérios para bloquear uma tarefa

O agente deve bloquear e pedir validação antes de continuar se a tarefa exigir:

- mudar arquitetura;
- criar microsserviço;
- criar serviço Azure novo não planejado;
- alterar fluxo de pagamento;
- alterar política de estoque;
- mudar status de pedido;
- alterar permissões;
- adicionar gateway;
- implementar WhatsApp Business API;
- implementar checkout transparente;
- implementar emissão fiscal;
- implementar integração logística automática;
- remover auditoria;
- remover validação de segurança;
- armazenar imagem no banco;
- versionar secrets.

---

## 18. Resumo das decisões inegociáveis

```txt
Arquitetura: monólito modular
Backend: Java 25 + Spring Boot 4
Frontend: Next.js + TypeScript
Banco: PostgreSQL
Cloud: Azure
Imagens: Azure Blob Storage
Pagamento: Mercado Pago Checkout Pro
Migrations: Flyway
Segurança: Spring Security + JWT/controle equivalente
Autorização: RBAC simples
Perfis: ADMIN, GESTOR, ATENDENTE, OPERACAO
Estoque: Inventory + InventoryMovement
Pedido: snapshot de itens, preço, custo e endereço
Pagamento: webhook + consulta confirmatória
Auditoria: obrigatória em eventos críticos
WhatsApp: apenas link/mensagem pré-formatada no MVP
Frete: retirada, motoboy/local e manual no MVP
```

---

## 19. Frase de segurança para o agente

Antes de implementar, confirme mentalmente:

```txt
Estou implementando exatamente a tarefa solicitada, dentro do MVP planejado, sem inventar escopo, sem mudar arquitetura e sem quebrar regras críticas de domínio?
```

Se a resposta não for claramente “sim”, pare e peça orientação.
