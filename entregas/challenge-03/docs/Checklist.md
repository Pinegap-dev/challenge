# Flask serverless on Lambda + API Gateway (Challenge 03)

Goal: publish the Flask app (returns `Hello, <NAME>!`) as a Lambda container exposed via API Gateway HTTP API, using Terraform for infra, ECR for the image, and GitHub Actions for CI/CD and Docs (GitHub Pages).

## Proposed architecture (high level)
- API Gateway HTTP API -> Lambda (container) running the Flask app.
- Image in Amazon ECR; Lambda aliases for `staging` and `prod`.
- IaC in `entregas/challenge-03/iac/` (module `lambda_api`).
- Observability: CloudWatch Logs for the Lambda.

## Phase 0 - Local prep and quality
1) Requirements: AWS CLI, Terraform >= 1.6, Docker, git.  
2) Validate Python deps/venv if running tests.  
3) Run quality locally (in `entregas/challenge-03/app/`; reference copy in `devops/challenge-03/`):
   ```bash
   pre-commit run --all-files
   pytest
   ```

## Phase 1 - Build and push the image
1) Check `Dockerfile` in `entregas/challenge-03/app/` (copy in `devops/challenge-03/`).  
2) Create ECR repo (e.g., `challenge-03`) and authenticate:
   ```bash
   aws ecr create-repository --repository-name challenge-03
   aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <registry>
   docker build -t <registry>/challenge-03:latest .
   docker push <registry>/challenge-03:latest
   ```
3) Keep the URI to use in Terraform (`lambda_image_uri`) and the workflow.

## Phase 2 - Provision infra (Terraform)
1) Directory: `entregas/challenge-03/iac/`.  
2) Adjust variables: `lambda_image_uri`, `name_value` (value of `NAME`), `region`, `environment`.  
3) Run:
   ```bash
   terraform init
   terraform plan -var 'environment=staging'
   terraform apply -var 'environment=staging' -auto-approve
   ```
4) Expected outputs: `api_endpoint`, Lambda names and aliases.  
5) Repeat for `environment=prod` with appropriate values.

## Phase 3 - CI/CD (GitHub Actions)
1) Secrets/vars for `.github/workflows/ci-cd.yml`:
   - `AWS_ROLE_TO_ASSUME`, `AWS_REGION`, `ECR_REPOSITORY`, `LAMBDA_FUNCTION_NAME`, `STG_NAME`, `PROD_NAME`.  
2) Flow:
   - `push` on `develop` -> build/push image -> `lambda update-function-code` -> update alias `staging` -> set env `NAME`.  
   - `push` on `main` -> same flow for alias `prod`.  
3) Optional: triggers for pre-commit/pytest and tfsec.

## Phase 4 - Docs (GitHub Pages)
1) Content in `entregas/challenge-03/app/docs/` (`index.md` + `README.md`).  
2) Workflow `.github/workflows/docs.yml` publishes Pages when `docs/` changes on `main`.  
3) Ensure the `github-pages` environment is enabled in the repo.

## Phase 5 - Validation
1) Call the API Gateway endpoint (`api_endpoint`): `curl <url>/`.  
2) Check logs in CloudWatch; change `NAME` and validate the response.  
3) Test both aliases (staging/prod) if configured.
