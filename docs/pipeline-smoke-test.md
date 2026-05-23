# Pipeline smoke test

Este arquivo foi criado para validar a esteira de CI/CD do backend Casa de Oxalá.

## Objetivo

Validar o fluxo:

1. Criação de branch de teste
2. Pull request para `develop`
3. Execução da CI
4. Merge em `develop`
5. Execução do Auto PR de `develop` para `main`

## Observação

Este arquivo não altera o comportamento da aplicação Java.
