# GitHub Actions variables (Challenge 03)

Configure in **Settings > Secrets and variables > Actions**.

## Actions Variables (required)
- `AWS_REGION`: AWS region.  
- `ECR_REPOSITORY`: ECR repository for build/push (app pipeline).  
- `LAMBDA_FUNCTION_NAME`: Lambda function name (same used in IaC).  
- `NAME_VALUE`: default value for env `NAME` (if not using the fields below).  
- `NAME_VALUE_STAGING` or `STG_NAME`: optional, value of `NAME` for staging.  
- `NAME_VALUE_PROD` or `PROD_NAME`: optional, value of `NAME` for prod.  
- `PROJECT`: (optional) prefix used in Terraform (default: challenge03).

## Actions Secrets (required)
- `AWS_ROLE_TO_ASSUME`: Role ARN for ECR/Lambda/Terraform.
