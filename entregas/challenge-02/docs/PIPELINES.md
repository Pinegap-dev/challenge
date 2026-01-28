# Deploy pipelines (Challenge 02)

Files: `.github/workflows/deploy-iac.yml` (infra) and `.github/workflows/deploy-app.yml` (application) inside this challenge. Both use AWS + Kubernetes (EKS) and keep artifacts under `entregas/challenge-02`.

## deploy-iac.yml (Terraform IaC)
- **IaC path:** `technical-challenges/entregas/challenge-02/iac` (local modules in `iac/modules/`).
- **What it does:** init/fmt/validate/plan/apply Terraform for VPC, KMS/S3, ECR, Aurora, EKS, Batch/Step Functions. Selects `hml` (develop), `prod` (main), or manual input.
- **Secrets/vars:** `AWS_ROLE_TO_ASSUME` (required), `TF_VAR_DB_PASSWORD` (secret), `BATCH_JOB_IMAGE` (optional var), `AWS_REGION`.
- **Triggers:** push to `main`/`develop` touching `entregas/challenge-02`, or manual.
- **Expected output:** state applied and Terraform outputs (VPC, buckets, Aurora, EKS, Batch/SFN).

## deploy-app.yml (Application on Kubernetes)
- **App paths:** optional `technical-challenges/devops/challenge-02/api` and `/web` (if they contain Dockerfile). If absent, use pre-published images via vars `API_IMAGE` and `WEB_IMAGE`.
- **What it does:** discover ECR registry → (optional) build/push API and Web images → kubeconfig for EKS → create namespace → render manifests in `entregas/challenge-02/k8s/` via `envsubst` → `kubectl apply` (Deployment/Service for API and Web).
- **Secrets/vars:** `AWS_ROLE_TO_ASSUME` (required), `AWS_REGION`, `EKS_CLUSTER_NAME`, `K8S_NAMESPACE`, `API_DEPLOYMENT`, `WEB_DEPLOYMENT`, `API_IMAGE`/`WEB_IMAGE` (if not building), `ECR_API_REPOSITORY`/`ECR_WEB_REPOSITORY` (for build).
- **Triggers:** push to `main`/`develop` hitting `entregas/challenge-02` or `devops/challenge-02`, or manual (default staging; prod on main).

## Kubernetes notes
- Base manifests in `entregas/challenge-02/k8s/` (API port 8000; Web port 3000). Adjust replicas, probes, and ingress as needed.
- Ensure the EKS cluster and namespace exist (IaC creates the cluster; pipeline creates the namespace if missing). Images must be in an ECR registry accessible to the cluster.
