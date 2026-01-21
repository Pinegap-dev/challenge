# Challenge 04 - IaC modular (Terraform)

Estrutura modular para provisionar o cenário Next.js + FastAPI + Batch/Step Functions na AWS.

## Como usar
1) Ajuste variáveis no `iac/main.tf` (ex.: `db_password`, `region`, `environment`, `batch_job_image`).
2) `cd iac && terraform init && terraform plan -var 'environment=hml'` (ou `prod`).
3) Ajuste tamanhos/classes conforme necessidade (RDS `db.r6g.large`, EKS node `t3.medium`, vCPUs do Batch).

## Módulos (em `iac/modules/`)
- `network`: VPC, sub-redes públicas/privadas, NAT, IGW, rotas, SGs (ALB, EKS, RDS).
- `kms`: chave KMS para S3.
- `s3`: buckets uploads (365d) e resultados (5y) com SSE-KMS e bloqueio público.
- `ecr`: repositórios ECR (frontend, api, batch) com scan on push.
- `rds`: Aurora Postgres multi-AZ, criptografado.
- `eks`: cluster EKS e node group base com roles/attachments.
- `batch_sfn`: Batch Fargate (CE, queue, job def) e Step Functions para orquestração.
- `edge` (opcional via `enable_edge`): CloudFront + Route53 + ACM (us-east-1) + WAF apontando para o origin informado (Ingress/ALB).
