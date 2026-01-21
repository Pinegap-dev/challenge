# Fluxo de desenvolvimento (Challenge 03)

- Branches:
  - `main`: producao
  - `develop`: homologacao
  - feature branches: `feat/<descricao>`; fix branches: `fix/<descricao>`
- Commits: convencao simples `tipo: resumo` (ex.: `feat: add lambda deploy workflow`, `fix: handle missing NAME env`). PRs pequenos, com checklist de lint/test.
- PRs:
  - feature -> develop (revisao obrigatoria, CI verde)
  - develop -> main via release PR; exige aprovacao + gate de deploy prod
- Versionamento de imagem: usar tag do SHA e semver em releases; manter `latest` apenas para dev local.
- Revisao: exigir pelo menos 1 reviewer e status checks (ruff, black, pytest) passando antes de merge.
- GitHub Pages: publicar docs a partir de branch `gh-pages` (gerado por workflow) ou pasta `docs` na main.
