# Variaveis do GitHub Actions (Challenge 01)

Use estes nomes exatamente em **Settings > Secrets and variables > Actions** do repositório.

## Actions Variables (obrigatorias)
- `AWS_REGION`: região AWS (ex.: `us-east-1`).
- `TASK_IMAGE`: URI ECR da imagem FastAPI usada pelo Terraform (seed inicial da task definition).
- `ECR_REPOSITORY`: nome do repositório ECR para build/push da app (`deploy-app.yml`).
- `ECS_CLUSTER_NAME`: nome do cluster ECS Fargate criado pelo Terraform.
- `ECS_SERVICE_NAME`: nome do service ECS (ex.: `challenge01-hml-fastapi-svc`).
- `CONTAINER_NAME`: (opcional) nome do container na task definition (padrão `fastapi`).
- `PROJECT`: (opcional) prefixo usado na IaC (default: challenge01).

## Actions Secrets (obrigatorias)
- `AWS_ROLE_TO_ASSUME`: ARN da role com permissão em ECR/ECS/Terraform.
- `ADMIN_USER`: usuário admin para a API (usado na IaC).
- `ADMIN_PASS`: senha admin para a API (usada na IaC).
