# GitHub Actions variables (Challenge 01)

Use these exact names in **Settings > Secrets and variables > Actions** of the repository.

## Actions Variables (required)
- `AWS_REGION`: AWS region (e.g., `us-east-1`).
- `TASK_IMAGE`: ECR URI of the FastAPI image used by Terraform (initial task definition seed).
- `ECR_REPOSITORY`: ECR repository name for app build/push (`deploy-app.yml`).
- `ECS_CLUSTER_NAME`: ECS Fargate cluster name created by Terraform.
- `ECS_SERVICE_NAME`: ECS service name (e.g., `challenge01-hml-fastapi-svc`).
- `CONTAINER_NAME`: (optional) container name in the task definition (default `fastapi`).
- `PROJECT`: (optional) prefix used in IaC (default: challenge01).

## Actions Secrets (required)
- `AWS_ROLE_TO_ASSUME`: Role ARN with permission in ECR/ECS/Terraform.
- `ADMIN_USER`: Admin user for the API (used in IaC).
- `ADMIN_PASS`: Admin password for the API (used in IaC).
