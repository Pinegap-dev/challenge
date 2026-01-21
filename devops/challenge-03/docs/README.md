# Publicacao via GitHub Pages

Este diretorio `docs/` e publicado pelo workflow `.github/workflows/docs.yml`.

### Como publicar
1) Faça push na branch `main` com os arquivos atualizados em `docs/`.
2) O workflow `docs-pages` cria o artefato e faz deploy para a Pages (environment `github-pages`).

### Estrutura
- `index.md`: conteudo principal (app, dev, deploy).
- Adicione novos md conforme necessario.
