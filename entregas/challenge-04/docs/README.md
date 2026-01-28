# Challenge 04 - Overview

Proposed architecture: Next.js (front) + FastAPI (API) on EKS, RDS Aurora Postgres, S3 buckets (uploads 365d, results 5y) with SSE-KMS, Step Functions + Batch for processing, ECR for images, optional edge (CloudFront/ACM/WAF), observability and security aligned.

Reference apps: code in `app/api` (FastAPI) and `app/web` (Next.js), ready for build/push via pipeline. The front consumes the API via `NEXT_PUBLIC_API_BASE` (variable injected in the manifest). K8s manifests in `k8s/`, IaC in `iac/`.

How to use:
1) Adjust vars/secrets per `docs/VARIABLES.md` and `docs/setup_variable.md`.  
2) Run pipelines `deploy-iac.yml` (Terraform) and `deploy-app.yml` (build/push -> deploy EKS).  
3) Publish docs with `docs.yml` (Pages).
