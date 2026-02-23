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
    <div>
      <h2 style={{ fontSize: 20, fontWeight: 800 }}>System</h2>
      {err ? <div style={{ color: "crimson" }}>Health check failed: {err}</div> : null}
      <pre style={{ padding: 12, background: "#fafafa", border: "1px solid #eee", borderRadius: 12 }}>
        {data ? JSON.stringify(data, null, 2) : "Loading…"}
      </pre>
    </div>
  );
}