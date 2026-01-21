# Q&A - Challenge 01 (FastAPI no ECS Fargate)

## Como voce provisionou a rede?
- VPC com 2 AZ, sub-redes publicas (ALB/NAT) e privadas (ECS). Rotas publicas via IGW, privadas via NAT. SGs: ALB aberto em 80/443, tasks aceitam 8000 apenas do SG do ALB. DNS/TLS opcional via Route53+ACM.

## Por que ECS Fargate e nao EC2/EKS?
- Fargate remove gestao de nodes, reduz manutencao e custo de idle em ambiente pequeno; atende ao requisito de simplicidade. EKS serviria se houvesse multiplos servicos/sidecars ou necessidade de malha, mas aqui a carga é simples.

## Onde ficam as credenciais ADMIN_USER/ADMIN_PASS?
- Ideal: Secrets Manager ou SSM SecureString, injetados na task definition. Terraform pode referenciar `secrets` no container. Rotacao via Secrets Manager.

## Como garantir alta disponibilidade?
- ALB multi-AZ, ECS service com 2+ tasks em sub-redes distintas, health checks. Se usar NAT por AZ, resiliencia de egress. Escala horizontal via target tracking em CPU/mem ou custom metrics.

## Observabilidade?
- CloudWatch Logs (grupo /ecs/...), metricas ALB (5xx, latencia), ECS (CPU/mem), alarmes para SNS/Slack. Opcional X-Ray para tracing.

## Segurança?
- SG least privilege, nenhuma public IP nas tasks, TLS no ALB com ACM, WAF gerenciado opcional. IAM: exec role minimo, task role apenas para ler secret. S3/CloudTrail/Config habilitaveis para auditoria.

## Como fazer CI/CD?
- GitHub Actions: lint/test (se houver) -> build/push ECR -> update task definition -> force new deployment no service. OIDC para evitar chaves long-lived.

## Como versionar e rollback?
- Imagens taggeadas por SHA/semver, ECS service suporta deployment controller rolling; rollback via redeploy da task definition anterior.

## Custo e otimizacao?
- Fargate on-demand com sizing minimo (0.25 vCPU/0.5GB) em dev; reduzir NAT para 1 AZ em hml se aceitavel; desligar logs verbose.

## O que muda para prod?
- TLS/WAF obrigatorios, secrets em Secrets Manager com rotacao, NAT redundante, alarmes e runbooks, backups de configs (tf state, etc).
