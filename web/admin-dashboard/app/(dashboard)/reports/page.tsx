"use client";

import { useState } from "react";
import { useReports } from "@/hooks/useReports";

export default function ReportsPage() {
  const [status, setStatus] = useState("open");
  const { data, isLoading, error } = useReports(status);

  return (
    <section className="page-card">
      <h2>Reports</h2>
      <p>Review incoming reports and moderation payloads.</p>

      <div className="filter-row" role="tablist" aria-label="Report status filters">
        <button
          onClick={() => setStatus("open")}
          className={`filter-btn ${status === "open" ? "is-active" : ""}`}
          role="tab"
          aria-selected={status === "open"}
        >
          Open
        </button>
        <button
          onClick={() => setStatus("closed")}
          className={`filter-btn ${status === "closed" ? "is-active" : ""}`}
          role="tab"
          aria-selected={status === "closed"}
        >
          Closed
        </button>
      </div>

      <div className="page-body">
        {isLoading ? <div className="info-text">Loading...</div> : null}
        {error ? <div className="error-text">Failed to load reports.</div> : null}

        <pre className="code-preview">
          {data ? JSON.stringify(data, null, 2) : "No data yet. Connect backend and ensure admin session."}
        </pre>
      </div>
    </section>
  );
}
