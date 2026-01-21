# IaC modular para Next.js + FastAPI + Batch/Step Functions (Challenge 04)

Objetivo: entregar a base de IaC em Terraform (modular) para o cenário Next.js frontend + API FastAPI + pipeline Batch/Step Functions na AWS, com buckets S3, Aurora, ECR, EKS e rede completa.

## Modulos/arquitetura (alto nivel)
- `modules/network`: VPC multi-AZ, sub-redes pub/priv, NAT, IGW, rotas, SGs (ALB/EKS/RDS).
- `modules/kms` + `modules/s3`: chave KMS e buckets uploads (365d) e resultados (5y) com SSE-KMS e block public.
- `modules/ecr`: repos ECR para frontend, api e batch (scan on push).
- `modules/rds`: Aurora Postgres multi-AZ criptografado.
- `modules/eks`: cluster EKS + node group base com roles/attachments.
- `modules/batch_sfn`: Batch (Fargate/EC2) + Step Functions para orquestracao de jobs.

## Fase 0 - Preparacao
1) Requisitos: AWS CLI, Terraform >= 1.6, Docker se for buildar imagens.
2) Definir estrategia de borda (ALB/CloudFront/WAF/Route53) e modelo do Next.js (static vs SSR/ISR).
3) Clonar repo e criar branch pessoal.

## Fase 1 - Configurar e aplicar Terraform
1) Diretorio: `entregas/challenge-04/`.
2) Ajustar variaveis em `main.tf`: `db_password`, `region`, `environment`, `batch_job_image`, classes de RDS/node group, tags.
3) Executar por ambiente (ex. hml):
   ```bash
   terraform init
   terraform plan -var 'environment=hml'
   terraform apply -var 'environment=hml' -auto-approve
   ```
4) Outputs: VPC/subnets, buckets, chave KMS, ECR URIs, Aurora endpoint, EKS cluster, Batch queue/State Machine.
5) Repetir para `prod` em state/workspace separado.

## Fase 2 - Imagens e deploy das apps
1) Build/push imagens:
   - Front Next.js -> ECR frontend (static ou SSR conforme estrategia).
   - API FastAPI -> ECR api.
   - Batch worker -> ECR batch (ou imagem apontada em `batch_job_image`).
2) EKS:
   - Instalar ALB Ingress Controller, Cluster Autoscaler, habilitar IRSA.
   - Deploy FastAPI via Helm/manifests, criar Ingress -> ALB.
3) Front:
   - Se static: S3 + CloudFront (adicionar IaC para bucket static + distro).
   - Se SSR/ISR: CloudFront + ALB/App Runner/ECS (estender IaC).

## Fase 3 - Batch/Step Functions
1) Validar Job Definition usa a imagem correta e recursos (vCPU/mem, retries, timeout).
2) Garantir permissoes IAM (IRSA) para a API invocar `states:StartExecution` e acessar S3.
3) Testar execucao fim-a-fim (upload -> execucao -> resultado no bucket de saida).

## Fase 4 - DNS, TLS e WAF (pendente/ajuste)
1) Route53 + ACM + WAF:
   - Certificado ACM (us-east-1 se usar CloudFront).
   - Distro CloudFront e/ou ALB HTTPS (listener 443; redirect 80 -> 443).
   - WAF com regras gerenciadas + rate limit.

## Fase 5 - Observabilidade
1) Logs: awslogs para pods/Batch; grupos CloudWatch dedicados.
2) Metricas: Prometheus/Grafana via EKS add-ons ou CloudWatch Container Insights.
3) Alarms: 5xx/latencia ALB, CPU/mem EKS, conexoes RDS, idade/fila Batch, falhas Step Functions.

## Fase 6 - CI/CD (a implementar)
1) Pipelines GitHub Actions:
   - `terraform plan/apply` por ambiente (hml/prod) com approvals.
   - Build/push das imagens frontend/api/batch.
   - Deploy dos manifests no EKS (kubectl/Helm/ArgoCD).
2) Checkov/tfsec e scan de imagens ECR habilitados.

## Fase 7 - Validacao
1) Acessar endpoints frontend/API via CF/ALB; health checks ok.
2) Executar pipeline Batch/Step Functions e conferir resultados no bucket.
3) Revisar alarms/logs/metricas e testes de resiliencia (falha de job, HPA, autoscaling).
