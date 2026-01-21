# Variaveis do GitHub Actions (Challenge 03)

Configure em **Settings > Secrets and variables > Actions**.

## Actions Variables (obrigatorias)
- `AWS_REGION`: regiao AWS.
- `ECR_REPOSITORY`: repositorio ECR para build/push (pipeline app).
- `LAMBDA_FUNCTION_NAME`: nome da funcao Lambda (mesma usada na IaC).
- `NAME_VALUE`: valor default da env `NAME` (se nao usar os campos abaixo).
- `NAME_VALUE_STAGING` ou `STG_NAME`: opcional, valor de `NAME` para staging.
- `NAME_VALUE_PROD` ou `PROD_NAME`: opcional, valor de `NAME` para prod.
- `PROJECT`: (opcional) prefixo usado no Terraform (default: challenge03).

## Actions Secrets (obrigatorias)
- `AWS_ROLE_TO_ASSUME`: ARN da role para ECR/Lambda/Terraform.
