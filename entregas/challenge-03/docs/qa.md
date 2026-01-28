# Q&A - Challenge 03 (Flask serverless on Lambda)

## Why Lambda + API Gateway?
- Handles variable load without managing infrastructure; pay-per-use; integrates with ECR for containers. Simple for hello-world and auto-scales.

## How is the NAME variable passed?
- Via env in Terraform/workflow or SSM SecureString with specific permission. Each alias (staging/prod) can have a different value. Avoid hardcoding in YAML.

## What is the CI/CD flow?
- GitHub Actions: lint/test -> build/push image to ECR -> update-function-code -> update-alias (staging/prod) and set env NAME. OIDC to assume AWS role (no long-lived keys). App pipelines point to `entregas/challenge-03/app` (copy kept in `devops/challenge-03`).

## Observability?
- CloudWatch Logs for Lambda; alarms for API Gateway 5xx/latency and function errors. Optional X-Ray for tracing.

## Security?
- Minimal IAM role for Lambda (logs). API Gateway with throttling/optional WAF. Sensitive vars in SSM/Secrets Manager. No public buckets. TLS managed by API Gateway.

## How to rollback?
- Keep published Lambda versions; repoint the alias to a prior version. Images tagged by SHA.

## Local dev?
- `docker-compose up` with `NAME=Local`; pre-commit (ruff/black) and pytest. Can use `sam local start-api` or `lambda-runtime-interface-emulator` to simulate Lambda.

## What if execution time blows up?
- Increase timeout/memory. For heavier workloads, move to App Runner/ECS or a higher-resourced Lambda. Add retries/backoff on the client if needed.

## How to publish docs?
- Workflow `docs.yml` publishes `entregas/challenge-03/app/docs/` to GitHub Pages (environment github-pages).
