# Provisioning Manual - Challenge 01 (FastAPI on ECS Fargate)

## Local prerequisites
1) AWS CLI configured with a profile that has admin-equivalent access.  
2) Terraform >= 1.6 (if using the provided IaC).  
3) Docker installed to build images.  
4) Git + access to the repo fork (GitHub Actions enabled).

## Overview
- Architecture: VPC (2 AZ) with public subnets (ALB/NAT) and private subnets (ECS), ALB, ECS Fargate, ECR, Secrets Manager/SSM for credentials, CloudWatch Logs, optional DNS/TLS.  
- IaC available at `entregas/challenge-01/iac/` (modules `network` and `ecs_fastapi`).

## Step by step (with Terraform)
1) Adjust variables in `entregas/challenge-01/iac/main.tf`:  
   - `task_image` (ECR URI), `admin_user`, `admin_pass` (prefer Secrets Manager later), `region`, `environment`, `vpc_cidr`.  
2) In `entregas/challenge-01/iac`:
   ```bash
   terraform init
   terraform plan -var 'environment=hml'
   terraform apply -var 'environment=hml' -auto-approve
   ```
   Key outputs: `alb_dns`, `service_name`.  
3) (Optional) Create a Route53 record pointing to `alb_dns` and attach an ACM certificate (listener 443) + WAF if needed.

## Step by step (build and push the image)
1) At `entregas/challenge-01/app/api` (reference copy at `devops/challenge-01/api`), create the Dockerfile (example already in `parte1.md`) or reuse the existing one.  
2) Create the repository in ECR:
   ```bash
   aws ecr create-repository --repository-name fastapi-vars --region <region>
   ```
3) Login and push:
   ```bash
   aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <account>.dkr.ecr.<region>.amazonaws.com
   docker build -t fastapi-vars:latest .
   docker tag fastapi-vars:latest <account>.dkr.ecr.<region>.amazonaws.com/fastapi-vars:latest
   docker push <account>.dkr.ecr.<region>.amazonaws.com/fastapi-vars:latest
   ```
4) Update `task_image` in Terraform with the image URI.

## Step by step (CI/CD example with GitHub Actions)
1) Create repo secrets/vars:  
   - `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`, `ECR_REGISTRY`, `ECR_REPOSITORY`, `ECS_CLUSTER`, `ECS_SERVICE`.  
2) Create the workflow with stages:  
   - lint/test (if present), build/push image to ECR, `aws ecs update-service --force-new-deployment`.  
3) Configure IAM for the runner (OIDC + assume role).

## Validation
1) `curl -u <ADMIN_USER>:<ADMIN_PASS> http://<alb_dns>/` should return the API JSON.  
2) Check healthy targets on ALB and logs in CloudWatch.  
3) Simulate stopping a task (ECS console) and verify recreation/healthcheck.

## Optional tweaks
- Move `ADMIN_USER`/`ADMIN_PASS` to Secrets Manager/SSM and reference them via task definition (envFrom).  
- Enable TLS with ACM and listener 443 on ALB.  
- Add WAF (managed) to ALB/CloudFront.
