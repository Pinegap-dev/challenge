# Deploy da API FastAPI na AWS (Challenge 01)

Objetivo: publicar a API FastAPI (usa vars `ADMIN_USER` e `ADMIN_PASS` para Basic Auth) em uma conta AWS limpa, com alta disponibilidade e CI/CD. Arquitetura escolhida: ECS Fargate por simplicidade (sem gerenciar nodes), ALB, Secrets Manager/SSM, VPC em 2 AZ, logs no CloudWatch, imagem no ECR.

## Arquitetura proposta (alto nivel)
- VPC com 2 AZ: sub-redes publicas (ALB, NAT) e privadas (ECS). Rota de saida via NAT para tasks baixarem deps.
- Application Load Balancer publico com listener 80/443 (TLS via ACM). Target group apontando para tarefas ECS.
- ECS Fargate service (min 2 tasks) rodando o container FastAPI. Health check HTTP `/`.
- Credenciais `ADMIN_USER` e `ADMIN_PASS` em AWS Secrets Manager (ou SSM Parameter Store SecureString). Injetadas como env nas tasks.
- Imagem Docker publicada no Amazon ECR.
- Logs de aplicacao em CloudWatch Logs; metricas/alarms em CloudWatch (5xx no ALB, CPU/Memory do service).
- WAF opcional no ALB/CloudFront; Route53 para DNS; ACM para certificados.
- CI/CD (GitHub Actions) que builda, scaneia, publica a imagem no ECR e atualiza o service ECS.

## Fase 0 - Preparacao local
1) Requisitos: AWS CLI configurado (perfil com perms admin ou equivalentes), Docker, Python 3.11+, Make (opcional), git, GitHub Actions runner habilitado no repo forkado.
2) Clonar o fork do repo, criar branch pessoal.
3) Opcional: adicionar Makefile com targets `build`, `push`, `deploy`.

## Fase 1 - Build e push da imagem
1) Na raiz da API (`entregas/challenge-01/app/api`, copia em `devops/challenge-01/api`), criar Dockerfile (exemplo):
   ```Dockerfile
   FROM python:3.11-slim
   WORKDIR /app
   COPY requirements.txt .
   RUN pip install --no-cache-dir -r requirements.txt
   COPY . .
   CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
   ```
2) Criar repositorio no ECR:
   ```bash
   aws ecr create-repository --repository-name fastapi-vars --region <regiao>
   ```
3) Login no ECR e push:
   ```bash
   aws ecr get-login-password --region <regiao> | docker login --username AWS --password-stdin <account>.dkr.ecr.<regiao>.amazonaws.com
   docker build -t fastapi-vars:latest .
   docker tag fastapi-vars:latest <account>.dkr.ecr.<regiao>.amazonaws.com/fastapi-vars:latest
   docker push <account>.dkr.ecr.<regiao>.amazonaws.com/fastapi-vars:latest
   ```

## Fase 2 - Provisionar infraestrutura (rede, seguranca, storage)
1) Criar VPC (ex.: 10.0.0.0/16), 2 sub-redes publicas e 2 privadas em AZs distintas, Internet Gateway, NAT Gateways para cada AZ. Pode usar VPC Quick Create ou CloudFormation/Terraform.
2) Security Groups:
   - SG-ALB: permite 80/443 de 0.0.0.0/0; permite saida 0.0.0.0/0.
   - SG-ECS: permite 8000/health do SG-ALB; saida 0.0.0.0/0 (via NAT).
3) Criar Load Balancer:
   - ALB publico nas sub-redes publicas com SG-ALB.
   - Listener 80 redireciona para 443 se houver TLS; listener 443 com certificado ACM (emitir para dominio no Route53).
   - Target group HTTP na porta 8000, health check path `/`.
4) Criar Secrets:
   - Secrets Manager: secret `fastapi-vars-admin` com campos `ADMIN_USER` e `ADMIN_PASS`. Marcar rotation opcional.
   - Permitir acesso via role da task ECS.
5) Criar bucket opcional para logs do ALB e do WAF (S3 com SSE-KMS).

## Fase 3 - Cluster e service ECS (Fargate)
1) Criar cluster ECS (Fargate).
2) Criar task definition:
   - Compatibilidade Fargate, CPU/Mem ex.: 0.25 vCPU / 512 MB (ajustar conforme carga).
   - Container image: `<account>.dkr.ecr.<regiao>.amazonaws.com/fastapi-vars:latest`.
   - Porta 8000 mapeada; health check HTTP `/`.
   - Logs: driver awslogs para grupo `/ecs/fastapi-vars`.
   - Env vars injetadas do Secrets Manager (`ADMIN_USER`, `ADMIN_PASS`).
   - IAM task role com permissoes para ler o secret e enviar logs/metrics.
3) Criar service ECS:
   - Min 2 replicas, deployment rolling update, sub-redes privadas, attach ao target group do ALB, assign public IP desabilitado.
   - Auto Scaling: target CPU 60% (ex.: min 2, max 6).

## Fase 4 - DNS, TLS e WAF (opcional, recomendado)
1) Criar zona hospedada no Route53 e um record A/AAAA apontando para o ALB (ou usar CloudFront se precisar de cache/geo).
2) Emitir certificado ACM para o dominio e associar ao listener 443.
3) Criar ACL do WAF e associar ao ALB ou CloudFront com regras basicas (SQLi, XSS, rate limit).

## Fase 5 - Observabilidade e SRE basico
1) CloudWatch Logs com retenção (ex.: 30 dias) para a app.
2) CloudWatch Alarms:
   - 5xx no ALB acima de threshold.
   - Latencia ALB p95 alta.
   - CPU/Memory do service ECS acima de 80% sustentado.
   - Integrar com SNS/Slack (Webhook via Lambda) para alertas.
3) Enable AWS X-Ray opcional para rastreamento.
4) CloudTrail habilitado na conta (para auditoria) e config de guardrails (Config, IAM Access Analyzer).

## Fase 6 - CI/CD (GitHub Actions)
Workflow sugerido (`.github/workflows/deploy.yml`):
1) gatilhos: push para main (prod) e branch de hml.
2) jobs:
   - `lint/test`: rodar testes (se adicionados), flake8/ruff, mypy opcional.
   - `build-and-push`:
     - Login no ECR com `aws-actions/amazon-ecr-login`.
     - Build e push da imagem com tag do SHA e `latest`.
   - `deploy`:
     - Atualizar task definition com nova imagem (gera JSON usando aws cli ou step de action `amazon-ecs-render-task-definition`).
     - Executar `aws ecs update-service --cluster <cluster> --service <service> --force-new-deployment`.
3) Secrets do workflow no GitHub:
   - `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`, `ECR_REGISTRY`, `ECR_REPOSITORY`, `ECS_CLUSTER`, `ECS_SERVICE`.
4) Artefatos e controle:
   - Usar tags versionadas (ex.: semver) para releases.
   - Bloquear deploy se testes falharem.

## Fase 7 - Validacao
1) Testar health via ALB: `curl -u <ADMIN_USER>:<ADMIN_PASS> https://<dominio>/`.
2) Verificar logs no CloudWatch e targets healthy no ALB.
3) Simular falha (parar uma task) e validar auto-recovery/auto-scaling.

## Notas finais
- Todo o fluxo pode ser codificado em Terraform/CloudFormation para reproducao: VPC, ALB, SGs, ECS Service, ECR, Secrets, IAM, CloudWatch, Route53, WAF.
- Para custo minimo em dev, usar 1 NAT (shared) e reduzir replicas; em prod manter 2 NAT e 2+ tasks.
