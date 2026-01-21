# Pipelines de deploy (Challenge 02)

Arquivos: `.github/workflows/deploy-iac.yml` (infra) e `.github/workflows/deploy-app.yml` (aplicaçao) dentro deste desafio. Ambos usam AWS + Kubernetes (EKS) e mantêm os artefatos em `entregas/challenge-02`.

## deploy-iac.yml (IaC Terraform)
- **Caminho IaC:** `technical-challenges/entregas/challenge-02/iac` (reutiliza módulos do challenge-04).
- **O que faz:** init/fmt/validate/plan/apply do Terraform para VPC, KMS/S3, ECR, Aurora, EKS, Batch/Step Functions. Seleciona `hml` (develop) ou `prod` (main) ou entrada manual.
- **Segredos/vars:** `AWS_ROLE_TO_ASSUME` (obrigatório), `TF_VAR_DB_PASSWORD` (secret), `BATCH_JOB_IMAGE` (var opcional), `AWS_REGION`.
- **Gatilhos:** push em `main`/`develop` que atinjam `entregas/challenge-02` ou os módulos herdados de `entregas/challenge-04/modules`, ou manual.
- **Saída esperada:** state aplicado e outputs do Terraform (VPC, buckets, Aurora, EKS, Batch/SFN).

## deploy-app.yml (Aplicação em Kubernetes)
- **Caminhos de app:** opcionais `technical-challenges/devops/challenge-02/api` e `/web` (se contiverem Dockerfile). Se não existirem, usar imagens já publicadas via vars `API_IMAGE` e `WEB_IMAGE`.
- **O que faz:** descobre registry ECR → (opcional) build/push imagens API e Web → kubeconfig do EKS → cria namespace → renderiza manifests em `entregas/challenge-02/k8s/` via `envsubst` → `kubectl apply` (Deployment/Service para API e Web).
- **Segredos/vars:** `AWS_ROLE_TO_ASSUME` (obrigatório), `AWS_REGION`, `EKS_CLUSTER_NAME`, `K8S_NAMESPACE`, `API_DEPLOYMENT`, `WEB_DEPLOYMENT`, `API_IMAGE`/`WEB_IMAGE` (se não for buildar), `ECR_API_REPOSITORY`/`ECR_WEB_REPOSITORY` (para build).
- **Gatilhos:** push em `main`/`develop` que atinjam `entregas/challenge-02` ou `devops/challenge-02`, ou manual (staging por default; prod em main).

## Observações de Kubernetes
- Manifests base em `entregas/challenge-02/k8s/` (API porta 8000; Web porta 3000). Ajuste réplicas, probes e ingress conforme necessário.
- Certifique-se de que o cluster EKS e o namespace existam (IaC cria o cluster; o pipeline cria o namespace se faltar). Imagens devem estar no ECR acessível ao cluster.
