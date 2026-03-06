"use client";

import React, { useCallback, useMemo, useState } from "react";
import { usePathname, useRouter } from "next/navigation";
import Sidebar from "@/components/layout/Sidebar";
import Topbar from "@/components/layout/Topbar";

const TITLES: Record<string, string> = {
  "/": "Dashboard",
  "/reports": "Reports",
  "/users": "Users",
  "/subscriptions": "Subscriptions",
  "/analytics": "Analytics",
  "/audit-logs": "Audit Logs",
  "/system": "System",
};

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  const router = useRouter();
  const pathname = usePathname();
  const [collapsed, setCollapsed] = useState(false);
  const [mobileOpen, setMobileOpen] = useState(false);

  const title = useMemo(() => TITLES[pathname] ?? "Dashboard", [pathname]);

  const logout = useCallback(async () => {
    await fetch("/api/auth/logout", { method: "POST" });
    localStorage.removeItem("datox_admin_role");
    router.replace("/login");
  }, [router]);

  return (
    <div className={`dashboard-shell ${collapsed ? "is-collapsed" : ""}`}>
      <Sidebar
        collapsed={collapsed}
        mobileOpen={mobileOpen}
        onToggleCollapse={() => setCollapsed((prev) => !prev)}
        onCloseMobile={() => setMobileOpen(false)}
        onLogout={logout}
      />

      <div className="dashboard-main">
        <Topbar title={title} onMenuToggle={() => setMobileOpen(true)} onLogout={logout} />
        <main className="dashboard-content">{children}</main>
      </div>
    </div>
  );
}
