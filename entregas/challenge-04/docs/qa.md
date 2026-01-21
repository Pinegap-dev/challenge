# Q&A - Challenge 04 (IaC modular: Next.js + FastAPI + Batch/Step Functions)

## Por que modularizar o Terraform?
- Facilita reuso e manutencao (network, kms/s3, ecr, rds, eks, batch_sfn). Permite aplicar/atualizar partes e versionar modulos. Segregacao de responsabilidades e menor blast radius.

## Como a arquitetura escala e garante HA?
- VPC multi-AZ; EKS com node group autoscaling; HPA nos pods; Aurora Postgres multi-AZ; Batch com CE spot/on-demand; ALB/Ingress multi-AZ; buckets S3 com KMS. Pode incluir CloudFront + WAF para borda (modulo `edge`).

## Por que EKS para API/Front?
- Padrao Kubernetes: facilita IRSA, ingress controller, HPA, observabilidade (Prometheus/Grafana), e blue/green/Canary via ingress/Argo Rollouts. Se front for static, pode ir para S3+CloudFront (usando `edge`); se SSR, pode rodar em EKS/ECS.

## Como acionar Batch/Step Functions?
- API FastAPI usa role IRSA com permissoes `states:StartExecution` e `batch:SubmitJob`. State machine chama Batch queue/Job Definition com imagem `batch_job_image`. Jobs leem S3 uploads e gravam S3 resultados (lifecycle 365d/5y).

## Seguranca e dados sensiveis?
- Secrets em Secrets Manager/SSM; IRSA para pods; SGs restritos (ALB -> pods; pods -> RDS); KMS para S3; TLS em transito; WAF/CloudFront opcional via `edge`; CloudTrail/Config habilitados; roles least privilege.

## Observabilidade/SRE?
- Logs stdout para CloudWatch; Container Insights/Prometheus para metricas; alarms para 5xx/latencia ALB, CPU/mem pods, conexoes RDS, idade/fila Batch, falhas Step Functions. Opcional tracing (X-Ray/OTel).

## CI/CD?
- Pipelines separadas: Terraform (plan/apply por ambiente) e app (build/push imagens API/Front, deploy kubectl/Helm/ArgoCD). OIDC para AWS. Scans de imagem (ECR) e tfsec/checkov recomendados. Aprovações para prod.

## Rollback e releases?
- Imagens taggeadas por SHA/semver; reverter Deployment/Helm release ou apontar Task/Job Definition anterior. Terraform com workspaces/state remoto e planos revisados antes de apply.

## Perguntas da sessao "Entrega" (SRE)
- App nao acessa o banco, o que fazer? Verificar se SG/ACL permitem porta do RDS, endpoint/hostname corretos e secrets válidos (SSM/Secrets). Conferir health do Aurora e failover. Checar se o pod tem rota/NAT para acessar o endpoint privado.
- Como debugar? Logs da app/pods, eventos do RDS, métricas de conexões, VPC Reachability Analyzer, `kubectl exec` + `psql` via bastion, e testes de conectividade na mesma subnet/SG. Replicar em staging.
- Como evitar que volte a ocorrer? IaC versionado para SG/rotas, rotation/validate de credenciais, liveness/readiness que validam conexões, alarms para erros de conexao e latencia DB, testes de integração em CI apontando para um banco de QA.
- Como definir SLO/SLI e acompanhar? SLO 99.9% disponibilidade API; SLIs: taxa 2xx/total, latencia p95, erro DB (timeouts/conexoes falhas), idade fila Batch, sucesso Step Functions. Monitorar via CloudWatch/Prometheus + dashboards e alertas, revisando SLO periodicamente.
