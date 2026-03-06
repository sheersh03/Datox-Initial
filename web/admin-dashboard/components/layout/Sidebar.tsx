"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { memo, useEffect, useState, type ComponentType } from "react";
import {
  BarChart3,
  ChevronLeft,
  ChevronRight,
  ClipboardList,
  LayoutDashboard,
  LogOut,
  Settings,
  Shield,
  Users,
  WalletCards,
} from "lucide-react";

type SidebarProps = {
  collapsed: boolean;
  mobileOpen: boolean;
  onToggleCollapse: () => void;
  onCloseMobile: () => void;
  onLogout: () => Promise<void>;
};

type NavItem = {
  label: string;
  href: string;
  icon: ComponentType<{ className?: string }>;
};

const navItems: NavItem[] = [
  { label: "Overview", href: "/", icon: LayoutDashboard },
  { label: "Reports", href: "/reports", icon: ClipboardList },
  { label: "Users", href: "/users", icon: Users },
  { label: "Subscriptions", href: "/subscriptions", icon: WalletCards },
  { label: "Analytics", href: "/analytics", icon: BarChart3 },
  { label: "Audit Logs", href: "/audit-logs", icon: Shield },
  { label: "System", href: "/system", icon: Settings },
];

function SidebarComponent({
  collapsed,
  mobileOpen,
  onToggleCollapse,
  onCloseMobile,
  onLogout,
}: SidebarProps) {
  const pathname = usePathname();
  const [role, setRole] = useState<string>("Admin");

  useEffect(() => {
    const storedRole = localStorage.getItem("datox_admin_role");
    if (storedRole?.trim()) {
      setRole(storedRole);
    }
  }, []);

  return (
    <>
      <aside className={`dash-sidebar ${collapsed ? "is-collapsed" : ""} ${mobileOpen ? "is-mobile-open" : ""}`}>
        <div className="sidebar-head">
          <div className="brand-wrap" aria-label="Datox Admin">
            <div className="brand-mark">DX</div>
            {!collapsed ? (
              <div className="brand-copy">
                <div className="brand-text">Datox Admin</div>
                <div className="brand-role">{role.replace(/_/g, " ")}</div>
              </div>
            ) : null}
          </div>
          <button className="icon-btn collapse-btn" onClick={onToggleCollapse} aria-label="Toggle sidebar">
            {collapsed ? <ChevronRight className="icon-18" /> : <ChevronLeft className="icon-18" />}
          </button>
        </div>

        <nav className="sidebar-nav" aria-label="Primary">
          {navItems.map((item) => {
            const active = item.href === "/" ? pathname === "/" : pathname.startsWith(item.href);
            const Icon = item.icon;
            return (
              <Link
                key={item.href}
                href={item.href}
                className={`sidebar-link ${active ? "is-active" : ""}`}
                onClick={onCloseMobile}
              >
                <Icon className="icon-18" />
                {!collapsed ? <span>{item.label}</span> : null}
              </Link>
            );
          })}
        </nav>

        <button className="sidebar-logout" onClick={onLogout}>
          <LogOut className="icon-18" />
          {!collapsed ? <span>Logout</span> : null}
        </button>
      </aside>

      {mobileOpen ? <button className="mobile-scrim" onClick={onCloseMobile} aria-label="Close menu" /> : null}
    </>
  );
}

const Sidebar = memo(SidebarComponent);

export default Sidebar;
