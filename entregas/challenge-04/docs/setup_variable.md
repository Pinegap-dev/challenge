# How to add variables and secrets (Challenge 04)

1. Go to `Settings > Secrets and variables > Actions` in the repository.  
2. Under **Variables**, create all items from `VARIABLES.md` (AWS_REGION, BATCH_JOB_IMAGE, EKS_CLUSTER_NAME, K8S_NAMESPACE, API_DEPLOYMENT, FRONT_DEPLOYMENT, ECR_API_REPOSITORY, ECR_FRONT_REPOSITORY and optionally API_IMAGE/FRONT_IMAGE; API_BASE_URL for the front to consume the API; API_HOST/FRONT_HOST/ALB_CERT_ARN for the ALB Ingress; for optional edge: ENABLE_EDGE, DOMAIN_NAME, HOSTED_ZONE_ID, ORIGIN_DOMAIN_NAME, ACM_CERTIFICATE_ARN, ENABLE_WAF).  
3. Under **Secrets**, create `AWS_ROLE_TO_ASSUME` and `TF_VAR_DB_PASSWORD`.  
4. Use values consistent with your infrastructure (ECR URIs, cluster/namespace names).  
5. Run the workflows (`deploy-iac.yml` and `deploy-app.yml`) only after everything is filled; they validate required variables and fail if something is missing.
