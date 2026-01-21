# Pipelines (Challenge 03)

Arquivos: `.github/workflows/deploy-iac.yml` (infra Lambda/API Gateway) e `.github/workflows/deploy-app.yml` (aplicaÇõÇœo serverless).

## deploy-iac.yml (IaC Terraform)
- **Caminho IaC:** `technical-challenges/entregas/challenge-03/iac`.
- **O que faz:** init/fmt/validate/plan/apply do Terraform que cria Lambda + API Gateway. Seleciona `hml` (develop) ou `prod` (main) ou manual. Usa var-file gerado no pipeline (`apply.fvars`).
- **Segredos/vars:** `AWS_ROLE_TO_ASSUME` (obrigatÇürio), `AWS_REGION`, `PROJECT` (opcional) e campos do `apply.fvars`.
- **Gatilhos:** push em `main`/`develop` que atinjam `entregas/challenge-03`, ou manual.
- **SaÇðda esperada:** state aplicado com Lambda/API Gateway conforme o Terraform.

## deploy-app.yml (AplicaÇõÇœo serverless)
- **Caminho app:** `technical-challenges/entregas/challenge-03/app` (Dockerfile builda a app Flask).
- **O que faz:** lint/test (ruff, black, pytest) → build/push imagem para ECR → `aws lambda update-function-code` com a imagem → atualiza env `NAME` → cria/atualiza alias por ambiente (`staging`/`prod`).
- **Segredos/vars:** `AWS_ROLE_TO_ASSUME` (obrigatÇürio), `AWS_REGION`, `ECR_REPOSITORY`, `LAMBDA_FUNCTION_NAME`, `NAME_VALUE` ou `NAME_VALUE_STAGING`/`NAME_VALUE_PROD`.
- **Gatilhos:** push em `main`/`develop` que atinjam `entregas/challenge-03`, ou manual (staging default; prod em main).

## Docs (GitHub Pages)
- Workflow `entregas/challenge-03/.github/workflows/docs.yml` publica `entregas/challenge-03/app/docs/` no GitHub Pages (environment github-pages), acionado apenas quando `entregas/challenge-03/app/docs/` (ou o prÇüprio workflow) muda.
