# Challenge 02 - arquitetura e provisionamento

## Objetivo
Propor arquitetura AWS para app bioinformatica (frontend Django, API FastAPI em Kubernetes) com Step Functions + Batch para pipeline de espectrometria, S3 para uploads/resultados, RDS para dados, ECR para imagens. Entrega inclui diagramas, passo a passo de provisionamento e material de apresentacao.

## Arquitetura proposta (alto nivel)
- Rede: VPC 2+ AZ, sub-redes publicas (ALB/ingress/NAT) e privadas (EKS, RDS, Batch). NAT por AZ.
- Entrada: Route53 -> CloudFront + WAF -> ALB/Ingress -> EKS (deployments Django e FastAPI).
- Processamento: Step Functions orquestra jobs no AWS Batch (Fargate ou EC2 Spot) que leem uploads do S3 e escrevem resultados em bucket de saida.
- Dados: RDS Aurora Postgres multi-AZ. Credenciais em Secrets Manager/SSM com rotation.
- Armazenamento: S3 uploads com lifecycle 365 dias; S3 resultados com lifecycle 5 anos; ambos com SSE-KMS, versionamento e bloqueio publico.
- Imagens: Amazon ECR com scan habilitado; CI publica imagens versionadas.
- Observabilidade: CloudWatch (logs/alarms), Prometheus/Grafana (via EKS add-on), AWS Backup para RDS, SNS/Slack para alertas.
- Segurança: WAF, SGs restritos, IRSA para pods, IAM least privilege, CloudTrail/Config habilitados, KMS para encriptacao, S3 block public.

## Passo a passo de provisionamento (resumido)
1) Rede: criar VPC, sub-redes, IGW, NATs, rotas. SGs para ALB, EKS nodes/pods, RDS, Batch, bastion opcional.
2) ECR: criar repos para frontend/backend/batch; habilitar scan.
3) EKS: criar cluster (eksctl/terraform), node groups (on-demand + spot). Ativar OIDC e IRSA. Instalar ingress controller (ALB Ingress Controller) e autoscaler (cluster-autoscaler).
4) RDS Aurora Postgres: cluster multi-AZ em sub-redes privadas; SG permite trafego apenas da API FastAPI. Backups automáticos e snapshots.
5) S3: buckets `uploads` (lifecycle 365 dias) e `resultados` (5 anos); versionamento, SSE-KMS, block public, logging habilitado.
6) Step Functions + Batch: criar job definitions (Fargate/EC2), compute environments (spot/on-demand mix) e queues; states machine que consome do S3 e escreve no bucket de resultados; permissões via IAM.
7) Deploy apps: buildar imagens (Django, FastAPI, workers) e publicar no ECR. Aplicar manifests Helm/k8s com envs via Secrets Manager/SSM, configmaps, HPA. Ingress exposto via ALB.
8) DNS/TLS: emitir certificado ACM; apontar dominio no Route53; associar ao ALB/CloudFront; WAF com regras gerenciadas + rate limiting.
9) Observabilidade: configurar log drivers (stdout -> CloudWatch), metricas com Prometheus/Grafana, alarms CloudWatch (5xx, latencia, fila Batch, RDS conexoes), SNS/Slack.
10) CI/CD: GitHub Actions com stages lint/test -> build/push imagens -> deploy (kubectl/Helm/ArgoCD) por ambiente (hml/prod); aprovacoes manuais para prod.

## Diagrama 
- Gerar e exportar o diagrama em `diagramas/`.

## Materiais de apresentacao
- Preparar slides com a arquitetura, fluxos principais, SLO/SLI, e plano de resposta a incidentes. Incluir Q&A de SRE do enunciado.
