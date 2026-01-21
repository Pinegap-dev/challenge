# Challenge 03 - Documentacao

## Aplicacao
- Endpoint raiz retorna `Hello, <NAME>!`, lendo a variavel de ambiente `NAME` (default `World`).

## Desenvolvimento
- Poetry para deps; lint com ruff e format com black; testes com pytest.
- Pre-commit configurado (`pre-commit install`).
- Dev local: `docker-compose up` (porta 8000), defina `NAME=Local` se quiser.

## Deploy serverless (resumo)
- API Gateway HTTP -> Lambda (container no ECR); aliases `staging` e `prod`.
- Variavel `NAME` por ambiente (env setada no deploy; pode vir de SSM).
- Workflow GitHub Actions `deploy-app.yml` publica imagem, atualiza a Lambda e o alias conforme branch (develop->staging, main->prod).

## Publicacao no GitHub Pages
- Publicar esta pasta via workflow Pages (ex.: acao `actions/upload-pages-artifact` + `actions/deploy-pages`).
- Origem sugerida: branch `gh-pages` gerado automaticamente a partir de `docs/`.
