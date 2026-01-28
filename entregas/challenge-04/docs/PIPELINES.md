# Deploy pipelines (Challenge 04)

Files: `.github/workflows/deploy-iac.yml` (infra) and `.github/workflows/deploy-app.yml` (application). Both live in `entregas/challenge-04` and orchestrate Terraform + rollout on Kubernetes (EKS).

## deploy-iac.yml (Terraform IaC)
- **IaC path:** `technical-challenges/entregas/challenge-04/iac`.
- **What it does:** init/fmt/validate/plan/apply for modular Terraform (network, kms, s3, ecr, rds, eks, batch/step functions). Selects `hml` (develop), `prod` (main), or manual.
- **Secrets/vars:** `AWS_ROLE_TO_ASSUME` (required), `TF_VAR_DB_PASSWORD` (secret), `BATCH_JOB_IMAGE` (optional var), `AWS_REGION`.
- **Optional edge:** enable CloudFront/WAF/Route53/ACM with `ENABLE_EDGE=true` and set `DOMAIN_NAME`, `HOSTED_ZONE_ID`, `ORIGIN_DOMAIN_NAME`, optional `ACM_CERTIFICATE_ARN`, `ENABLE_WAF`.
- **Triggers:** push to `main`/`develop` touching `entregas/challenge-04`, or manual.
- **Expected output:** state applied with VPC/buckets/KMS/ECR/Aurora/EKS/Batch/Step Functions.

## deploy-app.yml (Application on Kubernetes)
- **App paths:** `technical-challenges/entregas/challenge-04/app/api` and `/web` (if they contain Dockerfile). If absent, use pre-published images via vars `API_IMAGE` and `FRONT_IMAGE`.
- **What it does:** discover ECR registry → (optional) build/push API and Front → kubeconfig for EKS → create namespace → render manifests in `entregas/challenge-04/k8s/` via `envsubst` → `kubectl apply` (Deployment/Service for API and Front).
- **Secrets/vars:** `AWS_ROLE_TO_ASSUME` (required), `AWS_REGION`, `EKS_CLUSTER_NAME`, `K8S_NAMESPACE`, `API_DEPLOYMENT`, `FRONT_DEPLOYMENT`, `API_IMAGE`/`FRONT_IMAGE` (if not building), `ECR_API_REPOSITORY`/`ECR_FRONT_REPOSITORY` (for build).
- **Triggers:** push to `main`/`develop` hitting `entregas/challenge-04` or `devops/challenge-04`, or manual (default staging; prod on main).

## Kubernetes notes
- Base manifests in `entregas/challenge-04/k8s/` (API port 8000; Front port 3000). Adjust replicas, probes, ingress/service (ALB/NGINX) and envs per the real app.
- Ensure the EKS cluster and namespace exist (IaC creates the cluster; pipeline creates the namespace if missing). Images must be in an ECR registry accessible to the cluster.

## Docs (GitHub Pages)
- Workflow `entregas/challenge-04/.github/workflows/docs.yml` publishes `entregas/challenge-04/docs/` to GitHub Pages (environment github-pages), triggered only when `entregas/challenge-04/docs/` (or the workflow itself) changes.
