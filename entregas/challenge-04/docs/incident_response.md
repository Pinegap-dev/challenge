# Incident Response Plan – Challenge 04 (Next.js + FastAPI + Batch/Step Functions)

Context: Next.js front and FastAPI API on EKS; Aurora Postgres; S3 uploads/results; Batch/Step Functions; ALB/Ingress; images in ECR; modular Terraform IaC.

1) Detection and triggers
- Alarms: ALB 5xx/latency, pods not ready, HPA saturation, Batch queue/age, Step Functions failures, RDS connections, S3 errors.
- Security: IAM/IRSA misuse, WAF (if enabled) blocks, SG/ACL changes, public S3 objects.

2) Triage
- Confirm environment (hml/prod), impacted services (front, API, Batch pipeline), time and scope (AZs, namespaces).
- Pause deploys while investigating.

3) Containment
- Security incident: isolate namespace or SG, revoke/rotate secrets, pause Step Functions/Batch runs.
- App regression: rollback Deployment to stable image; limit traffic via Ingress/ALB if needed.
- DB outage: Aurora failover (Multi-AZ), fix SG/routes.

4) Analysis and eradication
- Logs: pods (kubectl/CloudWatch), ALB access logs, Step Functions execution history, Batch job logs, RDS events.
- Infra: check SG, routes/NAT, quotas; validate IAM/IRSA for S3/States/Batch/KMS.
- Apply fix in hotfix branch, build new image, validate in staging before prod.

5) Recovery
- Redeploy fixed images, re-enable Batch/Step Functions pipelines.
- Validate health: targets healthy, normal p95, Batch queue draining, Step Functions error-free, RDS OK.
- Heightened monitoring for 24–48h.

6) Communication
- Update internal channels and, if customer impact, external status. Record timeline and owners.

7) Post-incident
- RCA with preventive actions: integration tests (DB/S3/States/Batch), extra alarms (queue/age, 5xx, latency), WAF/rate limiting, restore drills, least-privilege policy review.

8) Useful artifacts
- IaC in `entregas/challenge-04/iac/`; K8s manifests in `entregas/challenge-04/k8s/`; pipelines `deploy-iac.yml` and `deploy-app.yml`; images in ECR; Step Functions state machine and Batch queue; optional `edge` module for CloudFront/Route53/ACM/WAF.
