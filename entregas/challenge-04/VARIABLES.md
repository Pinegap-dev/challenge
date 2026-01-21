# Variaveis do GitHub Actions (Challenge 04)

Cadastre em **Settings > Secrets and variables > Actions**.

## Actions Variables (obrigatorias)
- AWS_REGION: regiao AWS.
- BATCH_JOB_IMAGE: imagem do worker Batch (URI ECR ou publica).
- EKS_CLUSTER_NAME: cluster EKS alvo.
- K8S_NAMESPACE: namespace de deploy.
- API_DEPLOYMENT: nome do Deployment/Service da API.
- FRONT_DEPLOYMENT: nome do Deployment/Service do frontend.
- ECR_API_REPOSITORY: repositorio ECR da API (para build no pipeline).
- ECR_FRONT_REPOSITORY: repositorio ECR do frontend (para build no pipeline).
- API_IMAGE: (opcional) URI ja publicada da API; se vazio, pipeline tenta buildar.
- FRONT_IMAGE: (opcional) URI ja publicada do frontend; se vazio, pipeline tenta buildar.

## Actions Secrets (obrigatorias)
- AWS_ROLE_TO_ASSUME: ARN da role para ECR/EKS/Terraform.
- TF_VAR_DB_PASSWORD: senha do banco Aurora usada pelo Terraform.
