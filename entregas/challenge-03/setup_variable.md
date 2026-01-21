# Como cadastrar variaveis e segredos (Challenge 03)

1. Acesse `Settings > Secrets and variables > Actions` no repositório.
2. Em **Variables**, crie os itens listados em `VARIABLES.md` (AWS_REGION, LAMBDA_IMAGE_URI, NAME_VALUE, ECR_REPOSITORY, EKS_CLUSTER_NAME, K8S_NAMESPACE, DEPLOYMENT_NAME, STG_NAME, PROD_NAME).
3. Em **Secrets**, crie `AWS_ROLE_TO_ASSUME`.
4. Certifique-se de que as URIs e nomes de cluster/namespace reflitam seu ambiente real.
5. Execute os workflows (`deploy-iac.yml`, `deploy-app.yml` e `devops/challenge-03` `ci-cd.yml`) apos preencher tudo; as pipelines validam a presenca das variaveis e falham se faltar algo. Os builds usam o path `entregas/challenge-03/app` (copia mantida em `devops/challenge-03`).
