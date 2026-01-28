# How to add variables and secrets (Challenge 03)

1. Go to `Settings > Secrets and variables > Actions` in the repository.  
2. Under **Variables**, add the items listed in `VARIABLES.md` (AWS_REGION, ECR_REPOSITORY, LAMBDA_FUNCTION_NAME, NAME_VALUE or NAME_VALUE_STAGING/NAME_VALUE_PROD; optional `PROJECT` for IaC prefix).  
3. Under **Secrets**, add `AWS_ROLE_TO_ASSUME`.  
4. Run the workflows (`deploy-iac.yml` and `deploy-app.yml`) after everything is filled; pipelines validate required variables and fail if anything is missing. Builds use path `entregas/challenge-03/app` (copy kept in `devops/challenge-03`).
