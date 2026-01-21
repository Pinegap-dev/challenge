# Plano de Resposta a Incidentes — Challenge 03 (Flask)

Contexto: App Flask containerizada, deploy em EKS (Deployment/Service) e Lambda/API Gateway (serverless). Imagem no ECR; env `NAME`; docs em Pages; IaC Terraform (Lambda) e K8s manifests.

1) Detecção e gatilhos
- Alarms: 5xx/latência API Gateway, erros Lambda, pods não prontos em EKS, p95 alta, falhas de rollout, erros de imagem pull.
- Segurança: IAM role misuse, alterações em SG/Ingress, tráfego anômalo.

2) Triage
- Identificar superfície afetada (Lambda/API Gateway ou EKS), ambiente (staging/prod), horário e alcance.
- Pausar deploys até estabilizar.

3) Contenção
- Para comprometimento: revogar/rotacionar secrets/roles, bloquear endpoint (WAF/throttling) ou restringir Ingress/SG.
- Para regressão de app: rollback alias da Lambda para versão anterior; em EKS, rollback deployment.

4) Análise e erradicação
- Logs: CloudWatch (Lambda), APIGW access logs, pods (kubectl/CloudWatch), eventos de rollout.
- Infra: checar IAM (assume-role OIDC), SG, rotas; erros de imagem (ECR).
- Aplicar fix, gerar nova imagem, testar em staging e promover.

5) Recuperação
- Reapontar alias Lambda para versão corrigida; reimplantar deployment EKS com imagem nova.
- Validar saúde: 2xx/latência normal, erros Lambda zerando, pods prontos. Monitorar 24–48h.

6) Comunicação
- Status interno e, se impacto cliente, externo. Registrar linha do tempo e responsáveis.

7) Pós-incidente
- RCA com causa raiz/contributivas.
- Ações: alarmes adicionais (throttles, cold starts anormais), testes de integração no CI, reforço de limits/rate no APIGW/Ingress, rotação de secrets, checagens de rollout.

8) Artefatos úteis
- Pipelines `deploy-iac.yml`, `deploy-app.yml`, `devops/challenge-03/.github/workflows/ci-cd.yml`; manifests em `entregas/challenge-03/k8s/`; IaC Lambda em `entregas/challenge-03/iac/`; imagens versionadas no ECR.
