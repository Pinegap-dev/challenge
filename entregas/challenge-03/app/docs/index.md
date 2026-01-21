# Challenge 03 - Documentacao

## Aplicacao
- Endpoint raiz retorna `Hello, <NAME>!`, lendo a variavel de ambiente `NAME` (default `World`).

## Desenvolvimento
- Poetry para deps; lint com ruff e format com black; testes com pytest.
- Pre-commit configurado (`pre-commit install`).
- Dev local: `docker-compose up` (porta 8000), defina `NAME=Local` se quiser.

## Deploy serverless (resumo)
- API Gateway HTTP -> Lambda (container no ECR); aliases `staging` e `prod`.
- Variavel `NAME` por ambiente (SSM ou env).
- Workflow GitHub Actions `ci-cd.yml` publica imagem e atualiza aliases/stages conforme branch.

## Publicacao no GitHub Pages
- Publicar esta pasta via workflow Pages (ex.: acao `actions/upload-pages-artifact` + `actions/deploy-pages`).
- Origem sugerida: branch `gh-pages` gerado automaticamente a partir de `docs/`.
