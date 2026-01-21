# Pipelines de deploy (Challenge 01)

Arquivos de pipeline: `.github/workflows/deploy-iac.yml` (infra) e `.github/workflows/deploy-app.yml` (aplicaçao). Ambos rodam em GitHub Actions e usam AWS + Kubernetes.

## deploy-iac.yml (IaC Terraform)
- **Caminho IaC:** `technical-challenges/entregas/challenge-01/iac`.
- **O que faz:** init/fmt/validate/plan/apply do Terraform para criar rede, ALB, ECS/EKS-ready sub-redes e service FastAPI base (infra descrita no módulo). Seleciona ambiente `hml` (develop) ou `prod` (main) ou entrada manual.
- **Segredos/vars:** `AWS_ROLE_TO_ASSUME` (obrigatório), `ADMIN_USER`/`ADMIN_PASS` (opcional, injeta env), `TASK_IMAGE` (opcional override de imagem).
- **Gatilhos:** push em `main`/`develop` que toquem `entregas/challenge-01/**` ou disparo manual.
- **Saída esperada:** infra aplicada com ALB/serviço e outputs do Terraform no log.

## deploy-app.yml (Aplicação em Kubernetes)
- **Caminho app:** `technical-challenges/entregas/challenge-01/app` (Dockerfile construindo a FastAPI). Cópia de referência permanece em `devops/challenge-01`.
- **O que faz:** builda imagem, push no ECR e faz rollout no Kubernetes (EKS) aplicando os manifests em `entregas/challenge-01/k8s/` com `kubectl`.
- **Fluxo:** login AWS/ECR → build/push → kubeconfig do EKS → cria namespace → cria/atualiza Secret com `ADMIN_USER`/`ADMIN_PASS` → renderiza Deployment/Service via `envsubst` → `kubectl apply`.
- **Segredos/vars:** `AWS_ROLE_TO_ASSUME` (obrigatório), `ADMIN_USER`/`ADMIN_PASS` (secret), `AWS_REGION`, `ECR_REPOSITORY`, `EKS_CLUSTER_NAME`, `K8S_NAMESPACE`, `DEPLOYMENT_NAME`, `ADMIN_SECRET_NAME`.
- **Gatilhos:** push em `main`/`develop` que atinjam `devops/challenge-01` ou `entregas/challenge-01`, ou manual. Ambiente `staging` (develop) e `prod` (main) por padrão.

## Observaçoes de Kubernetes
- Os manifests base estao em `entregas/challenge-01/k8s/` e sao renderizados com a imagem gerada no pipeline.
- Certifique-se de que o cluster EKS e o namespace configurados existem ou que a IaC os tenha criado; o pipeline cria o namespace se faltar.
- Credenciais ADMIN ficam em Secret Kubernetes (`ADMIN_SECRET_NAME`). Ajuste probes/replicas conforme carga.
