# Variaveis do GitHub Actions (Challenge 03)

Configure em **Settings > Secrets and variables > Actions**.

## Actions Variables (obrigatorias)
- `AWS_REGION`: regiao AWS.
- `LAMBDA_IMAGE_URI`: URI da imagem container da Lambda (ECR).
- `NAME_VALUE`: valor da env `NAME` usada na app.
- `ECR_REPOSITORY`: repositorio ECR para build/push (pipeline app).
- `EKS_CLUSTER_NAME`: cluster EKS alvo (pipeline app).
- `K8S_NAMESPACE`: namespace de deploy (pipeline app).
- `DEPLOYMENT_NAME`: nome do Deployment/Service K8s (pipeline app).
- `STG_NAME`: valor de `NAME` para ambiente staging (pipeline ci-cd existente).
- `PROD_NAME`: valor de `NAME` para ambiente prod (pipeline ci-cd existente).

## Actions Secrets (obrigatorias)
- `AWS_ROLE_TO_ASSUME`: ARN da role para ECR/EKS/Lambda/Terraform.
