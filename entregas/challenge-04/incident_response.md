# Plano de Resposta a Incidentes — Challenge 04 (Next.js + FastAPI + Batch/Step Functions)

Contexto: Front Next.js e API FastAPI em EKS; Aurora Postgres; S3 uploads/resultados; Batch/Step Functions; ALB/Ingress; imagens no ECR; IaC modular Terraform.

1) Detecção e gatilhos
- Alarms: 5xx/latência ALB, pods não prontos, HPA saturado, fila/idade Batch, falhas Step Functions, conexões RDS, erros S3.
- Segurança: IAM/IRSA uso indevido, WAF (se ativo) com bloqueios, SG/ACL alterados, objetos S3 públicos.

2) Triage
- Confirmar ambiente (hml/prod), serviços impactados (front, API, pipeline Batch), horário e alcance (AZs, namespaces).
- Pausar deploys enquanto investiga.

3) Contenção
- Incidente de segurança: isolar namespace ou SG, revogar/rotacionar secrets, suspender execuções Step Functions/Batch.
- Regressão app: rollback Deployment para imagem estável; limitar tráfego via Ingress/ALB se preciso.
- DB indisponível: failover Aurora (Multi-AZ), ajustar SG/rotas.

4) Análise e erradicação
- Logs: pods (kubectl/CloudWatch), ALB access logs, Step Functions execution history, Batch job logs, eventos RDS.
- Infra: checar SG, rotas/NAT, quotas; validar IAM/IRSA para S3/States/Batch/KMS.
- Aplicar correção em branch hotfix, build nova imagem, validar em hml antes de prod.

5) Recuperação
- Reimplantar imagens corrigidas, reativar pipelines Batch/Step Functions.
- Validar saúde: targets healthy, p95 normal, fila Batch baixando, Step Functions sem erros, RDS ok.
- Monitoramento reforçado por 24–48h.

6) Comunicação
- Atualizar canais internos e, se impactar clientes, status externo. Registrar linha do tempo e responsáveis.

7) Pós-incidente
- RCA com ações preventivas: testes de integração (DB/S3/States/Batch), alarms extras (fila/idade, 5xx, latência), WAF/rate limiting, drills de restore, política de least privilege revisada.

8) Artefatos úteis
- IaC em `entregas/challenge-04/`; manifests K8s em `entregas/challenge-04/k8s/`; pipelines `deploy-iac.yml` e `deploy-app.yml`; imagens no ECR; state machine e queue Batch/Step Functions.
