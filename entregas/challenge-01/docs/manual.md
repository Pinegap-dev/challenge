# Manual de provisionamento - Challenge 01 (FastAPI no ECS Fargate)

## Prerequisitos locais
1) AWS CLI configurado com perfil com acesso admin ou equivalente.
2) Terraform >= 1.6 (se usar IaC).
3) Docker instalado para buildar imagens.
4) git + acesso ao fork do repo.

## Visao geral
- Arquitetura: VPC (2 AZ) com sub-redes publicas (ALB/NAT) e privadas (ECS), ALB, ECS Fargate, ECR, Secrets/SSM para credenciais, CloudWatch Logs, DNS/TLS opcional.
- IaC disponivel em `entregas/challenge-01/iac/` (modulos `network` e `ecs_fastapi`).

## Passo a passo (com Terraform)
1) Ajuste variaveis em `entregas/challenge-01/iac/main.tf`:
   - `task_image` (URI do ECR), `admin_user`, `admin_pass` (ideal usar Secrets Manager depois), `region`, `environment`, `vpc_cidr`.
2) No diretorio `entregas/challenge-01/iac`:
   ```bash
   terraform init
   terraform plan -var 'environment=hml'
   terraform apply -var 'environment=hml' -auto-approve
   ```
   Outputs importantes: `alb_dns`, `service_name`.
3) (Opcional) Crie record DNS no Route53 apontando para `alb_dns` e associe certificado ACM (listener 443) + WAF se desejar.

## Passo a passo (build e push da imagem)
1) No repo `entregas/challenge-01/app/api` (copia de referencia em `devops/challenge-01/api`), crie `Dockerfile` (ja descrito em `parte1.md`) ou use existente.
2) Criar repositorio no ECR:
   ```bash
   aws ecr create-repository --repository-name fastapi-vars --region <regiao>
   ```
3) Fazer login e push:
   ```bash
   aws ecr get-login-password --region <regiao> | docker login --username AWS --password-stdin <account>.dkr.ecr.<regiao>.amazonaws.com
   docker build -t fastapi-vars:latest .
   docker tag fastapi-vars:latest <account>.dkr.ecr.<regiao>.amazonaws.com/fastapi-vars:latest
   docker push <account>.dkr.ecr.<regiao>.amazonaws.com/fastapi-vars:latest
   ```
4) Atualize `task_image` no Terraform com o URI da imagem.

## Passo a passo (CI/CD exemplo GitHub Actions)
1) Crie secrets/vars no repo:
   - `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`, `ECR_REGISTRY`, `ECR_REPOSITORY`, `ECS_CLUSTER`, `ECS_SERVICE`.
2) Crie workflow com stages:
   - lint/test (se houver), build/push imagem para ECR, `aws ecs update-service --force-new-deployment`.
3) Configure IAM para o runner (OIDC + role assume).

## Validacao
1) `curl -u <ADMIN_USER>:<ADMIN_PASS> http://<alb_dns>/` deve retornar JSON da API.
2) Verificar targets healthy no ALB e logs no CloudWatch.
3) Simular parada de task (ECS console) e conferir re-criacao/health check.

## Ajustes opcionais
- Mover `ADMIN_USER`/`ADMIN_PASS` para Secrets Manager/SSM e referenciar via task definition (envFrom).
- Habilitar TLS com ACM e listener 443 no ALB.
- Adicionar WAF (gerenciado) ao ALB/CloudFront.
