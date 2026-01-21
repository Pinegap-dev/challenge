# Q&A - Challenge 02 (Django + FastAPI + Batch/Step Functions)

## Como a arquitetura garante HA e escala?
- VPC multi-AZ, EKS com node groups autoscaling (on-demand + spot), ALB/Ingress multi-AZ, Aurora Postgres multi-AZ. HPA nos deployments. Batch CE com mix spot/on-demand. CloudFront para cache e WAF na borda.

## Por que EKS e nao ECS/App Runner?
- Dois servicos (Django frontend e FastAPI) e possivel extensao com sidecars/observabilidade; EKS facilita padronizacao k8s, IRSA, ingress controller, HPA, service mesh opcional. ECS seria viavel, mas EKS atende escala/observabilidade requerida.

## Como trata uploads e resultados (retencao)?
- S3 uploads com lifecycle de 365 dias; resultados com 5 anos. Ambos com SSE-KMS, versionamento e bloqueio publico. Opcional replicacao cross-region.

## Como proteger dados e acessos?
- IAM least privilege + IRSA para pods. SGs restritos (ALB -> pods; pods -> RDS). WAF no CloudFront/ALB. KMS para S3, TLS in transit, secrets em Secrets Manager/SSM. CloudTrail/Config habilitados.

## Como orquestra Batch/Step Functions?
- API invoca Step Functions (StartExecution) via role dedicada; state machine chama Batch submitJob. Job definition define imagem e recursos; CE mistura spot/on-demand para custo. Resiliência via retries/backoff.

## Como expor as apps?
- Route53 -> CloudFront + WAF -> ALB/Ingress -> Services no EKS. Certificados ACM. Path-based routing entre frontend e API.

## Observabilidade e SRE?
- Logs stdout -> CloudWatch; metrics via CloudWatch + Prometheus/Grafana; alarms para 5xx/latencia ALB, CPU/mem pods, conexoes RDS, fila/idade Batch, erros Step Functions. AWS Backup para RDS.

## CI/CD?
- GitHub Actions: lint/test -> build/push imagens -> deploy (kubectl/Helm/ArgoCD). Gates para prod. Scan de imagem (ECR), opcional tfsec/checkov.

## SLO/SLI e incidentes?
- SLO ex. 99.9% disponibilidade API; SLIs: 2xx/total, latencia p95, idade fila Batch, sucesso Step Functions. Runbooks para DB down (SG/credenciais/health), fila presa (Batch/CE), erro app (logs/traces).

## Custo?
- Spot em node groups e Batch, CloudFront para cache, lifecycle S3, sizing Aurora adequado, desligar staging em off-hours se possivel.

## Perguntas da sessao "Entrega" (SRE)
- Como resolver se a aplicacao nao acessa o banco? Checar secrets/creds (SSM/Secrets), SG/ACL bloqueando porta, parametro de endpoint incorreto, health do Aurora. Ação: revisar SG ingress/egress, rotas, rotação de credenciais, failover Multi-AZ.
- Como debugar? Logs da app/pod, eventos do RDS, `kubectl exec` e `psql` via bastion, VPC Reachability Analyzer, métricas de conexão/latencia. Replicar em staging com mesmo SG/creds.
- Como evitar recorrencia? Guardrails: IaC versionado, health checks automáticos, alarms (conexões RDS, 5xx API), rotation automatizada de secrets, testes de integração que validam conexão DB em CI.
- Como definir SLO/SLI e acompanhar? SLO 99.9% disponibilidade API; SLIs: taxa 2xx/total, latencia p95, erros DB (timeouts/failures), idade fila Batch. Monitorar via CloudWatch/Prometheus + alertas e dashboards, revisando trimestralmente.
