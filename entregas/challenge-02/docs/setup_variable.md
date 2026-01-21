# Como cadastrar variaveis e segredos (Challenge 02)

1. Abra `Settings > Secrets and variables > Actions` no repositório.
2. Em **Variables**, crie todos os itens descritos em `VARIABLES.md` (AWS_REGION, BATCH_JOB_IMAGE, EKS_CLUSTER_NAME, K8S_NAMESPACE, API_DEPLOYMENT, WEB_DEPLOYMENT, ECR_API_REPOSITORY, ECR_WEB_REPOSITORY; opcionalmente API_IMAGE/WEB_IMAGE se ja tiver imagens prontas).
3. Em **Secrets**, crie `AWS_ROLE_TO_ASSUME` e `TF_VAR_DB_PASSWORD`.
4. Use URIs de ECR/region/cluster correspondentes ao ambiente real.
5. Somente depois de todos os valores preenchidos execute os workflows `deploy-iac.yml` e `deploy-app.yml`; eles falham se algo obrigatorio estiver ausente.
