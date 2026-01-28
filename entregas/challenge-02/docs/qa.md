# Q&A - Challenge 02 (Django + FastAPI + Batch/Step Functions)

## How does the architecture ensure HA and scale?
- Multi-AZ VPC, EKS with autoscaling node groups (on-demand + spot), multi-AZ ALB/Ingress, multi-AZ Aurora Postgres. HPA on deployments. Batch CE mixing spot/on-demand. CloudFront for cache and WAF at the edge.

## Why EKS and not ECS/App Runner?
- Two services (Django frontend and FastAPI) and room for sidecars/observability; EKS standardizes k8s, IRSA, ingress controller, HPA, optional service mesh. ECS would work, but EKS meets scale/observability requirements.

## How do uploads/results retention work?
- S3 uploads with 365-day lifecycle; results with 5-year lifecycle. Both SSE-KMS, versioning, and public-block. Optional cross-region replication.

## How do you protect data and access?
- Least-privilege IAM + IRSA for pods. Tight SGs (ALB -> pods; pods -> RDS). WAF on CloudFront/ALB. KMS for S3, TLS in transit, secrets in Secrets Manager/SSM. CloudTrail/Config enabled.

## How are Batch/Step Functions orchestrated?
- API calls Step Functions (StartExecution) via dedicated role; state machine calls Batch submitJob. Job definition sets image/resources; CE mixes spot/on-demand for cost. Resilience via retries/backoff.

## How are apps exposed?
- Route53 -> CloudFront + WAF -> ALB/Ingress -> EKS services. ACM certificates. Path-based routing between frontend and API.

## Observability and SRE?
- Stdout logs -> CloudWatch; metrics via CloudWatch + Prometheus/Grafana; alarms for ALB 5xx/latency, pod CPU/mem, RDS connections, Batch queue/age, Step Functions errors. AWS Backup for RDS.

## CI/CD?
- GitHub Actions: lint/test -> build/push images -> deploy (kubectl/Helm/ArgoCD). Gates for prod. Image scan (ECR), optional tfsec/checkov.

## SLO/SLI and incidents?
- Example SLO 99.9% API availability; SLIs: 2xx/total, p95 latency, Batch queue age, Step Functions success. Runbooks for DB down (SG/creds/health), stuck queue (Batch/CE), app error (logs/traces).

## Cost?
- Spot for node groups and Batch, CloudFront cache, S3 lifecycle, right-sized Aurora, turn off staging off-hours if possible.

## “Entrega” (SRE) session answers
- App can’t reach DB? Check secrets/creds (SSM/Secrets), SG/ACL blocking port, bad endpoint param, Aurora health. Action: review SG ingress/egress, routes, credential rotation, Multi-AZ failover.  
- How to debug? App/pod logs, RDS events, `kubectl exec` + `psql` via bastion, VPC Reachability Analyzer, connection/latency metrics. Reproduce in staging with same SG/creds.  
- How to avoid recurrence? Guardrails: versioned IaC, automatic health checks, alarms (RDS connections, API 5xx), automated secrets rotation, CI integration tests validating DB connectivity.  
- How to set/track SLO/SLI? SLO 99.9% API availability; SLIs: 2xx/total, p95 latency, DB errors/timeouts, Batch queue age. Monitor via CloudWatch/Prometheus + alerts/dashboards, review quarterly.
