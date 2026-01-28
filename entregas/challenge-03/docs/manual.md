# Provisioning Manual - Challenge 03 (Flask serverless on Lambda + API Gateway)

## Prerequisites
1) AWS CLI configured; Terraform >= 1.6.  
2) Docker to build the Lambda image.  
3) GitHub Actions enabled (OIDC or keys) for CI/CD and Pages.

## Overview
- Simple Flask app returning `Hello, <NAME>!` (env `NAME`).  
- Serverless deploy: API Gateway HTTP API -> Lambda container (image in ECR).  
- IaC at `entregas/challenge-03/iac/` (module `lambda_api`).  
- CI/CD at `.github/workflows/ci-cd.yml`; Pages at `.github/workflows/docs.yml`.

## Step by step (image)
1) Adjust/validate `Dockerfile` in `entregas/challenge-03/app/` (reference copy in `devops/challenge-03/`).  
2) Create ECR repo: `aws ecr create-repository --repository-name challenge-03`.  
3) Login + build/push:
   ```bash
   aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <registry>
   docker build -t <registry>/challenge-03:latest .
   docker push <registry>/challenge-03:latest
   ```
4) Use the URI as `lambda_image_uri` in Terraform or workflow vars.

## Step by step (Terraform)
1) In `entregas/challenge-03/iac/`, set:
   - `lambda_image_uri`, `name_value`, `region`, `environment`.
2) Run:
   ```bash
   terraform init
   terraform plan -var 'environment=staging'
   terraform apply -var 'environment=staging' -auto-approve
   ```
   Output: `api_endpoint`.  
3) Repeat for `environment=prod` (change `name_value` if desired).

## Step by step (CI/CD GitHub Actions)
1) Repo secrets/vars:
   - `AWS_ROLE_TO_ASSUME`, `AWS_REGION`, `ECR_REPOSITORY` (challenge-03), `LAMBDA_FUNCTION_NAME`, `STG_NAME`, `PROD_NAME`.  
2) Workflow `.github/workflows/ci-cd.yml`:
   - `push` on `develop` -> deploy staging (alias `staging`).  
   - `push` on `main` -> deploy prod (alias `prod`).  
   - Steps: lint/test (ruff/black/pytest), build/push image, `lambda update-function-code`, `lambda update-alias`, set env `NAME`.

## Docs and GitHub Pages
1) Content in `entregas/challenge-03/app/docs/` (`index.md` + `README.md`).  
2) Workflow `.github/workflows/docs.yml` publishes to Pages when `docs/` changes on `main`.  
3) Configure Pages to use the `github-pages` environment from the workflow.

## Validation
1) Call the API Gateway endpoint (output `api_endpoint`): `curl <url>/`.  
2) Check CloudWatch Logs for the Lambda.  
3) Change `NAME` (var or SSM) and verify the response.  
4) Run pre-commit locally: `pre-commit run --all-files`.
