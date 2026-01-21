# Plano de Resposta a Incidentes — Challenge 01 (FastAPI)

Contexto: API FastAPI containerizada, deploy em EKS (Deployment/Service), imagem no ECR, secrets ADMIN em Kubernetes. Infra provisória via Terraform (VPC/ALB/ECS/EKS).

1) Detecção e gatilhos
- Alarms CloudWatch/Prometheus: p95 alta, 5xx/4xx incomuns, pods não prontos, readiness/liveness falhando, picos de 401/403.
- Alertas de segurança: IAM role misuse, alterações em SGs/Network ACLs, tráfego anômalo no ALB/WAF.

2) Triage inicial
- Confirmar escopo (ambiente: staging/prod), tempo de início, blast radius (ALB target health, pods afetados, nós EKS).
- Congelar mudanças não essenciais (pausar deploys).

3) Contenção imediata
- Se comprometimento: revogar/rotacionar secrets (`ADMIN_USER/PASS`), isolar namespace ou bloquear SG/Ingress suspeitos.
- Se crash/erro app: scale to zero e reverter para última imagem estável (deployment rollback).

4) Análise e erradicação
- Logs: `kubectl logs`, CloudWatch (stdout), eventos do Deployment/ReplicaSet.
- Infra: verificar ALB target health, SGs, rotas; checar IAM role do pod.
- Aplicar fix em branch hotfix, gerar nova imagem, validar em staging antes de prod.

5) Recuperação
- Reimplantar imagem corrigida; reabilitar tráfego gradualmente (HPA/rollout progressivo).
- Validar saúde (readiness ok, 2xx/latência normal). Manter monitoração ampliada por 24–48h.

6) Comunicação
- Status interno: canal incidentes; externo se necessário (status page).
- Registrar linha do tempo e owners; abrir postmortem.

7) Pós-incidente
- RCA documentado (causa raiz e contributivas).
- Ações preventivas: testes de integração conectando ao backend, alarms adicionais, política de secrets (rotation), WAF/Rate limiting se não houver.

8) Artefatos úteis
- Imagens versionadas por SHA no ECR; manifests em `k8s/`; pipeline `deploy-app.yml`; Terraform state/outputs do ambiente.
