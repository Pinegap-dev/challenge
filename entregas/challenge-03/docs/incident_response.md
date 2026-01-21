# Plano de Resposta a Incidentes — Challenge 03 (Flask)

Contexto: App Flask containerizada, deploy serverless em Lambda + API Gateway. Imagem no ECR; env `NAME`; docs em Pages; IaC Terraform (Lambda).

1) Detecção e gatilhos  
- Alarmes: 5xx/latência API Gateway, erros/throttles da Lambda, p95 alta, falhas de rollout, erros de imagem pull.  
- Segurança: IAM role misuse, mudanças em SG, tráfego anômalo.

2) Triage  
- Identificar superfície afetada (Lambda/API Gateway), ambiente (staging/prod), horário e alcance.  
- Pausar deploys até estabilizar.

3) Contenção  
- Comprometimento: rotacionar secrets/roles, bloquear endpoint (WAF/throttling) ou restringir SG.  
- Regressão: rollback do alias da Lambda para versão anterior.

4) Análise e erradicação  
- Logs: CloudWatch (Lambda), access logs do API Gateway, eventos de rollout.  
- Infra: checar IAM, SG, rotas; erros de imagem (ECR).  
- Aplicar fix, gerar nova imagem, testar em staging e promover.

5) Recuperação  
- Reapontar alias Lambda para a versão corrigida.  
- Validar saúde: 2xx/latência normal, erros Lambda zerando. Monitorar 24–48h.

6) Comunicação  
- Status interno e, se impacto ao cliente, externo. Registrar linha do tempo e responsáveis.

7) Pós-incidente  
- RCA com causa raiz/contributivas.  
- Ações: alarmes adicionais (throttles, cold starts anormais), testes de integração no CI, reforço de limits/rate no API Gateway, rotação de secrets, checagens de rollout.

8) Artefatos úteis  
- Pipelines `deploy-iac.yml`, `deploy-app.yml`, `devops/challenge-03/.github/workflows/ci-cd.yml`; IaC Lambda em `entregas/challenge-03/iac/`; imagens versionadas no ECR.
