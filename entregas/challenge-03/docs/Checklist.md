# Flask serverless em Lambda + API Gateway (Challenge 03)

Objetivo: publicar a aplicacao Flask (responde `Hello, <NAME>!`) como container de Lambda exposto via API Gateway HTTP API, usando Terraform para infra, ECR para a imagem e GitHub Actions para CI/CD e Docs (GitHub Pages).

## Arquitetura proposta (alto nivel)
- API Gateway HTTP API -> Lambda (container) rodando a app Flask.
- Imagem no Amazon ECR; alias da Lambda para `staging` e `prod`.
- IaC em `entregas/challenge-03/iac/` (modulo `lambda_api`).
- Observabilidade: CloudWatch Logs para a Lambda.

## Fase 0 - Preparacao local e qualidade
1) Requisitos: AWS CLI, Terraform >= 1.6, Docker, git.
2) Validar deps Python/venv se rodar testes.
3) Rodar qualidade local (na raiz `entregas/challenge-03/app/`; copia de referencia em `devops/challenge-03/`):
   ```bash
   pre-commit run --all-files
   pytest
   ```

## Fase 1 - Build e push da imagem
1) Conferir `Dockerfile` em `entregas/challenge-03/app/` (copia em `devops/challenge-03/`).
2) Criar repo ECR (ex.: `challenge-03`) e autenticar:
   ```bash
   aws ecr create-repository --repository-name challenge-03
   aws ecr get-login-password --region <regiao> | docker login --username AWS --password-stdin <registry>
   docker build -t <registry>/challenge-03:latest .
   docker push <registry>/challenge-03:latest
   ```
3) Guardar o URI para usar no Terraform (`lambda_image_uri`) e no workflow.

## Fase 2 - Provisionar infra (Terraform)
1) Diretorio: `entregas/challenge-03/iac/`.
2) Ajustar variaveis: `lambda_image_uri`, `name_value` (valor de `NAME`), `region`, `environment`.
3) Executar:
   ```bash
   terraform init
   terraform plan -var 'environment=staging'
   terraform apply -var 'environment=staging' -auto-approve
   ```
4) Outputs esperados: `api_endpoint`, nomes da Lambda e alias.
5) Repetir para `environment=prod` com variaveis apropriadas.

## Fase 3 - CI/CD (GitHub Actions)
1) Secrets/vars do workflow `.github/workflows/ci-cd.yml`:
   - `AWS_ROLE_TO_ASSUME`, `AWS_REGION`, `ECR_REPOSITORY`, `LAMBDA_FUNCTION_NAME`, `STG_NAME`, `PROD_NAME`.
2) Fluxo:
   - `push` em `develop` -> build/push imagem -> `lambda update-function-code` -> atualizar alias `staging` -> set env `NAME`.
   - `push` em `main` -> mesmo fluxo para alias `prod`.
3) Opcional: gatilhos para pre-commit/pytest e tfsec.

## Fase 4 - Docs (GitHub Pages)
1) Conteudo em `entregas/challenge-03/app/docs/` (`index.md` + `README.md`).
2) Workflow `.github/workflows/docs.yml` publica Pages quando `docs/` mudar na `main`.
3) Conferir que o ambiente `github-pages` esta habilitado no repo.

## Fase 5 - Validacao
1) Chamar o endpoint do API Gateway (`api_endpoint`): `curl <url>/`.
2) Ver logs no CloudWatch; alterar `NAME` e validar resposta.
3) Testar ambos aliases (staging/prod) se configurados.
