# Plano de execucao dos desafios DevOps

- [x] Repositorio `technical-challenges` clonado
- [x] READMEs dos desafios 01 a 04 revisados
- [x] Estrutura base `entregas/` 
- [x] Produzir as entregas e documentos descritos abaixo

## Estrutura de trabalho
- `entregas/challenge-01/`: materiais do desafio 01 (deploy FastAPI na AWS).
- `entregas/challenge-02/`: materiais do desafio 02 (arquitetura Django + FastAPI + batch na AWS).
- `entregas/challenge-03/`: materiais do desafio 03 (app Flask e pipeline serverless).
- `entregas/challenge-04/`: materiais do desafio 04 (Next.js + FastAPI + IaC e pipelines).
- Cada pasta deve conter: documentos finais (md), diagramas, scripts, IaC e anotacoes de apoio.

## Challenge 01 - Deploy da API FastAPI
- Objetivo: descrever, em `parte1.md`, um passo a passo reproduzivel para publicar a API FastAPI (usa envs `ADMIN_USER` e `ADMIN_PASS`) na AWS. Vale ajustar o codigo ou adicionar arquivos se ajudarem o deploy.
- Fases e checklist:
- [x] Ler README e codigo da API em `entregas/challenge-01/app/api` (copia de referencia mantida em `devops/challenge-01/api`)
  - [x] Escolher arquitetura AWS alvo (ex.: ECS Fargate ou EKS com ALB, VPC com 2 AZ, secrets no SSM/Secrets Manager, logs no CloudWatch)
  - [x] Gerar diagrama e exportar para `entregas/challenge-01/diagramas/`
  - [x] Documentar todo o fluxo (build da imagem, repositorio ECR, criacao de VPC, ALB/Ingress, SG, IAM, secrets, deploy, observabilidade, CI/CD) em `entregas/challenge-01/parte1.md`
- [x] IaC: Terraform modular em `entregas/challenge-01/iac/` (network + ecs_fastapi)

## Challenge 02 - Arquitetura Django + FastAPI + Step Functions/Batch
- Objetivo: propor arquitetura completa em AWS para app web (frontend Django, API FastAPI em Kubernetes), orquestracao com Step Functions + Batch, S3 para arquivos, RDS para dados. Entregas incluem diagramas, passo a passo de provisionamento, mitigar riscos de seguranca/DevOps e um deck para apresentacao.
- Fases e checklist:
  - [x] Ler README e requisitos
  - [x] Definir arquitetura alvo (componentes AWS, alta disponibilidade, escalabilidade, retencao: uploads 1 ano, resultados 5 anos)
  - [x] Descrever provisionamento end-to-end (rede, EKS, RDS, S3 com lifecycle, ECR, Step Functions + Batch, observabilidade, backup, seguranca)
  - [x] Preparar material de apresentacao (slides) e roteiro de Q&A SRE
  - [x] Exportar diagrama(s)  `entregas/challenge-02/diagramas/` e documentar em `entregas/challenge-02/README.md`
  - [x] QA em `entregas/challenge-02/qa.md`
- [x] IaC: Terraform em `entregas/challenge-02/iac/` reutilizando modulos (network/kms/s3/ecr/rds/eks/batch_sfn)

## Challenge 03 - App Flask production-ready e CI/CD serverless
- Objetivo: evoluir a app Flask em `entregas/challenge-03/app` (copia mantida em `devops/challenge-03`) para ser production-ready, com checklist do README, deploy serverless AWS para homologacao e producao via GitHub Actions, mais documentacao publicada no GitHub Pages.
- Fases e checklist:
  - [x] Ler README e codigo atual
  - [x] Ajustar app para usar env `NAME` no greeting
  - [x] Atualizar `.gitignore` para Python
  - [x] Definir fluxo de desenvolvimento (branches, convencao de commits, revisao)
  - [x] Adicionar ferramentas de qualidade (lint/format/test, pre-commit, analise estatica)
  - [x] Containerizar app e definir compose/local dev
  - [x] Definir deploy serverless na AWS (ex.: API Gateway + Lambda via imagem ou AWS App Runner) com dois ambientes
  - [x] Construir pipelines GitHub Actions (lint/test -> build/publish imagem -> deploy staging/prod)
  - [x] Escrever documentacao e publicar via GitHub Pages
  - [x] Gerar diagrama(s) e salvar em `entregas/challenge-03/diagramas/`
  - [x] QA em `entregas/challenge-03/qa.md`
- [x] IaC: Terraform em `entregas/challenge-03/iac/` (Lambda + API Gateway)

## Challenge 04 - Arquitetura Next.js + FastAPI + IaC e pipelines
- Objetivo: propor arquitetura completa em AWS com front Next.js, API FastAPI em Kubernetes, pipeline Step Functions + Batch, buckets com retencao (365 dias para uploads, 5 anos para resultados), RDS, custos otimizados e seguranca. Entregar Terraform (arquivo unico), pipelines GitHub Actions para hml/prod, documentacao hospedada em Pages.
- Fases e checklist:
  - [x] Ler README e requisitos
  - [x] Definir arquitetura alvo (camadas web, API, dados, processamento batch, observabilidade, seguranca, custo)
  - [x] Redigir Terraform (modular) com recursos essenciais (VPC, EKS, RDS, S3, IAM, ECR, Step Functions, Batch) evitando modulos custom
  - [x] Planejar/configurar pipelines GitHub Actions (build/test -> terraform plan/apply -> build/publish imagens -> deploy hml/prod)
  - [x] Documentar IaC em `entregas/challenge-04/README.md`; restante (pipelines/Pages) pendente
  - [x] Gerar diagrama(s)  e salvar em `entregas/challenge-04/diagramas/`
