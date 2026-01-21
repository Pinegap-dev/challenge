# Challenge 04 - API (FastAPI)

API de referência para o desafio: expõe endpoints para receber uploads, acionar análise (Batch/Step Functions) e consultar resultados.

## Endpoints principais
- `GET /health`: healthcheck.
- `POST /samples/{sample_id}/files/presign`: gera URL (stub) pré-assinada para upload de arquivos.
- `POST /samples/{sample_id}/analyze`: simula disparo do workflow; marca status como `completed` e gera URLs de resultado.
- `GET /samples/{sample_id}/results`: consulta status/URLs de resultados.

## Como rodar local
```bash
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

## Docker
```bash
docker build -t challenge04-api .
docker run -p 8000:8000 challenge04-api
```
