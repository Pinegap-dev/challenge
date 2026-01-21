from datetime import datetime, timedelta
from typing import Dict, List, Optional

from fastapi import FastAPI, HTTPException, Path
from pydantic import BaseModel, Field

app = FastAPI(title="Challenge 04 API", version="1.0.0")

# In-memory demo storage (substitui banco/queues reais)
SAMPLES: Dict[str, Dict] = {}


class PresignRequest(BaseModel):
    filename: str = Field(..., example="sample1.raw")
    content_type: Optional[str] = Field(None, example="application/octet-stream")


class PresignResponse(BaseModel):
    sample_id: str
    upload_url: str
    fields: Dict[str, str]
    expires_at: datetime


class AnalysisTriggerRequest(BaseModel):
    priority: Optional[str] = Field("normal", description="normal|high")


class AnalysisStatus(BaseModel):
    sample_id: str
    status: str
    submitted_at: datetime
    completed_at: Optional[datetime] = None
    results: List[str] = Field(default_factory=list)


@app.get("/health")
def health():
    return {"status": "ok", "service": "fastapi", "message": "healthy"}


@app.post(
    "/samples/{sample_id}/files/presign",
    response_model=PresignResponse,
    summary="Gerar URL pre-assinada para upload no bucket de uploads",
)
def presign_upload(
    sample_id: str = Path(..., description="Identificador da amostra"),
    req: PresignRequest = None,
):
    # Stub: gera URL fake; em produção use boto3 S3.generate_presigned_post
    expires_at = datetime.utcnow() + timedelta(minutes=15)
    SAMPLES.setdefault(sample_id, {"status": "draft", "submitted_at": datetime.utcnow(), "results": []})
    return PresignResponse(
        sample_id=sample_id,
        upload_url=f"https://uploads.example.com/{sample_id}/{req.filename}",
        fields={
            "Content-Type": req.content_type or "application/octet-stream",
            "acl": "private",
        },
        expires_at=expires_at,
    )


@app.post(
    "/samples/{sample_id}/analyze",
    response_model=AnalysisStatus,
    summary="Disparar pipeline (Step Functions + Batch)",
)
def trigger_analysis(
    sample_id: str = Path(..., description="Identificador da amostra"),
    req: AnalysisTriggerRequest = None,
):
    sample = SAMPLES.get(sample_id)
    if not sample:
        raise HTTPException(status_code=404, detail="Sample not found; faça upload antes.")
    now = datetime.utcnow()
    sample.update(
        {
            "status": "submitted",
            "submitted_at": sample.get("submitted_at", now),
            "priority": req.priority if req else "normal",
        }
    )
    # Stub: simula conclusão imediata
    sample["status"] = "completed"
    sample["completed_at"] = now + timedelta(minutes=5)
    sample["results"] = [
        f"s3://results-bucket/{sample_id}/report.pdf",
        f"s3://results-bucket/{sample_id}/summary.json",
    ]
    return AnalysisStatus(
        sample_id=sample_id,
        status=sample["status"],
        submitted_at=sample["submitted_at"],
        completed_at=sample["completed_at"],
        results=sample["results"],
    )


@app.get(
    "/samples/{sample_id}/results",
    response_model=AnalysisStatus,
    summary="Consultar status e URLs de resultados",
)
def get_results(sample_id: str = Path(..., description="Identificador da amostra")):
    sample = SAMPLES.get(sample_id)
    if not sample:
        raise HTTPException(status_code=404, detail="Sample not found")
    return AnalysisStatus(
        sample_id=sample_id,
        status=sample.get("status", "draft"),
        submitted_at=sample.get("submitted_at", datetime.utcnow()),
        completed_at=sample.get("completed_at"),
        results=sample.get("results", []),
    )
