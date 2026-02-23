"use client";

import React from "react";
import { useRouter } from "next/navigation";

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  const router = useRouter();

  async function logout() {
    await fetch("/api/auth/logout", { method: "POST" });
    router.replace("/login");
  }

  return (
    <div style={{ display: "grid", gridTemplateColumns: "240px 1fr", minHeight: "100vh" }}>
      <aside style={{ borderRight: "1px solid #eee", padding: 16 }}>
        <div style={{ fontWeight: 800 }}>Datox Admin</div>
        <nav style={{ marginTop: 16, display: "grid", gap: 8 }}>
          <a href="/">Overview</a>
          <a href="/reports">Reports</a>
          <a href="/users">Users</a>
          <a href="/subscriptions">Subscriptions</a>
          <a href="/analytics">Analytics</a>
          <a href="/audit-logs">Audit Logs</a>
          <a href="/system">System</a>
        </nav>
      </aside>

      <main style={{ padding: 20 }}>
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 16 }}>
          <div style={{ fontSize: 18, fontWeight: 700 }}>Dashboard</div>
          <button onClick={logout} style={{ padding: "8px 12px", borderRadius: 10, border: "1px solid #ddd" }}>
            Logout
          </button>
        </div>
        {children}
      </main>
    </div>
  );
}