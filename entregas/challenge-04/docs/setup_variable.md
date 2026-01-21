# Como cadastrar variaveis e segredos (Challenge 04)

1. Va em `Settings > Secrets and variables > Actions` no repositorio.
2. Em **Variables**, crie todos os itens de `VARIABLES.md` (AWS_REGION, BATCH_JOB_IMAGE, EKS_CLUSTER_NAME, K8S_NAMESPACE, API_DEPLOYMENT, FRONT_DEPLOYMENT, ECR_API_REPOSITORY, ECR_FRONT_REPOSITORY e opcionalmente API_IMAGE/FRONT_IMAGE; API_BASE_URL para o front consumir a API; API_HOST/FRONT_HOST/ALB_CERT_ARN para o Ingress ALB; para edge opcional: ENABLE_EDGE, DOMAIN_NAME, HOSTED_ZONE_ID, ORIGIN_DOMAIN_NAME, ACM_CERTIFICATE_ARN, ENABLE_WAF).
3. Em **Secrets**, crie `AWS_ROLE_TO_ASSUME` e `TF_VAR_DB_PASSWORD`.
4. Use valores condizentes com sua infraestrutura (URIs ECR, nomes de cluster/namespace).
5. Rode os workflows (`deploy-iac.yml` e `deploy-app.yml`) apenas apos preencher tudo; eles validam a presenca das variaveis e falham se algo estiver ausente.
