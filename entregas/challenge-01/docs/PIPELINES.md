# Deploy pipelines (Challenge 01)

Files: `.github/workflows/deploy-iac.yml` (infra) and `.github/workflows/deploy-app.yml` (application). Both run on GitHub Actions with AWS.

## deploy-iac.yml (Terraform IaC)
- **IaC path:** `technical-challenges/entregas/challenge-01/iac`.
- **What it does:** `terraform init/fmt/validate/plan/apply` to create a VPC in 2 AZs, public ALB, and FastAPI ECS Fargate service. Chooses env `hml` (develop) or `prod` (main) or manual input. Generates `apply.fvars` in the workflow.
- **Secrets/vars:** `AWS_ROLE_TO_ASSUME` (required), `ADMIN_USER`/`ADMIN_PASS` (required), `TASK_IMAGE` (initial service image), optional `PROJECT`.
- **Triggers:** push to `main`/`develop` touching `entregas/challenge-01/**` or manual dispatch.
- **Output:** infra applied and logs with outputs (ALB DNS, service name).

## deploy-app.yml (Application on ECS Fargate)
- **App path:** `technical-challenges/entregas/challenge-01/app` (FastAPI Dockerfile). Reference copy lives in `devops/challenge-01`.
- **What it does:** builds the image, pushes to ECR, and updates the ECS service by registering a new task definition with the generated image.
- **Flow:** AWS/ECR login → build/push → read current service task definition → swap container image (`CONTAINER_NAME`, default `fastapi`) → register new task definition → `update-service --force-new-deployment`.
- **Secrets/vars:** `AWS_ROLE_TO_ASSUME` (required), `AWS_REGION`, `ECR_REPOSITORY`, `ECS_CLUSTER_NAME`, `ECS_SERVICE_NAME`, optional `CONTAINER_NAME`.
- **Triggers:** push to `main`/`develop` touching `devops/challenge-01` or `entregas/challenge-01`, or manual. Defaults env to `staging` (develop) and `prod` (main).
