# Plano de Resposta a Incidentes — Challenge 02 (Django + FastAPI + Batch/Step Functions em EKS)

Contexto: Front Django e API FastAPI em EKS; Aurora Postgres; S3 uploads/resultados; Batch/Step Functions; ALB/Ingress; imagens no ECR; secrets em SSM/Secrets; IaC Terraform.

1) Detecção e gatilhos
- Alarms: 5xx/latência ALB, HPA saturado, pods não prontos, fila/idade Batch alta, erros Step Functions, conexões RDS, erros S3.
- Segurança: eventos IAM suspeitos, WAF (se ativo), SG/ACL alterados, objetos S3 públicos.

2) Triage
- Definir ambiente (hml/prod), serviços afetados (web, api, pipeline Batch), tempo de início e alcance (AZs, namespaces).
- Suspender deploys até estabilizar.

3) Contenção
- Incidente de segurança: isolar namespace ou SG, revogar/rotacionar secrets, suspender execuções Batch/Step Functions.
- Falha app: rollback para imagem anterior; reduzir tráfego (limitar ingress) se necessário.
- DB indisponível: failover Aurora (se Multi-AZ), ajustar SG/rotas.

4) Análise e erradicação
- Logs: pods (kubectl/CloudWatch), ALB access logs, Step Functions execution history, Batch job logs, RDS eventos/Performance Insights.
- Infra: checar SG, rotas, NAT, quotas; validar IAM (IRSA) para S3/States/Batch.
- Corrigir código/config, build nova imagem, validar em hml antes de prod.

5) Recuperação
- Reimplantar imagens corrigidas, retomar execuções Batch/Step Functions.
- Validar saúde: targets healthy, p95 normal, fila Batch reduzindo, erro Step Functions zerando, RDS estável.
- Monitorar por 24–48h com alarmes ampliados.

6) Comunicação
- Status interno via canal de incidentes; externo (status page) se impacto a clientes.
- Registrar linha do tempo, ações e owners.

7) Pós-incidente
- RCA com causa raiz/contributivas.
- Ações: reforçar tests de integração (DB/S3/States), alarmes de fila/idade Batch, policies IAM mínimas, WAF/rate limit, backups/restore drills, chaos (falha de CE/Spot) se cabível.

8) Artefatos úteis
- IaC em `entregas/challenge-02/iac`; manifests K8s em `entregas/challenge-02/k8s/`; pipelines `deploy-iac.yml` e `deploy-app.yml`; imagens versionadas no ECR; history de Step Functions/Batch.
