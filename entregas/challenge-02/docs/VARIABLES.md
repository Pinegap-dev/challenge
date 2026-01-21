# Variaveis do GitHub Actions (Challenge 02)

Configure em **Settings > Secrets and variables > Actions**.

## Actions Variables (obrigatorias)
- `AWS_REGION`: regiao AWS.
- `BATCH_JOB_IMAGE`: imagem do worker Batch (URI ECR ou publica) usada na IaC.
- `PROJECT`: (opcional) prefixo do projeto (default: challenge02). Usado para tags e nomes no Terraform.
- `EKS_CLUSTER_NAME`: cluster EKS alvo.
- `K8S_NAMESPACE`: namespace de deploy.
- `API_DEPLOYMENT`: nome do Deployment/Service da API.
- `WEB_DEPLOYMENT`: nome do Deployment/Service do frontend.
- `ECR_API_REPOSITORY`: repositorio ECR para a API (se for buildar no pipeline).
- `ECR_WEB_REPOSITORY`: repositorio ECR para o frontend (se for buildar no pipeline).
- `API_IMAGE`: (opcional) URI ja publicada da API; se vazio, o pipeline tenta buildar.
- `WEB_IMAGE`: (opcional) URI ja publicada do frontend; se vazio, o pipeline tenta buildar.
- `ENABLE_EDGE`: (opcional) true/false para habilitar CloudFront/Route53/ACM/WAF na IaC. Se true, preencher os campos abaixo.
- `ENABLE_WAF`: (opcional) true/false para anexar WAF ao CloudFront.
- `DOMAIN_NAME`: (opcional) dominio publico (ex.: app.example.com) usado pelo edge.
- `HOSTED_ZONE_ID`: (opcional) hosted zone ID do Route53 para o dominio.
- `ORIGIN_DOMAIN_NAME`: (opcional) DNS do ALB/Ingress que sera origem do CloudFront.
- `ACM_CERTIFICATE_ARN`: (opcional) ARN de certificado existente em us-east-1; se vazio e EDGE habilitado, a IaC solicita novo.
- `ALARM_EMAIL`: (opcional) email para assinar o SNS de alertas (CloudWatch alarms/backup).
- `ROTATION_APP_VERSION`: (opcional) versao do app de rotacao RDS do Serverless App Repo (default 1.1.0).

## Actions Secrets (obrigatorias)
- `AWS_ROLE_TO_ASSUME`: ARN da role para ECR/EKS/Terraform.
- `TF_VAR_DB_PASSWORD`: senha do banco Aurora usada pelo Terraform.
