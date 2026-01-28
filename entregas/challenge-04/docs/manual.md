# Provisioning Manual - Challenge 04 (Next.js + FastAPI + Batch/Step Functions)

## Prerequisites
1) AWS CLI configured; Terraform >= 1.6.  
2) Docker to build images (Next.js, FastAPI, Batch).  
3) Plan DNS/ACM/WAF (if using CloudFront/ALB) and decide whether the `edge` module will be enabled.

## Overview
- Modular IaC in `entregas/challenge-04/iac/`:
  - `main.tf` consumes modules `network`, `kms`, `s3`, `ecr`, `rds`, `eks`, `batch_sfn` located in `iac/modules/`.
  - Optional `edge` module for CloudFront/Route53/ACM/WAF (enabled with `enable_edge` and filling domain/hosted zone/origin).
- Coverage: multi-AZ VPC, public/private subnets, SGs, buckets with lifecycle (365d uploads, 5y results) and SSE-KMS, ECR, Aurora Postgres, EKS, Batch+Step Functions.
- Pending: edge (CloudFront/WAF/Route53/ALB) and CI/CD pipelines.

## Step by step (Terraform base)
1) Adjust variables in `iac/main.tf`:
- `db_password`, `region`, `environment`, `batch_job_image`, sizes (RDS class, node group), tags.
- Optional edge: `enable_edge`, `domain_name`, `hosted_zone_id`, `origin_domain_name`, optional `acm_certificate_arn`, `enable_waf`.
2) Run:
   ```bash
   cd entregas/challenge-04
   terraform init
   terraform plan -var 'environment=hml'
   terraform apply -var 'environment=hml' -auto-approve
   ```
   Outputs: VPC/subnets, buckets, Aurora endpoint, EKS cluster, Batch queue, State Machine.
3) Repeat for `environment=prod` with separate state/workspace.

## Images and app deploy
1) Build/push images:
   - Next.js front (static/ISR) -> frontend ECR.
   - FastAPI API -> API ECR.
   - Batch worker -> Batch ECR (or use image set in `batch_job_image`).
2) EKS:
   - Install ALB Ingress Controller, Cluster Autoscaler, enable IRSA.
   - Deploy FastAPI via Helm/manifests; create Ingress pointing to ALB.
3) Front:
   - If static: build and deploy to S3 + CloudFront (add IaC for static S3 + distro).
   - If Next.js SSR/ISR: use CloudFront + Lambda@Edge or App Runner/ECS; adjust IaC for chosen model.

## Database
1) Use the Aurora endpoint (output `rds_endpoint`); store credentials in Secrets Manager/SSM.  
2) Grant pod access via SG (already configured for EKS nodes).

## Batch/Step Functions
1) Update Job Definition with the worker image if different from `batch_job_image`.  
2) Grant IAM permission (IRSA) for the API to call `states:StartExecution` and read S3.

## Observability
1) Logs: awslogs for pods/Batch; CloudWatch groups.  
2) Metrics: Prometheus/Grafana on EKS or CloudWatch Container Insights.  
3) Alarms: ALB 5xx/latency, EKS CPU/mem, RDS connections, Batch queue/age, Step Functions errors.

## Edge (to-do)
1) CloudFront + WAF + Route53 + ACM:
   - Create CF distro pointing to static S3 or ALB.
   - ACM cert in us-east-1 (for CF).
   - WAF with managed rules + rate limit.
2) ALB HTTPS: listener 443 with ACM; optional redirect 80 -> 443.

## CI/CD (to-do)
1) GitHub Actions pipelines:
   - `terraform plan/apply` per environment.
   - Build/push frontend/api/batch images.
   - Deploy manifests to EKS (kubectl/Helm/ArgoCD).
2) Gates: approvals for prod; scan images (ECR scan) and tfsec/checkov optional.

## Validation
1) Access endpoints (frontend and API) via CF/ALB; health checks ok.  
2) Submit upload and trigger Batch pipeline via API; verify results in S3.  
3) Check alarms/logs/metrics; test scalability (HPA and node autoscaling).
