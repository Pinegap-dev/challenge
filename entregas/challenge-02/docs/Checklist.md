# Arquitetura bioinformatica na AWS (Challenge 02)

Objetivo: entregar a arquitetura e provisionamento para o app bioinformatica (frontend Django, API FastAPI) com pipeline de processamento via Step Functions + AWS Batch, buckets S3 (uploads/resultados), Aurora Postgres, imagens no ECR, rodando em EKS com CI/CD.

## Arquitetura proposta (alto nivel)
- VPC 2+ AZ com sub-redes publicas (ALB/ingress/NAT) e privadas (EKS, RDS, Batch), NAT por AZ.
- Entrada: Route53 -> CloudFront + WAF (opcional) -> ALB/Ingress -> EKS (deployments Django e FastAPI).
- Processamento: Step Functions orquestra jobs no AWS Batch (Fargate/EC2 Spot) lendo S3 uploads e gravando S3 resultados (lifecycle 365d / 5y, SSE-KMS, block public).
- Dados: RDS Aurora Postgres multi-AZ. Credenciais em Secrets Manager/SSM com rotation; acesso via SG apenas da API.
- Imagens: repositórios ECR (frontend/backend/batch) com scan on push; pods com IRSA.
- Observabilidade: CloudWatch logs/alarms, opcional Prometheus/Grafana, SNS/Slack para alertas.

## Fase 0 - Preparacao local
1) AWS CLI configurado, Terraform >= 1.6, Docker, kubectl/Helm (ou ArgoCD), git.
2) Configurar conta/repositorio com acesso ao ECR (OIDC do GitHub Actions ou chaves).
3) Clonar repo/fork e criar branch pessoal.

## Fase 1 - Build e push de imagens
1) Ajustar Dockerfiles dos serviços (Django, FastAPI, Batch worker).
2) Criar repos ECR e logar:
   ```bash
   aws ecr create-repository --repository-name <frontend|api|batch>
   aws ecr get-login-password --region <regiao> | docker login --username AWS --password-stdin <registry>
   docker build -t <image_uri> .
   docker push <image_uri>
   ```
3) Guardar URIs para usar no Terraform/manifests.

## Fase 2 - Provisionar base (Terraform)
1) Diretório: `entregas/challenge-02/iac/` (módulos locais em `iac/modules/`).
2) Ajustar variaveis em `main.tf`: `region`, `environment`, `db_password`, `batch_job_image`, tamanhos e tags.
3) Executar:
   ```bash
   terraform init
   terraform plan -var 'environment=hml'
   terraform apply -var 'environment=hml' -auto-approve
   ```
4) Outputs esperados: VPC/subnets, buckets, Aurora endpoint, EKS cluster name, Batch queue e State Machine ARN.

## Fase 3 - Deploy apps no EKS
1) Configurar kubeconfig: `aws eks update-kubeconfig --name <eks_cluster> --region <regiao>`.
2) Instalar ALB Ingress Controller, Cluster Autoscaler e habilitar IRSA.
3) Criar Secrets/ConfigMaps (DB creds, buckets, ARNs).
4) Aplicar manifests/Helm:
   - Django frontend com Service/Ingress.
   - FastAPI backend com Service/Ingress e acesso ao Aurora + S3.
   - HPA para CPU/mem se necessario.

## Fase 4 - Pipeline Batch/Step Functions
1) Validar Job Definition (imagem do worker) e Compute Environment (Fargate/Spot).
2) Garantir permissões IAM para FastAPI (IRSA) invocar `states:StartExecution` e `batch:SubmitJob`.
3) Testar fluxo: upload em S3 -> execucao Step Functions -> job Batch -> resultados no bucket de saida.

## Fase 5 - DNS, TLS e WAF
1) Emitir certificado ACM; configurar Route53 para dominios do frontend/API.
2) Se usar CloudFront, criar distro apontando para ALB/Ingress; associar WAF com regras gerenciadas + rate limit.
3) Listener 443 no ALB com redirect 80 -> 443.

## Fase 6 - Observabilidade e SRE
1) Logs: stdout dos pods para CloudWatch (driver awslogs) e logs do Batch.
2) Alarms: 5xx/latencia ALB, CPU/mem pods, conexoes RDS, fila/idade Batch, falhas Step Functions.
3) Backups: habilitar AWS Backup para Aurora; revisar retenção dos buckets.

## Fase 7 - CI/CD (GitHub Actions sugerido)
1) Stages: lint/test -> build/push imagens -> deploy (kubectl/Helm/ArgoCD) por ambiente (hml/prod).
2) Secrets/vars: `AWS_ROLE_TO_ASSUME`, `AWS_REGION`, `ECR_REPO_*`, `EKS_CLUSTER_NAME`, config do state machine/queue.
3) Gates: approvals para prod; tfsec/checkov opcionais.

## Fase 8 - Validacao
1) Acessar ingress/CloudFront e validar rotas Django e API.
2) Submeter upload e conferir pipeline Batch/Step Functions ate salvar resultados.
3) Checar alarms/logs e metricas; simular falha de job para validar alertas.
