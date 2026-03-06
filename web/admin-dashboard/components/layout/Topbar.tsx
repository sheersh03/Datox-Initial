"use client";

import { memo } from "react";
import { Bell, LogOut, Menu, Search } from "lucide-react";

type TopbarProps = {
  title: string;
  onMenuToggle: () => void;
  onLogout: () => Promise<void>;
};

function TopbarComponent({ title, onMenuToggle, onLogout }: TopbarProps) {
  return (
    <header className="dash-topbar">
      <div className="topbar-left">
        <button className="icon-btn mobile-menu-btn" onClick={onMenuToggle} aria-label="Open menu">
          <Menu className="icon-18" />
        </button>
        <h1>{title}</h1>
      </div>

      <label className="topbar-search" aria-label="Search">
        <Search className="icon-18" />
        <input type="search" placeholder="Search reports, users, subscriptions" />
      </label>

      <div className="topbar-actions">
        <button className="icon-btn" aria-label="Notifications">
          <Bell className="icon-18" />
        </button>

        <div className="profile-pill" aria-label="Profile">
          <div className="avatar">AD</div>
          <span>Admin</span>
        </div>

        <button className="logout-btn" onClick={onLogout}>
          <LogOut className="icon-16" />
          Logout
        </button>
      </div>
    </header>
  );
}

const Topbar = memo(TopbarComponent);

export default Topbar;
