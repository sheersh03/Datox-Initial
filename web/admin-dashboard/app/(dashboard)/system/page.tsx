"use client";

import { useEffect, useState } from "react";

export default function SystemPage() {
  const [data, setData] = useState<any>(null);
  const [err, setErr] = useState<string | null>(null);

  useEffect(() => {
    fetch("/api/health", { cache: "no-store" })
      .then(async (r) => {
        if (!r.ok) throw new Error(String(r.status));
        setData(await r.json().catch(() => ({})));
      })
      .catch((e) => setErr(e?.message || "error"));
  }, []);

  return (
    <section className="page-card">
      <h2>System</h2>
      <p>Service health and diagnostics.</p>
      {err ? <div className="error-text">Health check failed: {err}</div> : null}
      <pre className="code-preview">{data ? JSON.stringify(data, null, 2) : "Loading..."}</pre>
    </section>
  );
}
