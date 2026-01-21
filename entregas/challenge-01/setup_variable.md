# Como cadastrar variaveis e segredos (Challenge 01)

1. No GitHub, acesse `Settings > Secrets and variables > Actions`.
2. Em **Variables**, adicione os pares nome/valor listados em `VARIABLES.md` (AWS_REGION, TASK_IMAGE, ECR_REPOSITORY, EKS_CLUSTER_NAME, K8S_NAMESPACE, DEPLOYMENT_NAME, ADMIN_SECRET_NAME).
3. Em **Secrets**, adicione `AWS_ROLE_TO_ASSUME`, `ADMIN_USER`, `ADMIN_PASS`.
4. Certifique-se de que os valores batem com seus recursos AWS (ECR, EKS, namespace) e credenciais da API.
5. Rode os workflows (`deploy-iac.yml` e `deploy-app.yml`) somente depois de tudo cadastrado; cada workflow valida a presenca das variaveis e falha se algo estiver faltando.
