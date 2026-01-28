# Deploying the FastAPI on AWS (Challenge 01)

Goal: publish the FastAPI (uses `ADMIN_USER` and `ADMIN_PASS` for Basic Auth) in a clean AWS account with high availability and CI/CD. Chosen architecture: ECS Fargate for simplicity (no node management) with ALB, Secrets Manager/SSM, VPC in 2 AZs, CloudWatch logs, and image in ECR.

## Proposed architecture (high level)
- VPC with 2 AZs: public subnets (ALB, NAT) and private subnets (ECS). Egress through NAT so tasks can pull dependencies.
- Public Application Load Balancer with listeners 80/443 (TLS via ACM). Target group points to ECS tasks.
- ECS Fargate service (min 2 tasks) running the FastAPI container. HTTP health check `/`.
- Credentials `ADMIN_USER` and `ADMIN_PASS` in AWS Secrets Manager (or SSM SecureString), injected as env vars into the tasks.
- Docker image published to Amazon ECR.
- Application logs in CloudWatch Logs; CloudWatch metrics/alarms (ALB 5xx, service CPU/Memory).
- Optional WAF on ALB/CloudFront; Route53 for DNS; ACM for certificates.
- CI/CD (GitHub Actions) to build/scan/push the image to ECR and update the ECS service.

## Phase 0 - Local preparation
1) Requirements: AWS CLI configured (admin or equivalent), Docker, Python 3.11+, Make (optional), git, GitHub Actions enabled on the repo fork.
2) Clone the fork and create a personal branch.
3) Optional: add a Makefile with `build`, `push`, `deploy`.

## Phase 1 - Build and push the image
1) In the API root (`entregas/challenge-01/app/api`, copy in `devops/challenge-01/api`), create the Dockerfile (example):
   ```Dockerfile
   FROM python:3.11-slim
   WORKDIR /app
   COPY requirements.txt .
   RUN pip install --no-cache-dir -r requirements.txt
   COPY . .
   CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
   ```
2) Create the ECR repository:
   ```bash
   aws ecr create-repository --repository-name fastapi-vars --region <region>
   ```
3) Login to ECR and push:
   ```bash
   aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <account>.dkr.ecr.<region>.amazonaws.com
   docker build -t fastapi-vars:latest .
   docker tag fastapi-vars:latest <account>.dkr.ecr.<region>.amazonaws.com/fastapi-vars:latest
   docker push <account>.dkr.ecr.<region>.amazonaws.com/fastapi-vars:latest
   ```

## Phase 2 - Provision infrastructure (network, security, storage)
1) Create a VPC (e.g., 10.0.0.0/16), 2 public and 2 private subnets in distinct AZs, an Internet Gateway, and NAT Gateways (ideally one per AZ). Use VPC Quick Create or CloudFormation/Terraform.
2) Security Groups:
   - SG-ALB: allow 80/443 from 0.0.0.0/0; allow egress 0.0.0.0/0.
   - SG-ECS: allow 8000/health from SG-ALB; allow egress 0.0.0.0/0 (via NAT).
3) Create the Load Balancer:
   - Public ALB in public subnets with SG-ALB.
   - Listener 80 redirects to 443 if TLS; listener 443 with ACM cert (issued for your Route53 domain).
   - Target group HTTP on port 8000, health check path `/`.
4) Create secrets:
   - Secrets Manager: secret `fastapi-vars-admin` with keys `ADMIN_USER` and `ADMIN_PASS`. Enable rotation if desired.
   - Allow access via the ECS task role.
5) Optionally create an S3 bucket for ALB/WAF logs (SSE-KMS).

## Phase 3 - ECS cluster and service (Fargate)
1) Create ECS cluster (Fargate).
2) Create task definition:
   - Fargate compatibility, CPU/Mem e.g., 0.25 vCPU / 512 MB (adjust to load).
   - Container image: `<account>.dkr.ecr.<region>.amazonaws.com/fastapi-vars:latest`.
   - Expose port 8000; health check HTTP `/`.
   - Logs: awslogs driver to group `/ecs/fastapi-vars`.
   - Env vars from Secrets Manager (`ADMIN_USER`, `ADMIN_PASS`).
   - Task IAM role with permissions to read the secret and send logs/metrics.
3) Create ECS service:
   - Min 2 replicas, rolling updates, private subnets, attach to the ALB target group, disable public IP assignment.
   - Auto Scaling: target CPU 60% (e.g., min 2, max 6).

## Phase 4 - DNS, TLS, and WAF (optional, recommended)
1) Create hosted zone in Route53 and an A/AAAA record pointing to the ALB (or use CloudFront if you need cache/geo).  
2) Issue ACM certificate for the domain and attach to listener 443.  
3) Create a WAF ACL and associate it with ALB/CloudFront with basic managed rules (SQLi, XSS, rate limit).

## Phase 5 - Observability and SRE basics
1) CloudWatch Logs with retention (e.g., 30 days) for the app.  
2) CloudWatch Alarms:
   - ALB 5xx above threshold.  
   - ALB latency p95 high.  
   - ECS service CPU/Memory above 80% sustained.  
   - Integrate with SNS/Slack (Webhook via Lambda) for alerts.  
3) Optional AWS X-Ray for tracing.  
4) CloudTrail enabled in the account (audit) plus guardrails (Config, IAM Access Analyzer).

## Phase 6 - CI/CD (GitHub Actions)
Suggested workflow (`.github/workflows/deploy.yml`):
1) Triggers: push to main (prod) and staging branch.  
2) Jobs:
   - `lint/test`: run tests (if added), flake8/ruff, optional mypy.  
   - `build-and-push`:
     - Login to ECR via `aws-actions/amazon-ecr-login`.  
     - Build and push the image tagged with SHA and `latest`.  
   - `deploy`:
     - Update task definition with new image (generate JSON via AWS CLI or `amazon-ecs-render-task-definition`).  
     - Run `aws ecs update-service --cluster <cluster> --service <service> --force-new-deployment`.  
3) GitHub workflow secrets:
   - `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`, `ECR_REGISTRY`, `ECR_REPOSITORY`, `ECS_CLUSTER`, `ECS_SERVICE`.  
4) Artifacts/control:
   - Use versioned tags (e.g., semver) for releases.  
   - Block deploy if tests fail.

## Phase 7 - Validation
1) Health via ALB: `curl -u <ADMIN_USER>:<ADMIN_PASS> https://<domain>/`.  
2) Check CloudWatch logs and ALB healthy targets.  
3) Simulate failure (stop a task) and validate auto-recovery/auto-scaling.

## Final notes
- The entire flow can be codified in Terraform/CloudFormation for reproducibility: VPC, ALB, SGs, ECS Service, ECR, Secrets, IAM, CloudWatch, Route53, WAF.  
- For minimal dev cost, use 1 NAT (shared) and fewer replicas; for prod keep 2 NAT and 2+ tasks.
