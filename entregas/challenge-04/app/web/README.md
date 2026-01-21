# Challenge 04 - Front (Next.js)

Frontend de referência com interação mínima com a API:
- Define `sampleId` e `filename`.
- Botões para: gerar presign, disparar análise e consultar resultados.
- Usa `NEXT_PUBLIC_API_BASE` para apontar para a API (default `http://localhost:8000`).

## Dev
```bash
npm install
npm run dev
# acessar http://localhost:3000
```

## Build/Run Docker
```bash
docker build -t challenge04-web .
docker run -p 3000:3000 challenge04-web
```
