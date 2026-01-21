# Variaveis do GitHub Actions (Challenge 01)

Use estes nomes exatamente em **Settings > Secrets and variables > Actions** do repositório.

## Actions Variables (obrigatorias)
- `AWS_REGION`: regiao AWS (ex.: `us-east-1`).
- `TASK_IMAGE`: URI ECR da imagem FastAPI usada pelo Terraform.
- `ECR_REPOSITORY`: repositorio ECR para build/push da app (`deploy-app.yml`).
- `EKS_CLUSTER_NAME`: nome do cluster EKS alvo do deploy.
- `K8S_NAMESPACE`: namespace onde a app roda.
- `DEPLOYMENT_NAME`: nome do Deployment/Service Kubernetes.
- `ADMIN_SECRET_NAME`: nome do Secret Kubernetes com credenciais admin.
- `PROJECT`: (opcional) prefixo usado na IaC (default: challenge01).

## Actions Secrets (obrigatorias)
- `AWS_ROLE_TO_ASSUME`: ARN da role com permissao em ECR/EKS/Terraform.
- `ADMIN_USER`: usuário admin para a API.
- `ADMIN_PASS`: senha admin para a API.
