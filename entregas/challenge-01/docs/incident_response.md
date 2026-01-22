# Plano de Resposta a Incidentes – Challenge 01 (FastAPI em ECS Fargate)

Contexto: API FastAPI containerizada, deploy em ECS Fargate atrás de ALB. Imagem no ECR; credenciais `ADMIN_USER`/`ADMIN_PASS` definidas via Terraform (recomendado usar Secrets Manager com rotation). Infra: VPC 2 AZ, ALB público, service ECS.

1) Detecção e gatilhos
- CloudWatch Alarms: 5xx/latência alta no ALB, `ECS Service Desired vs Running` divergente, falhas de tarefa (StoppedReason).
- Segurança: alterações suspeitas em SG/NACL, IAM role misuse, tráfego anômalo no ALB/WAF (se habilitado).

2) Triage inicial
- Identificar ambiente (staging/prod), início e alcance (ALB target health, tasks afetadas, sub-redes).
- Congelar deploys não críticos (pausar pipeline de app).

3) Contenção imediata
- Comprometimento: rotacionar secrets (`ADMIN_USER/PASS`), apertar SG para bloquear origens suspeitas.
- Erro/crash: reduzir tráfego (deregister targets) ou scale down temporário; reverter para última task definition estável (`aws ecs update-service ... --task-definition <revision-boa>`).

4) Análise e erradicação
- Logs CloudWatch do service (`/ecs/<service>`) e eventos do ALB (target health). Checar health check no ALB.
- Conferir SG, rotas, dependências externas (ECR pull, DNS, NAT).
- Criar hotfix, gerar nova imagem, validar em staging antes de prod.

5) Recuperação
- Atualizar service ECS com a task definition corrigida; restaurar desired count.
- Validar saúde (targets healthy, 2xx e latência normal). Monitorar reforçado por 24–48h.

6) Comunicação
- Canal interno de incidentes; externo (status page) se aplicável.
- Registrar linha do tempo e responsáveis; abrir postmortem.

7) Pós-incidente
- RCA documentado (causas raiz e contributivas).
- Ações preventivas: mover secrets para Secrets Manager com rotation, alarms adicionais (CPU/mem por tarefa, 5xx do ALB), WAF/Rate limiting se ausentes, testes de integração cobrindo autenticação/admin.

8) Artefatos úteis
- Imagens versionadas (SHA) no ECR; pipelines `.github/workflows/deploy-iac.yml` e `deploy-app.yml`; Terraform state/outputs do ambiente; histórico de health do ALB.
