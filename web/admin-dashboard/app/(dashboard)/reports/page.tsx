"use client";

import { useState } from "react";
import { useReports } from "@/hooks/useReports";

export default function ReportsPage() {
  const [status, setStatus] = useState("open");
  const { data, isLoading, error } = useReports(status);

  return (
    <div>
      <h2 style={{ fontSize: 20, fontWeight: 800 }}>Reports</h2>

      <div style={{ marginTop: 12, display: "flex", gap: 8 }}>
        <button onClick={() => setStatus("open")} style={{ padding: 8, borderRadius: 10, border: "1px solid #ddd" }}>
          Open
        </button>
        <button onClick={() => setStatus("closed")} style={{ padding: 8, borderRadius: 10, border: "1px solid #ddd" }}>
          Closed
        </button>
      </div>

      <div style={{ marginTop: 16 }}>
        {isLoading ? <div>Loading…</div> : null}
        {error ? <div style={{ color: "crimson" }}>Failed to load reports.</div> : null}

        <pre style={{ padding: 12, background: "#fafafa", border: "1px solid #eee", borderRadius: 12, overflow: "auto" }}>
          {data ? JSON.stringify(data, null, 2) : "No data yet. Connect backend and ensure admin session."}
        </pre>
      </div>
    </div>
  );
}