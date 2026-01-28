# Pipelines (Challenge 03)

Files: `.github/workflows/deploy-iac.yml` (Lambda/API Gateway infra) and `.github/workflows/deploy-app.yml` (serverless app).

## deploy-iac.yml (Terraform IaC)
- **IaC path:** `technical-challenges/entregas/challenge-03/iac`.
- **What it does:** Terraform init/fmt/validate/plan/apply creating Lambda + API Gateway. Selects `hml` (develop), `prod` (main), or manual. Uses a var-file generated in the pipeline (`apply.fvars`).
- **Secrets/vars:** `AWS_ROLE_TO_ASSUME` (required), `AWS_REGION`, `PROJECT` (optional) and the fields in `apply.fvars`.
- **Triggers:** push to `main`/`develop` touching `entregas/challenge-03`, or manual.
- **Expected output:** state applied with Lambda/API Gateway per Terraform.

## deploy-app.yml (Serverless application)
- **App path:** `technical-challenges/entregas/challenge-03/app` (Dockerfile builds the Flask app).
- **What it does:** lint/test (ruff, black, pytest) → build/push image to ECR → `aws lambda update-function-code` with the image → update env `NAME` → create/update alias per environment (`staging`/`prod`).
- **Secrets/vars:** `AWS_ROLE_TO_ASSUME` (required), `AWS_REGION`, `ECR_REPOSITORY`, `LAMBDA_FUNCTION_NAME`, `NAME_VALUE` or `NAME_VALUE_STAGING`/`NAME_VALUE_PROD`.
- **Triggers:** push to `main`/`develop` touching `entregas/challenge-03`, or manual (staging default; prod on main).

## Docs (GitHub Pages)
- Workflow `entregas/challenge-03/.github/workflows/docs.yml` publishes `entregas/challenge-03/app/docs/` to GitHub Pages (environment github-pages), triggered when `entregas/challenge-03/app/docs/` (or the workflow itself) changes.
