# Estrategia de deploy serverless (Challenge 03)

## Stack
- API Gateway HTTP API expondo rota raiz para Lambda.
- Lambda rodando container da app Flask (imagem no ECR), com timeout ex.: 10s e memoria 256-512MB.
- Variavel `NAME` fornecida via SSM Parameter Store (SecureString) ou env por stage; permissao IAM especifica para leitura.
- Logs no CloudWatch; alarms para 5xx/latencia.

## Ambientes
- homologacao (staging): alias `staging` na Lambda, stage do API Gateway `stg`, variaveis `NAME=Staging`.
- producao: alias `prod` e stage `prod`, variaveis `NAME=Prod`.
- Cada deploy atualiza a mesma funcao com imagem nova e publica/atualiza o alias.

## CI/CD resumido
1) Trigger:
   - push para `develop` -> deploy staging
   - push para `main` -> deploy prod (com aprovacao opcional)
2) Passos:
   - Lint/test (ruff/black/pytest)
   - Build imagem, push para ECR com tag do SHA
   - `aws lambda update-function-code --function-name <fn> --image-uri <tag>`
   - `aws lambda update-alias --function-name <fn> --name <alias> --function-version <versao>` (capturar da chamada de update)
   - Atualizar stage do API Gateway se necessario
3) Secrets/vars no GitHub:
   - `AWS_ROLE_TO_ASSUME`, `AWS_REGION`, `ECR_REPOSITORY`, `LAMBDA_FUNCTION_NAME`
   - `STG_NAME`, `PROD_NAME` (ou usar SSM e apenas referenciar os parametros)
