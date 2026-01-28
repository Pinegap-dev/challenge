# GitHub Actions variables (Challenge 04)

Add them in **Settings > Secrets and variables > Actions**.

## Actions Variables (required)
- `AWS_REGION`: AWS region.  
- `BATCH_JOB_IMAGE`: Batch worker image (ECR URI or public).  
- `EKS_CLUSTER_NAME`: target EKS cluster.  
- `K8S_NAMESPACE`: deployment namespace.  
- `API_DEPLOYMENT`: API Deployment/Service name.  
- `FRONT_DEPLOYMENT`: frontend Deployment/Service name.  
- `ECR_API_REPOSITORY`: API ECR repository (for pipeline builds).  
- `ECR_FRONT_REPOSITORY`: frontend ECR repository (for pipeline builds).  
- `API_IMAGE`: (optional) pre-published API URI; if empty, pipeline tries to build.  
- `FRONT_IMAGE`: (optional) pre-published frontend URI; if empty, pipeline tries to build.  
- `API_BASE_URL`: (optional) API URL used by the front (injects `NEXT_PUBLIC_API_BASE` in deployment).  
- `API_HOST`: (optional) DNS host for the API (Ingress ALB).  
- `FRONT_HOST`: (optional) DNS host for the front (Ingress ALB).  
- `ALB_CERT_ARN`: (optional) ACM cert ARN for HTTPS on the ALB Ingress.  
- `ENABLE_EDGE`: (optional) `true/false` to enable CloudFront/Route53/ACM/WAF.  
- `DOMAIN_NAME`: (optional) domain served by CloudFront (e.g., app.example.com).  
- `HOSTED_ZONE_ID`: (optional) Route53 Hosted Zone ID for the domain.  
- `ORIGIN_DOMAIN_NAME`: (optional) origin DNS (ALB/Ingress) for CloudFront.  
- `ACM_CERTIFICATE_ARN`: (optional) ACM cert ARN in us-east-1; leave empty to create automatically.  
- `ENABLE_WAF`: (optional) `true/false` to attach WAFv2 to CloudFront.

## Actions Secrets (required)
- `AWS_ROLE_TO_ASSUME`: Role ARN for ECR/EKS/Terraform.  
- `TF_VAR_DB_PASSWORD`: Aurora DB password used by Terraform.
