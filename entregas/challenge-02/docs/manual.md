# Manual de provisionamento - Challenge 02 (Django + FastAPI + Batch/Step Functions)

## Prerequisitos
1) AWS CLI configurado; Terraform >= 1.6.
2) Docker para buildar imagens.
3) kubectl/Helm (para aplicar manifests) ou ArgoCD se preferir GitOps.
4) Repo com acesso a ECR (OIDC ou chaves de acesso) e permissao de admin/infra.

## Visao geral
- Arquitetura: VPC 2+ AZ, ALB/Ingress, EKS (Django frontend + FastAPI), Aurora Postgres, S3 (uploads 365d, resultados 5y, SSE-KMS), ECR (imagens), Step Functions + Batch (Fargate/Spot), observabilidade (CloudWatch, opcional Prometheus/Grafana).
- IaC base em `entregas/challenge-02/iac/` reutilizando modulos do challenge 04.

## Passo a passo com Terraform
1) Configure variaveis em `entregas/challenge-02/iac/main.tf`:
   - `db_password` (trocar `CHANGE_ME`), `batch_job_image`, `region`, `environment`.
2) Execute:
   ```bash
   cd entregas/challenge-02/iac
   terraform init
   terraform plan -var 'environment=hml'
   terraform apply -var 'environment=hml' -auto-approve
   ```
   Outputs: VPC, subnets, buckets, Aurora endpoint, EKS cluster name, Batch queue, State machine ARN.
3) Configure kubeconfig para o cluster:
   ```bash
   aws eks update-kubeconfig --name <eks_cluster_name> --region <region>
   ```

## Imagens e ECR
1) Buildar e publicar imagens:
   - Django: `<account>.dkr.ecr.<regiao>.amazonaws.com/<project>/frontend:<tag>`
   - FastAPI: `<account>.dkr.ecr.<regiao>.amazonaws.com/<project>/api:<tag>`
   - Batch workers: `<account>.dkr.ecr.<regiao>.amazonaws.com/<project>/batch:<tag>`
2) Para cada imagem:
   ```bash
   aws ecr get-login-password --region <regiao> | docker login --username AWS --password-stdin <registry>
   docker build -t <image_uri> .
   docker push <image_uri>
   ```

## Deploy no EKS
1) Instale ALB Ingress Controller, Cluster Autoscaler e IRSA (via Helm):
   ```bash
   helm repo add eks https://aws.github.io/eks-charts
   helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=<eks_cluster_name> --set serviceAccount.create=true --set region=<region>
   ```
2) Crie Secrets/ConfigMaps:
   - Credenciais DB via Secrets Manager + IRSA ou SealedSecrets/Secrets Kubernetes.
   - Config de buckets e endpoints de fila/State Machine via ConfigMap.
3) Apply manifests/Helm charts para:
   - Django (frontend) com Service/Ingress.
   - FastAPI com Service/Ingress, apontando para Aurora e S3.
   - HPA (CPU/mem).
4) Verifique ingress (ALB) criado e endpoints.

## Step Functions / Batch
1) State Machine e Queue já criadas pelo Terraform; atualize a Job Definition se precisar de imagem custom:
   - Ajuste `batch_job_image` no `main.tf` ou edite no console.
2) Conceda permissoes IAM ao serviço FastAPI (via IRSA) para `states:StartExecution` e `batch:SubmitJob`.

## DNS/TLS/WAF
1) Criar certificado ACM para o dominio (us-east-1 para uso em CloudFront).
2) Route53: crie records para app/ingress; se usar CloudFront, aponte o alias para a distribuição.
3) WAF: associe ao CloudFront ou ALB com regras gerenciadas + rate limit.

## Observabilidade e SRE
1) Logs: stdout dos pods para CloudWatch (driver awslogs) ou Prometheus/Grafana para métricas.
2) Alarms: 5xx/latência ALB, CPU/mem pods, conexões RDS, falhas Batch, idade da fila Batch.
3) Backup: habilite AWS Backup para Aurora.

## CI/CD (GitHub Actions sugerido)
1) Stages: lint/test -> build/push imagens -> deploy (kubectl/Helm/ArgoCD).
2) Secrets/vars:
   - `AWS_ROLE_TO_ASSUME`, `AWS_REGION`, `ECR_REPO_*`, `EKS_CLUSTER_NAME`, `KUBE_CONFIG` (ou configure via OIDC).
3) Gates: aprovação manual para `main`/prod; deploy automático para `develop`/hml.

## Validacao
1) Acessar ALB/CloudFront com DNS; verificar rota Django e API.
2) Submeter upload e acionar pipeline (Step Functions -> Batch) e conferir arquivos em S3 resultados.
3) Conferir métricas/alarms e logs.
