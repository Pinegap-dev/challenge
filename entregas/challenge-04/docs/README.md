# Challenge 04 - Visão Geral

Arquitetura proposta: Next.js (front) + FastAPI (API) em EKS, RDS Aurora Postgres, buckets S3 (uploads 365d, resultados 5y) com SSE-KMS, Step Functions + Batch para processamento, ECR para imagens, edge opcional (CloudFront/ACM/WAF), observabilidade e segurança alinhadas.

Apps de referência: código em `app/api` (FastAPI) e `app/web` (Next.js), prontos para build/push via pipeline. O front consome a API via `NEXT_PUBLIC_API_BASE` (variável injetada no manifest). Manifests k8s em `k8s/`, IaC em `iac/`.

Como usar:
1) Ajustar vars/secrets conforme `docs/VARIABLES.md` e `docs/setup_variable.md`.
2) Executar pipelines `deploy-iac.yml` (Terraform) e `deploy-app.yml` (build/push -> deploy EKS).
3) Publicar docs com `docs.yml` (Pages).
