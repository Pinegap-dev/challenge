# Modular IaC for Next.js + FastAPI + Batch/Step Functions (Challenge 04)

Goal: deliver the modular Terraform base for the Next.js frontend + FastAPI API + Batch/Step Functions pipeline on AWS, with S3 buckets, Aurora, ECR, EKS, and full networking.

## Modules/architecture (high level) in `iac/modules/`
- `network`: multi-AZ VPC, public/private subnets, NAT, IGW, routes, SGs (ALB/EKS/RDS).
- `kms` + `s3`: KMS key and buckets for uploads (365d) and results (5y) with SSE-KMS and block public.
- `ecr`: ECR repos for frontend, api, and batch (scan on push).
- `rds`: encrypted Aurora Postgres multi-AZ.
- `eks`: EKS cluster + base node group with roles/attachments.
- `batch_sfn`: Batch (Fargate/EC2) + Step Functions for job orchestration.

## Phase 0 - Preparation
1) Requirements: AWS CLI, Terraform >= 1.6, Docker if building images.  
2) Decide on edge strategy (ALB/CloudFront/WAF/Route53) and Next.js mode (static vs SSR/ISR). If using edge, set `enable_edge` and fill domain/hosted zone/origin.  
3) Clone repo and create a personal branch.

## Phase 1 - Configure and apply Terraform
1) Directory: `entregas/challenge-04/iac/` (modules now under `iac/modules/`).  
2) Adjust variables in `iac/main.tf`: `db_password`, `region`, `environment`, `batch_job_image`, RDS/node group sizes, tags. If using edge: `enable_edge`, `domain_name`, `hosted_zone_id`, `origin_domain_name`, optional `acm_certificate_arn`, `enable_waf`.  
3) Run per environment (e.g., hml):
   ```bash
   cd iac
   terraform init
   terraform plan -var 'environment=hml'
   terraform apply -var 'environment=hml' -auto-approve
   ```
4) Outputs: VPC/subnets, buckets, KMS key, ECR URIs, Aurora endpoint, EKS cluster, Batch queue/State Machine.  
5) Repeat for `prod` with separate state/workspace.

## Phase 2 - Images and app deploy
1) Build/push images:
   - Next.js front -> frontend ECR (static or SSR per strategy).  
   - FastAPI API -> api ECR.  
   - Batch worker -> batch ECR (or image set in `batch_job_image`).  
2) EKS:
   - Install ALB Ingress Controller, Cluster Autoscaler, enable IRSA.  
   - Deploy FastAPI via Helm/manifests, create Ingress -> ALB (use vars `API_HOST`, `FRONT_HOST`, `ALB_CERT_ARN`, `API_BASE_URL`).  
3) Front:
   - If static: S3 + CloudFront (use `edge` module for the distro; add static buckets).  
   - If SSR/ISR: CloudFront + ALB/App Runner/ECS (extend IaC and use `edge` with origin to ALB/Ingress).

## Phase 3 - Batch/Step Functions
1) Validate Job Definition uses the correct image/resources (vCPU/mem, retries, timeout).  
2) Ensure IAM permissions (IRSA) for the API to call `states:StartExecution` and access S3.  
3) Test end-to-end (upload -> execution -> result in output bucket).

## Phase 4 - DNS, TLS, and WAF (edge optional)
1) Route53 + ACM + WAF:
   - ACM cert in us-east-1 via `edge` module or external ARN.  
   - CloudFront distro (`edge` module) and/or ALB HTTPS (listener 443; redirect 80 -> 443).  
   - WAF (optional in `edge`) with managed rules + rate limit.

## Phase 5 - Observability
1) Logs: awslogs for pods/Batch; dedicated CloudWatch groups.  
2) Metrics: Prometheus/Grafana via EKS add-ons or CloudWatch Container Insights.  
3) Alarms: ALB 5xx/latency, EKS CPU/mem, RDS connections, Batch age/queue, Step Functions failures.

## Phase 6 - CI/CD (to implement)
1) GitHub Actions pipelines:
   - `terraform plan/apply` per environment (hml/prod) with approvals.  
   - Build/push frontend/api/batch images.  
   - Deploy manifests to EKS (kubectl/Helm/ArgoCD).  
2) Checkov/tfsec and ECR image scan enabled.

## Phase 7 - Validation
1) Access frontend/API endpoints via CF/ALB; health checks OK.  
2) Run Batch/Step Functions pipeline and confirm results in the bucket.  
3) Review alarms/logs/metrics and resilience tests (job failure, HPA, autoscaling).
