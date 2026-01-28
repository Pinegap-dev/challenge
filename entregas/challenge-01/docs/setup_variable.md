# How to add variables and secrets (Challenge 01)

1. In GitHub, open `Settings > Secrets and variables > Actions`.  
2. Under **Variables**, add the name/value pairs listed in `VARIABLES.md` (AWS_REGION, TASK_IMAGE, ECR_REPOSITORY, ECS_CLUSTER_NAME, ECS_SERVICE_NAME; optional `CONTAINER_NAME` and `PROJECT`).  
3. Under **Secrets**, add `AWS_ROLE_TO_ASSUME`, `ADMIN_USER`, `ADMIN_PASS`.  
4. Make sure values match your AWS resources (ECR, ECS cluster/service) and API credentials.  
5. Run the workflows (`deploy-iac.yml` and `deploy-app.yml`) only after everything is set; each workflow validates required variables and fails if something is missing.
