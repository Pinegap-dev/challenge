# Q&A - Challenge 04 (Modular IaC: Next.js + FastAPI + Batch/Step Functions)

## Why modularize Terraform?
- Easier reuse and maintenance (network, kms/s3, ecr, rds, eks, batch_sfn). Lets you apply/update parts, version modules, and reduce blast radius with clearer ownership.

## How does the architecture scale and ensure HA?
- Multi-AZ VPC; EKS with autoscaling node group; HPA on pods; Aurora Postgres multi-AZ; Batch CE spot/on-demand; multi-AZ ALB/Ingress; S3 buckets with KMS. CloudFront + WAF for edge via `edge` module if needed.

## Why EKS for API/Front?
- Kubernetes standard: IRSA, ingress controller, HPA, observability (Prometheus/Grafana), and blue/green/canary via ingress/Argo Rollouts. If the front is static, it can go to S3+CloudFront (`edge`); if SSR, it can run on EKS/ECS.

## How to trigger Batch/Step Functions?
- FastAPI uses an IRSA role with `states:StartExecution` and `batch:SubmitJob`. The state machine calls Batch queue/Job Definition with image `batch_job_image`. Jobs read S3 uploads and write S3 results (lifecycle 365d/5y).

## How does the front discover the API?
- `API_BASE_URL` injects `NEXT_PUBLIC_API_BASE` in the front deployment. In ingress, hosts `API_HOST`/`FRONT_HOST` and optional `ALB_CERT_ARN` handle HTTPS via ALB.

## Security and sensitive data?
- Secrets in Secrets Manager/SSM; IRSA for pods; tight SGs (ALB -> pods; pods -> RDS); KMS for S3; TLS in transit; optional WAF/CloudFront via `edge`; CloudTrail/Config enabled; least-privilege roles.

## Observability/SRE?
- Stdout logs to CloudWatch; Container Insights/Prometheus for metrics; alarms for ALB 5xx/latency, pod CPU/mem, RDS connections, Batch age/queue, Step Functions failures. Optional tracing (X-Ray/OTel).

## CI/CD?
- Separate pipelines: Terraform (plan/apply per environment) and app (build/push API/Front images, deploy via kubectl/Helm/ArgoCD). OIDC for AWS. Image scans (ECR) and tfsec/checkov recommended. Approvals for prod.

## Rollback and releases?
- Images tagged by SHA/semver; roll back Deployment/Helm release or point to previous Task/Job Definition. Terraform with workspaces/remote state and plans reviewed before apply.

## “Entrega” (SRE) session answers
- App can’t reach DB: check SG/ACL allow RDS port, correct endpoint/hostname, valid secrets (SSM/Secrets). Check Aurora health/failover. Ensure pod has route/NAT to reach the private endpoint.  
- How to debug: app/pod logs, RDS events, connection metrics, VPC Reachability Analyzer, `kubectl exec` + `psql` via bastion, connectivity tests in same subnet/SG. Reproduce in staging.  
- How to prevent recurrence: versioned IaC for SG/routes, rotate/validate creds, liveness/readiness that validate connections, alarms for DB connection errors/latency, CI integration tests pointing to a QA DB.  
- How to set/track SLO/SLI: SLO 99.9% API availability; SLIs: 2xx/total, p95 latency, DB errors/timeouts, Batch queue age, Step Functions success. Monitor via CloudWatch/Prometheus with dashboards/alerts, review SLO periodically.
