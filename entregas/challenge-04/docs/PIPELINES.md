# Pipelines de deploy (Challenge 04)

Arquivos: `.github/workflows/deploy-iac.yml` (infra) e `.github/workflows/deploy-app.yml` (aplicação). Ambos ficam em `entregas/challenge-04` e orquestram Terraform + rollout em Kubernetes (EKS).

## deploy-iac.yml (IaC Terraform)
- **Caminho IaC:** `technical-challenges/entregas/challenge-04/iac`.
- **O que faz:** init/fmt/validate/plan/apply do Terraform modular (network, kms, s3, ecr, rds, eks, batch/step functions). Seleciona `hml` (develop) ou `prod` (main) ou manual.
- **Segredos/vars:** `AWS_ROLE_TO_ASSUME` (obrigatório), `TF_VAR_DB_PASSWORD` (secret), `BATCH_JOB_IMAGE` (var opcional), `AWS_REGION`.
- **Edge opcional:** habilite CloudFront/WAF/Route53/ACM com `ENABLE_EDGE=true` e configure `DOMAIN_NAME`, `HOSTED_ZONE_ID`, `ORIGIN_DOMAIN_NAME`, opcional `ACM_CERTIFICATE_ARN`, `ENABLE_WAF`.
- **Gatilhos:** push em `main`/`develop` que atinjam `entregas/challenge-04`, ou manual.
- **Saída esperada:** state aplicado com VPC/buckets/KMS/ECR/Aurora/EKS/Batch/Step Functions.

## deploy-app.yml (Aplicação em Kubernetes)
- **Caminhos de app:** opcionais `technical-challenges/devops/challenge-04/api` e `/web` (se contiverem Dockerfile). Se não existirem, usar imagens já publicadas via vars `API_IMAGE` e `FRONT_IMAGE`.
- **O que faz:** descobre registry ECR → (opcional) build/push API e Front → kubeconfig do EKS → cria namespace → renderiza manifests em `entregas/challenge-04/k8s/` via `envsubst` → `kubectl apply` (Deployment/Service para API e Front).
- **Segredos/vars:** `AWS_ROLE_TO_ASSUME` (obrigatório), `AWS_REGION`, `EKS_CLUSTER_NAME`, `K8S_NAMESPACE`, `API_DEPLOYMENT`, `FRONT_DEPLOYMENT`, `API_IMAGE`/`FRONT_IMAGE` (se não for buildar), `ECR_API_REPOSITORY`/`ECR_FRONT_REPOSITORY` (para build).
- **Gatilhos:** push em `main`/`develop` que atinjam `entregas/challenge-04` ou `devops/challenge-04`, ou manual (staging por default; prod em main).

## Observações de Kubernetes
- Manifests base em `entregas/challenge-04/k8s/` (API porta 8000; Front porta 3000). Ajuste réplicas, probes, ingress/serviço (ALB/NGINX) e envs conforme a app real.
- Certifique-se de que o cluster EKS e o namespace existam (IaC cria cluster; pipeline cria namespace se faltar). Imagens precisam estar no ECR acessível ao cluster.
