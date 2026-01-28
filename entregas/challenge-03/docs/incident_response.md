# Incident Response Plan – Challenge 03 (Flask)

Context: Flask app containerized, serverless deploy on Lambda + API Gateway. Image in ECR; env `NAME`; docs on Pages; IaC Terraform (Lambda).

1) Detection and triggers  
- Alarms: API Gateway 5xx/latency, Lambda errors/throttles, p95 high, rollout failures, image pull errors.  
- Security: IAM role misuse, SG changes, anomalous traffic.

2) Triage  
- Identify affected surface (Lambda/API Gateway), environment (staging/prod), time and scope.  
- Pause deploys until stable.

3) Containment  
- Compromise: rotate secrets/roles, block endpoint (WAF/throttling) or tighten SG.  
- Regression: rollback Lambda alias to previous version.

4) Analysis and eradication  
- Logs: CloudWatch (Lambda), API Gateway access logs, rollout events.  
- Infra: check IAM, SG, routes; image errors (ECR).  
- Apply fix, build new image, test in staging, then promote.

5) Recovery  
- Point Lambda alias to the fixed version.  
- Validate health: normal 2xx/latency, Lambda errors clearing. Monitor 24–48h.

6) Communication  
- Internal status and, if customer impact, external. Record timeline and owners.

7) Post-incident  
- RCA with root/contributing causes.  
- Actions: extra alarms (throttles, abnormal cold starts), CI integration tests, stronger API Gateway limits/rate, secrets rotation, rollout checks.

8) Useful artifacts  
- Pipelines `deploy-iac.yml`, `deploy-app.yml`, `devops/challenge-03/.github/workflows/ci-cd.yml`; Lambda IaC in `entregas/challenge-03/iac/`; versioned images in ECR.
