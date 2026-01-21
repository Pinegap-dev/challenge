# Manual de provisionamento - Challenge 03 (Flask serverless em Lambda + API Gateway)

## Prerequisitos
1) AWS CLI configurado; Terraform >= 1.6.
2) Docker para buildar imagem da Lambda.
3) GitHub Actions habilitado (OIDC ou chaves) para CI/CD e Pages.

## Visao geral
- Aplicacao Flask simples que retorna `Hello, <NAME>!` (env `NAME`).
- Deploy serverless: API Gateway HTTP API -> Lambda container (imagem no ECR).
- IaC em `entregas/challenge-03/iac/` (modulo `lambda_api`).
- CI/CD em `.github/workflows/ci-cd.yml`; docs Pages em `.github/workflows/docs.yml`.

## Passo a passo (imagem)
1) Ajuste/valide `Dockerfile` em `entregas/challenge-03/app/` (copia de referencia em `devops/challenge-03/`).
2) Criar repo ECR: `aws ecr create-repository --repository-name challenge-03`.
3) Login + build/push:
   ```bash
   aws ecr get-login-password --region <regiao> | docker login --username AWS --password-stdin <registry>
   docker build -t <registry>/challenge-03:latest .
   docker push <registry>/challenge-03:latest
   ```
4) Use o URI como `lambda_image_uri` no Terraform ou vars do workflow.

## Passo a passo (Terraform)
1) No diretorio `entregas/challenge-03/iac/`, ajuste:
   - `lambda_image_uri`, `name_value`, `region`, `environment`.
2) Execute:
   ```bash
   terraform init
   terraform plan -var 'environment=staging'
   terraform apply -var 'environment=staging' -auto-approve
   ```
   Output: `api_endpoint`.
3) Repita para `environment=prod` (variando `name_value` se quiser).

## Passo a passo (CI/CD GitHub Actions)
1) Secrets/vars no repo:
   - `AWS_ROLE_TO_ASSUME`, `AWS_REGION`, `ECR_REPOSITORY` (challenge-03), `LAMBDA_FUNCTION_NAME`, `STG_NAME`, `PROD_NAME`.
2) Workflow `.github/workflows/ci-cd.yml`:
   - `push` em `develop` -> deploy staging (alias `staging`).
   - `push` em `main` -> deploy prod (alias `prod`).
   - Etapas: lint/test (ruff/black/pytest), build/push imagem, `lambda update-function-code`, `lambda update-alias`, set env `NAME`.

## Docs e GitHub Pages
1) Conteudo em `entregas/challenge-03/app/docs/` (`index.md` + `README.md`).
2) Workflow `.github/workflows/docs.yml` publica para Pages ao alterar `docs/` na `main`.
3) Configurar Pages para usar o ambiente `github-pages` do workflow.

## Validacao
1) Chamar o endpoint do API Gateway (output `api_endpoint`): `curl <url>/`.
2) Verificar CloudWatch Logs da Lambda.
3) Alterar `NAME` (var ou SSM) e conferir resposta.
4) Rodar pre-commit local: `pre-commit run --all-files`.
