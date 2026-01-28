# How to add variables and secrets (Challenge 02)

1. Open `Settings > Secrets and variables > Actions` in the repository.  
2. Under **Variables**, create all items listed in `VARIABLES.md` (AWS_REGION, BATCH_JOB_IMAGE, EKS_CLUSTER_NAME, K8S_NAMESPACE, API_DEPLOYMENT, WEB_DEPLOYMENT, ECR_API_REPOSITORY, ECR_WEB_REPOSITORY; optional API_IMAGE/WEB_IMAGE; optional edge ENABLE_EDGE/ENABLE_WAF/DOMAIN_NAME/HOSTED_ZONE_ID/ORIGIN_DOMAIN_NAME/ACM_CERTIFICATE_ARN; optional ALARM_EMAIL/ROTATION_APP_VERSION; optional `PROJECT` for Terraform prefixes).  
3. Under **Secrets**, create `AWS_ROLE_TO_ASSUME` and `TF_VAR_DB_PASSWORD`.  
4. Use ECR URIs/region/cluster values that match the real environment.  
5. Only run `deploy-iac.yml` and `deploy-app.yml` after everything is set; they will fail if required fields are missing.
