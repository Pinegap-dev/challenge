# Incident Response Plan – Challenge 01 (FastAPI on ECS Fargate)

Context: FastAPI container deployed on ECS Fargate behind an ALB. Image in ECR; `ADMIN_USER`/`ADMIN_PASS` defined via Terraform (recommended: Secrets Manager with rotation). Infra: 2-AZ VPC, public ALB, ECS service.

1) Detection and triggers
- CloudWatch Alarms: ALB 5xx/latency high, `ECS Service Desired vs Running` divergence, task failures (StoppedReason).
- Security: suspicious SG/NACL changes, IAM role misuse, anomalous traffic on ALB/WAF (if enabled).

2) Initial triage
- Identify environment (staging/prod), start time, and blast radius (ALB target health, affected tasks, subnets).
- Freeze non-critical deploys (pause app pipeline).

3) Immediate containment
- Compromise: rotate secrets (`ADMIN_USER/PASS`), tighten SG to block suspicious sources.
- Error/crash: reduce traffic (deregister targets) or temporary scale down; roll back to last stable task definition (`aws ecs update-service ... --task-definition <good-revision>`).

4) Analysis and eradication
- CloudWatch logs for the service (`/ecs/<service>`) and ALB events (target health). Check ALB health checks.
- Verify SG, routes, external dependencies (ECR pull, DNS, NAT).
- Build hotfix, push new image, validate in staging before prod.

5) Recovery
- Update ECS service with the fixed task definition; restore desired count.
- Validate health (targets healthy, 2xx and normal latency). Monitor closely for 24–48h.

6) Communication
- Internal incident channel; external (status page) if applicable.
- Record timeline and owners; open postmortem.

7) Post-incident
- Document RCA (root and contributing causes).
- Preventive actions: move secrets to Secrets Manager with rotation, add alarms (CPU/mem per task, ALB 5xx), WAF/Rate limiting if missing, integration tests covering auth/admin.

8) Useful artifacts
- Versioned images (SHA) in ECR; pipelines `.github/workflows/deploy-iac.yml` and `deploy-app.yml`; Terraform state/outputs; ALB health history.
