# Q&A - Challenge 03 (Flask serverless em Lambda)

## Por que Lambda + API Gateway?
- Atende carga variavel sem gerenciar infraestrutura; custo sob demanda; integra com ECR para container. Simples para hello-world e escala automatica.

## Como passa a variavel NAME?
- Via env no Terraform/workflow ou SSM SecureString com permissao especifica. Cada alias (staging/prod) pode ter valor diferente. Evitar hardcode em YAML.

## Como e o fluxo de CI/CD?
- GitHub Actions: lint/test -> build/push imagem para ECR -> update-function-code -> update-alias (staging/prod) e setar env NAME. OIDC para assumir role AWS, sem chaves long-lived. Pipelines de app apontam para `entregas/challenge-03/app` (copia mantida em `devops/challenge-03`).

## Observabilidade?
- CloudWatch Logs para Lambda; alarms para 5xx/latencia no API Gateway e erros da funcao. Opcional X-Ray para tracing.

## Segurança?
- IAM role minimo para Lambda (logs). API Gateway com throttling/WAF opcional. Variaveis sensiveis em SSM/Secrets Manager. Sem public buckets. TLS gerenciado pelo API Gateway.

## Como faria rollback?
- Manter versoes publicadas da Lambda; re-apontar o alias para uma versao anterior. Imagens taggeadas por SHA.

## Dev local?
- `docker-compose up` com `NAME=Local`; pre-commit (ruff/black) e pytest. Pode usar `sam local start-api` ou `lambda-runtime-interface-emulator` se quiser simular Lambda.

## E se o tempo de execucao estourar?
- Ajustar timeout/memoria. Para workloads mais pesados, mover para App Runner/ECS ou Lambda com mais CPU/mem. Adicionar retries/backoff no cliente se necessario.

## Como publicar a documentacao?
- Workflow `docs.yml` publica `entregas/challenge-03/app/docs/` no GitHub Pages (environment github-pages).
