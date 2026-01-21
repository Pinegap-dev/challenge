# Pipelines de deploy (Challenge 03)

Arquivos: `.github/workflows/deploy-iac.yml` (infra) e `.github/workflows/deploy-app.yml` (aplicação). Ambos ficam em `entregas/challenge-03` e usam AWS + Kubernetes (EKS) para o rollout da app Flask.

## deploy-iac.yml (IaC Terraform)
- **Caminho IaC:** `technical-challenges/entregas/challenge-03/iac`.
- **O que faz:** init/fmt/validate/plan/apply do Terraform que hoje cria Lambda + API Gateway (state machine existente). Seleciona `hml` (develop) ou `prod` (main) ou manual.
- **Segredos/vars:** `AWS_ROLE_TO_ASSUME` (obrigatório), `LAMBDA_IMAGE_URI` (var opcional), `NAME_VALUE` (var opcional), `AWS_REGION`.
- **Gatilhos:** push em `main`/`develop` que atinjam `entregas/challenge-03`, ou manual.
- **Saída esperada:** state aplicado com Lambda/API Gateway conforme o Terraform.

## deploy-app.yml (Aplicação em Kubernetes)
- **Caminho app:** `technical-challenges/entregas/challenge-03/app` (Dockerfile builda a app Flask). Cópia de referência permanece em `devops/challenge-03`.
- **O que faz:** build/push da imagem no ECR → kubeconfig do EKS → cria namespace → renderiza manifests `entregas/challenge-03/k8s/` via `envsubst` → `kubectl apply` (Deployment/Service).
- **Segredos/vars:** `AWS_ROLE_TO_ASSUME` (obrigatório), `AWS_REGION`, `ECR_REPOSITORY`, `EKS_CLUSTER_NAME`, `K8S_NAMESPACE`, `DEPLOYMENT_NAME`, `NAME_VALUE` (valor para env `NAME`).
- **Gatilhos:** push em `main`/`develop` que atinjam `devops/challenge-03` ou `entregas/challenge-03`, ou manual (staging default; prod em main).

## Observações de Kubernetes
- Manifests base em `entregas/challenge-03/k8s/` (porta 8000). Ajuste réplicas/probes/ingress conforme necessário.
- Certifique-se de que o cluster EKS e o namespace existam; o pipeline cria o namespace se faltar. Imagem precisa estar no ECR acessível pelo cluster.

## Docs (GitHub Pages)
- Workflow `entregas/challenge-03/.github/workflows/docs.yml` publica `entregas/challenge-03/app/docs/` no GitHub Pages (environment github-pages), acionado apenas quando `entregas/challenge-03/app/docs/` (ou o próprio workflow) muda.
