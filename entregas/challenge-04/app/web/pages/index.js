import { useState } from "react";

const API_BASE = process.env.NEXT_PUBLIC_API_BASE || "http://localhost:8000";

export default function Home() {
  const [sampleId, setSampleId] = useState("sample-001");
  const [filename, setFilename] = useState("file.raw");
  const [log, setLog] = useState([]);

  const appendLog = (msg) => setLog((prev) => [...prev, msg]);

  const callPresign = async () => {
    appendLog(`Gerando presign para ${filename}...`);
    const res = await fetch(`${API_BASE}/samples/${sampleId}/files/presign`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ filename }),
    });
    const data = await res.json();
    appendLog(`Presign OK: ${data.upload_url}`);
  };

  const callAnalyze = async () => {
    appendLog(`Disparando analise para ${sampleId}...`);
    const res = await fetch(`${API_BASE}/samples/${sampleId}/analyze`, { method: "POST" });
    const data = await res.json();
    appendLog(`Status: ${data.status}`);
  };

  const callResults = async () => {
    appendLog(`Consultando resultados de ${sampleId}...`);
    const res = await fetch(`${API_BASE}/samples/${sampleId}/results`);
    const data = await res.json();
    appendLog(`Resultados: ${data.results?.join(", ") || "n/d"}`);
  };

  return (
    <main style={{ minHeight: "100vh", display: "grid", placeItems: "center", fontFamily: "Inter, sans-serif", padding: "2rem" }}>
      <div style={{ width: "100%", maxWidth: 720 }}>
        <h1>Challenge 04 - Front</h1>
        <p>Interface de referência para upload e análise (stub).</p>

        <div style={{ marginTop: "1rem", display: "grid", gap: "0.5rem" }}>
          <label>
            Sample ID:
            <input value={sampleId} onChange={(e) => setSampleId(e.target.value)} style={{ width: "100%" }} />
          </label>
          <label>
            Filename:
            <input value={filename} onChange={(e) => setFilename(e.target.value)} style={{ width: "100%" }} />
          </label>
          <div style={{ display: "flex", gap: "0.5rem", flexWrap: "wrap" }}>
            <button onClick={callPresign}>Gerar presign</button>
            <button onClick={callAnalyze}>Disparar análise</button>
            <button onClick={callResults}>Ver resultados</button>
          </div>
        </div>

        <div style={{ marginTop: "1.5rem", padding: "1rem", border: "1px solid #ccc", borderRadius: 8 }}>
          <strong>Log:</strong>
          <ul>
            {log.map((line, idx) => (
              <li key={idx}>{line}</li>
            ))}
          </ul>
        </div>
      </div>
    </main>
  );
}
