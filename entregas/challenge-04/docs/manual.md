# Manual de provisionamento - Challenge 04 (Next.js + FastAPI + Batch/Step Functions)

## Prerequisitos
1) AWS CLI configurado; Terraform >= 1.6.
2) Docker para buildar imagens (Next.js, FastAPI, Batch).
3) Planejar DNS/ACM/WAF (se usar CloudFront/ALB) e definir se o modulo `edge` sera habilitado.

## Visao geral
- IaC modular em `entregas/challenge-04/iac/`:
  - `main.tf` consome modulos `network`, `kms`, `s3`, `ecr`, `rds`, `eks`, `batch_sfn` localizados em `iac/modules/`.
  - Modulo opcional `edge` para CloudFront/Route53/ACM/WAF (habilitado com variavel `enable_edge` e preenchendo dominio/hosted zone/origin).
- Cobertura: VPC multi-AZ, sub-redes pub/priv, SGs, buckets com lifecycle (365d uploads, 5y resultados) e SSE-KMS, ECR, Aurora Postgres, EKS, Batch+Step Functions.
- Pendentes: borda (CloudFront/WAF/Route53/ALB) e pipelines CI/CD.

## Passo a passo (Terraform base)
1) Ajustar variaveis em `iac/main.tf`:
- `db_password`, `region`, `environment`, `batch_job_image`, tamanhos (RDS classe, node group), tags.
- Opcional edge: `enable_edge`, `domain_name`, `hosted_zone_id`, `origin_domain_name`, opcional `acm_certificate_arn`, `enable_waf`.
2) Executar:
   ```bash
   cd entregas/challenge-04
   terraform init
   terraform plan -var 'environment=hml'
   terraform apply -var 'environment=hml' -auto-approve
   ```
   Outputs: VPC/subnets, buckets, Aurora endpoint, EKS cluster, Batch queue, State Machine.
3) Repetir para `environment=prod` com state/workspace separado.

## Imagens e deploy app
1) Build/push imagens:
   - Front Next.js (estatico/ISR) -> ECR frontend.
   - API FastAPI -> ECR api.
   - Batch worker -> ECR batch (ou use image setada em `batch_job_image`).
2) EKS:
   - Instalar ALB Ingress Controller, Cluster Autoscaler, habilitar IRSA.
   - Deploy FastAPI via Helm/manifests; criar Ingress apontando para ALB.
3) Front:
   - Se estatico: build e deploy para S3 + CloudFront (adicionar IaC para S3 static + distro).
   - Se Next.js SSR/ISR: usar CloudFront + Lambda@Edge ou App Runner/ECS; ajustar IaC conforme modelo escolhido.

## Banco de dados
1) Usar endpoint do Aurora (output `rds_endpoint`); guardar credenciais em Secrets Manager/SSM.
2) Conceder acesso aos pods via SG (já configurado para EKS nodes).

## Batch/Step Functions
1) Atualizar Job Definition com a imagem do worker se diferir do `batch_job_image`.
2) Conceder permissao IAM (IRSA) na API para invocar `states:StartExecution` e ler S3.

## Observabilidade
1) Logs: awslogs para pods/Batch; CloudWatch groups.
2) Metricas: Prometheus/Grafana no EKS ou CloudWatch Container Insights.
3) Alarms: 5xx/latencia ALB, CPU/mem EKS, conexoes RDS, fila/idade Batch, erros Step Functions.

## Borda (to-do)
1) CloudFront + WAF + Route53 + ACM:
   - Criar distro CF apontando para S3 static ou ALB.
   - Certificado ACM em us-east-1 (para CF).
   - WAF com regras gerenciadas + rate limit.
2) ALB HTTPS: listener 443 com ACM; opcional redirecionar 80 -> 443.

## CI/CD (to-do)
1) Pipelines GitHub Actions:
   - `terraform plan/apply` por ambiente.
   - Build/push imagens frontend/api/batch.
   - Deploy manifests no EKS (kubectl/Helm/ArgoCD).
2) Gates: approvals para prod; escanear imagens (ECR scan) e tfsec/checkov opcional.

## Validacao
1) Acessar endpoints (frontend e API) via CF/ALB; health checks ok.
2) Submeter upload e acionar pipeline Batch via API; conferir resultados em S3.
3) Verificar alarms/logs/metrics; testar escalabilidade (HPA e autoscaling de nodes).
