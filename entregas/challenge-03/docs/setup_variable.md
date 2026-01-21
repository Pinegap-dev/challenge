# Como cadastrar variaveis e segredos (Challenge 03)

1. Acesse `Settings > Secrets and variables > Actions` no repositório.
2. Em **Variables**, crie os itens listados em `VARIABLES.md` (AWS_REGION, ECR_REPOSITORY, LAMBDA_FUNCTION_NAME, NAME_VALUE ou NAME_VALUE_STAGING/NAME_VALUE_PROD; opcional `PROJECT` para prefixo da IaC).
3. Em **Secrets**, crie `AWS_ROLE_TO_ASSUME`.
4. Execute os workflows (`deploy-iac.yml` e `deploy-app.yml`) apos preencher tudo; as pipelines validam a presenca das variaveis e falham se faltar algo. Os builds usam o path `entregas/challenge-03/app` (copia mantida em `devops/challenge-03`).
