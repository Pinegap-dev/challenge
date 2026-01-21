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
- ENABLE_EDGE: (opcional) `true/false` para habilitar CloudFront/Route53/ACM/WAF.
- DOMAIN_NAME: (opcional) dominio servido pelo CloudFront (ex.: app.example.com).
- HOSTED_ZONE_ID: (opcional) Hosted Zone ID do Route53 para o dominio.
- ORIGIN_DOMAIN_NAME: (opcional) DNS do origin (ALB/Ingress) para CloudFront.
- ACM_CERTIFICATE_ARN: (opcional) ARN do certificado ACM em us-east-1; deixe vazio para criar automaticamente.
- ENABLE_WAF: (opcional) `true/false` para anexar WAFv2 ao CloudFront.

## Actions Secrets (obrigatorias)
- AWS_ROLE_TO_ASSUME: ARN da role para ECR/EKS/Terraform.
- TF_VAR_DB_PASSWORD: senha do banco Aurora usada pelo Terraform.
