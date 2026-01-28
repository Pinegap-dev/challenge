# Q&A - Challenge 01 (FastAPI on ECS Fargate)

## How did you provision the network?
- VPC with 2 AZs, public subnets (ALB/NAT) and private subnets (ECS). Public routes via IGW, private via NAT. SGs: ALB open on 80/443, tasks accept 8000 only from the ALB SG. DNS/TLS optional via Route53+ACM.

## Why ECS Fargate instead of EC2/EKS?
- Fargate removes node management, reduces maintenance and idle cost for a small setup; meets the simplicity goal. EKS would fit if there were many services/sidecars or mesh needs, but here the load is simple.

## Where are ADMIN_USER/ADMIN_PASS stored?
- Ideally in Secrets Manager or SSM SecureString, injected in the task definition. Terraform can reference container `secrets`. Rotation via Secrets Manager.

## How do you ensure high availability?
- Multi-AZ ALB, ECS service with 2+ tasks in distinct subnets, health checks. NAT per AZ for resilient egress. Horizontal scale via target tracking on CPU/memory or custom metrics.

## Observability?
- CloudWatch Logs (group /ecs/...), ALB metrics (5xx, latency), ECS (CPU/mem), alarms to SNS/Slack. Optional X-Ray for tracing.

## Security?
- Least-privilege SGs, no public IP on tasks, TLS on ALB with ACM, optional managed WAF. IAM: minimal exec role, task role only to read the secret. S3/CloudTrail/Config can be enabled for audit.

## How to do CI/CD?
- GitHub Actions: lint/test (if present) -> build/push to ECR -> update task definition -> force new deployment on the service. OIDC to avoid long-lived keys.

## How to version and rollback?
- Images tagged by SHA/semver; ECS service uses rolling deployments; rollback by redeploying the previous task definition.

## Cost and optimization?
- Fargate on-demand with minimal sizing (0.25 vCPU/0.5GB) in dev; reduce NAT to 1 AZ in staging if acceptable; tone down verbose logs.

## What changes for prod?
- Mandatory TLS/WAF, secrets in Secrets Manager with rotation, redundant NAT, alarms and runbooks, backups of configs (tf state, etc.).
