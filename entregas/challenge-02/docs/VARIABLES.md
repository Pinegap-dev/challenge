# Variaveis do GitHub Actions (Challenge 02)

Configure em **Settings > Secrets and variables > Actions**.

## Actions Variables (obrigatorias)
- `AWS_REGION`: regiao AWS.
- `BATCH_JOB_IMAGE`: imagem do worker Batch (URI ECR ou publica).
- `EKS_CLUSTER_NAME`: cluster EKS alvo.
- `K8S_NAMESPACE`: namespace de deploy.
- `API_DEPLOYMENT`: nome do Deployment/Service da API.
- `WEB_DEPLOYMENT`: nome do Deployment/Service do frontend.
- `ECR_API_REPOSITORY`: repositorio ECR para a API (se for buildar no pipeline).
- `ECR_WEB_REPOSITORY`: repositorio ECR para o frontend (se for buildar no pipeline).
- `API_IMAGE`: (opcional) URI já publicada da API; se vazio, o pipeline tenta buildar.
- `WEB_IMAGE`: (opcional) URI já publicada do frontend; se vazio, o pipeline tenta buildar.

## Actions Secrets (obrigatorias)
- `AWS_ROLE_TO_ASSUME`: ARN da role para ECR/EKS/Terraform.
- `TF_VAR_DB_PASSWORD`: senha do banco Aurora usada pelo Terraform.
