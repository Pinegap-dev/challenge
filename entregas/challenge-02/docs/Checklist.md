# Bioinformatics architecture on AWS (Challenge 02)

Goal: deliver the architecture and provisioning for the bioinformatics app (Django frontend, FastAPI API) with a processing pipeline via Step Functions + AWS Batch, S3 buckets (uploads/results), Aurora Postgres, images in ECR, running on EKS with CI/CD.

## Proposed architecture (high level)
- VPC 2+ AZ with public subnets (ALB/ingress/NAT) and private subnets (EKS, RDS, Batch), NAT per AZ.
- Entry: Route53 -> CloudFront + WAF (optional) -> ALB/Ingress -> EKS (Django and FastAPI deployments).
- Processing: Step Functions orchestrates AWS Batch jobs (Fargate/EC2 Spot) reading S3 uploads and writing S3 results (lifecycle 365d / 5y, SSE-KMS, block public).
- Data: RDS Aurora Postgres multi-AZ. Credentials in Secrets Manager/SSM with rotation; SG access only from the API.
- Images: ECR repositories (frontend/backend/batch) with scan on push; pods with IRSA.
- Observability: CloudWatch logs/alarms, optional Prometheus/Grafana, SNS/Slack for alerts.

## Phase 0 - Local preparation
1) AWS CLI configured, Terraform >= 1.6, Docker, kubectl/Helm (or ArgoCD), git.  
2) Configure account/repo with access to ECR (GitHub Actions OIDC or keys).  
3) Clone repo/fork and create a personal branch.

## Phase 1 - Build and push images
1) Adjust service Dockerfiles (Django, FastAPI, Batch worker).  
2) Create ECR repos and login:
   ```bash
   aws ecr create-repository --repository-name <frontend|api|batch>
   aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <registry>
   docker build -t <image_uri> .
   docker push <image_uri>
   ```
3) Keep the URIs to use in Terraform/manifests.

## Phase 2 - Provision base (Terraform)
1) Directory: `entregas/challenge-02/iac/` (local modules in `iac/modules/`).  
2) Adjust variables in `main.tf`: `region`, `environment`, `db_password`, `batch_job_image`, sizes and tags.  
3) Run:
   ```bash
   terraform init
   terraform plan -var 'environment=hml'
   terraform apply -var 'environment=hml' -auto-approve
   ```
4) Expected outputs: VPC/subnets, buckets, Aurora endpoint, EKS cluster name, Batch queue and State Machine ARN.

## Phase 3 - Deploy apps on EKS
1) Configure kubeconfig: `aws eks update-kubeconfig --name <eks_cluster> --region <region>`.  
2) Install ALB Ingress Controller, Cluster Autoscaler, and enable IRSA.  
3) Create Secrets/ConfigMaps (DB creds, buckets, ARNs).  
4) Apply manifests/Helm:
   - Django frontend with Service/Ingress.  
   - FastAPI backend with Service/Ingress and access to Aurora + S3.  
   - HPA for CPU/memory if needed.

## Phase 4 - Batch/Step Functions pipeline
1) Validate Job Definition (worker image) and Compute Environment (Fargate/Spot).  
2) Ensure IAM permissions for FastAPI (IRSA) to call `states:StartExecution` and `batch:SubmitJob`.  
3) Test flow: upload to S3 -> Step Functions execution -> Batch job -> results in output bucket.

## Phase 5 - DNS, TLS, and WAF
1) Issue ACM certificate; configure Route53 for frontend/API domains.  
2) If using CloudFront, create distribution pointing to ALB/Ingress; associate WAF with managed rules + rate limit.  
3) Listener 443 on ALB with redirect 80 -> 443.

## Phase 6 - Observability and SRE
1) Logs: pod stdout to CloudWatch (awslogs), Batch logs.  
2) Alarms: ALB 5xx/latency, pod CPU/mem, RDS connections, Batch queue/age, Step Functions failures.  
3) Backups: enable AWS Backup for Aurora; review bucket retention.

## Phase 7 - CI/CD (GitHub Actions suggested)
1) Stages: lint/test -> build/push images -> deploy (kubectl/Helm/ArgoCD) per environment (hml/prod).  
2) Secrets/vars: `AWS_ROLE_TO_ASSUME`, `AWS_REGION`, `ECR_REPO_*`, `EKS_CLUSTER_NAME`, state machine/queue config.  
3) Gates: approvals for prod; tfsec/checkov optional.

## Phase 8 - Validation
1) Access ingress/CloudFront and validate Django and API routes.  
2) Submit an upload and verify Batch/Step Functions pipeline until results are stored.  
3) Check alarms/logs/metrics; simulate job failure to validate alerts.
