# Provisioning Manual - Challenge 02 (Django + FastAPI + Batch/Step Functions)

## Prerequisites
1) AWS CLI configured; Terraform >= 1.6.  
2) Docker to build images.  
3) kubectl/Helm (to apply manifests) or ArgoCD if you prefer GitOps.  
4) Repo access to ECR (OIDC or access keys) and infra/admin permissions.

## Overview
- Architecture: VPC 2+ AZ, ALB/Ingress, EKS (Django frontend + FastAPI), Aurora Postgres, S3 (uploads 365d, results 5y, SSE-KMS), ECR (images), Step Functions + Batch (Fargate/Spot), observability (CloudWatch, optional Prometheus/Grafana).
- Base IaC in `entregas/challenge-02/iac/` with local modules in `iac/modules/` (network, kms, s3, ecr, rds, eks, batch_sfn).

## Step by step with Terraform
1) Configure variables in `entregas/challenge-02/iac/main.tf`:
   - `db_password` (replace `CHANGE_ME`), `batch_job_image`, `region`, `environment`.
2) Run:
   ```bash
   cd entregas/challenge-02/iac
   terraform init
   terraform plan -var 'environment=hml'
   terraform apply -var 'environment=hml' -auto-approve
   ```
   Outputs: VPC, subnets, buckets, Aurora endpoint, EKS cluster name, Batch queue, State machine ARN.
3) Configure kubeconfig for the cluster:
   ```bash
   aws eks update-kubeconfig --name <eks_cluster_name> --region <region>
   ```

## Images and ECR
1) Build and publish images:
   - Django: `<account>.dkr.ecr.<region>.amazonaws.com/<project>/frontend:<tag>`
   - FastAPI: `<account>.dkr.ecr.<region>.amazonaws.com/<project>/api:<tag>`
   - Batch workers: `<account>.dkr.ecr.<region>.amazonaws.com/<project>/batch:<tag>`
2) For each image:
   ```bash
   aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <registry>
   docker build -t <image_uri> .
   docker push <image_uri>
   ```

## Kubernetes manifests (EKS)
1) Apply namespaces/secrets/config if defined (see `k8s/` if present).  
2) Deploy frontend and API (Helm or raw manifests) pointing images to the ECR URIs above.  
3) Expose via Ingress (ALB controller) with TLS (ACM) and host rules for web/api.  
4) Configure HPA if desired (CPU/mem).

## Batch + Step Functions
1) Queue and job definition are created by Terraform; update the job image in the var file (`batch_job_image`).  
2) Update the state machine definition (Terraform module) to pull from S3 uploads and write to the results bucket.  
3) Grant IAM permissions to read/write S3 and emit logs/metrics.

## CI/CD (suggestion)
1) Pipeline stages: lint/test -> build/push (frontend, api, batch) -> deploy manifests to EKS -> kick off smoke tests.  
2) Use GitHub Actions OIDC + assume role for AWS.  
3) Store env-specific values (DB endpoint, S3 buckets, SFN ARN) in GitHub Actions variables/secrets or SSM/Secrets Manager.

## Validation
1) Ingress endpoints respond for web/api with 200 and correct content.  
2) ALB targets healthy; pods ready; HPA (if enabled) scaling appropriately.  
3) Batch job runs end-to-end reading uploads bucket and writing to results bucket.  
4) Aurora reachable from API (test migrations/queries).

## Optional hardening
- Rotate DB credentials via Secrets Manager.  
- Enable WAF on ALB/CloudFront.  
- Add Prometheus/Grafana stack for metrics, with alerts to SNS/Slack.  
- Enable CloudTrail/Config across the account.
