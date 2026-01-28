# GitHub Actions variables (Challenge 02)

Configure in **Settings > Secrets and variables > Actions**.

## Actions Variables (required)
- `AWS_REGION`: AWS region.  
- `BATCH_JOB_IMAGE`: Batch worker image (ECR URI or public) used in IaC.  
- `PROJECT`: (optional) project prefix (default: challenge02). Used for tags/names in Terraform.  
- `EKS_CLUSTER_NAME`: target EKS cluster.  
- `K8S_NAMESPACE`: deployment namespace.  
- `API_DEPLOYMENT`: name of the API Deployment/Service.  
- `WEB_DEPLOYMENT`: name of the frontend Deployment/Service.  
- `ECR_API_REPOSITORY`: ECR repo for the API (if building in the pipeline).  
- `ECR_WEB_REPOSITORY`: ECR repo for the frontend (if building in the pipeline).  
- `API_IMAGE`: (optional) pre-published API image URI; if empty, the pipeline tries to build.  
- `WEB_IMAGE`: (optional) pre-published frontend image URI; if empty, the pipeline tries to build.  
- `ENABLE_EDGE`: (optional) true/false to enable CloudFront/Route53/ACM/WAF in IaC. If true, fill the fields below.  
- `ENABLE_WAF`: (optional) true/false to attach WAF to CloudFront.  
- `DOMAIN_NAME`: (optional) public domain (e.g., app.example.com) used by the edge.  
- `HOSTED_ZONE_ID`: (optional) Route53 hosted zone ID for the domain.  
- `ORIGIN_DOMAIN_NAME`: (optional) ALB/Ingress DNS to be the CloudFront origin.  
- `ACM_CERTIFICATE_ARN`: (optional) existing cert ARN in us-east-1; if empty and EDGE enabled, IaC requests a new one.  
- `ALARM_EMAIL`: (optional) email to subscribe to the alert SNS (CloudWatch alarms/backup).  
- `ROTATION_APP_VERSION`: (optional) version of the RDS rotation app from the Serverless App Repo (default 1.1.0).

## Actions Secrets (required)
- `AWS_ROLE_TO_ASSUME`: Role ARN for ECR/EKS/Terraform.  
- `TF_VAR_DB_PASSWORD`: Aurora database password used by Terraform.
