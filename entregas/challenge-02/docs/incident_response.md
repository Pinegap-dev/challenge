# Incident Response Plan – Challenge 02 (Django + FastAPI + Batch/Step Functions on EKS)

Context: Django frontend and FastAPI API on EKS; Aurora Postgres; S3 uploads/results; Batch/Step Functions; ALB/Ingress; images in ECR; secrets in SSM/Secrets; IaC in Terraform.

1) Detection and triggers
- Alarms: ALB 5xx/latency, HPA saturation, pods not ready, Batch queue/age high, Step Functions errors, RDS connections, S3 errors.
- Security: suspicious IAM events, WAF (if enabled), SG/ACL changes, public S3 objects.

2) Triage
- Identify environment (staging/prod), impacted services (web, api, Batch pipeline), start time and scope (AZs, namespaces).
- Pause deploys until stable.

3) Containment
- Security incident: isolate namespace or SG, revoke/rotate secrets, pause Batch/Step Functions executions.
- App failure: roll back to prior image; reduce traffic (tighten ingress) if needed.
- DB outage: trigger Aurora failover (if Multi-AZ), fix SG/routes.

4) Analysis and eradication
- Logs: pods (kubectl/CloudWatch), ALB access logs, Step Functions execution history, Batch job logs, RDS events/Performance Insights.
- Infra: check SG, routes, NAT, quotas; validate IAM (IRSA) for S3/States/Batch.
- Fix code/config, build new image, validate in staging before prod.

5) Recovery
- Redeploy fixed images, resume Batch/Step Functions runs.
- Validate health: targets healthy, p95 normal, Batch queue draining, Step Functions errors cleared, RDS stable.
- Monitor 24–48h with heightened alarms.

6) Communication
- Internal incident channel; external status page if customer impact.
- Record timeline, actions, and owners.

7) Post-incident
- RCA with root and contributing causes.
- Actions: strengthen integration tests (DB/S3/States), alarms for Batch queue/age, minimal IAM policies, WAF/rate limit, backup/restore drills, chaos (CE/Spot failure) if appropriate.

8) Useful artifacts
- IaC in `entregas/challenge-02/iac`; K8s manifests in `entregas/challenge-02/k8s/`; pipelines `deploy-iac.yml` and `deploy-app.yml`; versioned images in ECR; Step Functions/Batch history.
