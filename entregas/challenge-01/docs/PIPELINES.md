# Pipelines de deploy (Challenge 01)

Arquivos: `.github/workflows/deploy-iac.yml` (infra) e `.github/workflows/deploy-app.yml` (aplicação). Ambos rodam no GitHub Actions com AWS.

## deploy-iac.yml (IaC Terraform)
- **Caminho IaC:** `technical-challenges/entregas/challenge-01/iac`.
- **O que faz:** `terraform init/fmt/validate/plan/apply` para criar VPC em 2 AZ, ALB público e serviço ECS Fargate da FastAPI. Escolhe ambiente `hml` (develop) ou `prod` (main) ou manual. Gera `apply.fvars` no workflow.
- **Segredos/vars:** `AWS_ROLE_TO_ASSUME` (obrigatório), `ADMIN_USER`/`ADMIN_PASS` (obrigatórios), `TASK_IMAGE` (imagem inicial do serviço), opcional `PROJECT`.
- **Gatilhos:** push em `main`/`develop` que toquem `entregas/challenge-01/**` ou disparo manual.
- **Saída:** infra aplicada e outputs no log (DNS do ALB, nome do service).

## deploy-app.yml (Aplicação em ECS Fargate)
- **Caminho app:** `technical-challenges/entregas/challenge-01/app` (Dockerfile da FastAPI). Cópia de referência permanece em `devops/challenge-01`.
- **O que faz:** builda imagem, faz push no ECR e atualiza o service ECS registrando nova task definition com a imagem gerada.
- **Fluxo:** login AWS/ECR → build/push → ler task definition atual do service → trocar a imagem do container (`CONTAINER_NAME`, padrão `fastapi`) → registrar nova task definition → `update-service --force-new-deployment`.
- **Segredos/vars:** `AWS_ROLE_TO_ASSUME` (obrigatório), `AWS_REGION`, `ECR_REPOSITORY`, `ECS_CLUSTER_NAME`, `ECS_SERVICE_NAME`, opcional `CONTAINER_NAME`.
- **Gatilhos:** push em `main`/`develop` que atinjam `devops/challenge-01` ou `entregas/challenge-01`, ou manual. Ambiente `staging` (develop) e `prod` (main) por padrão.
